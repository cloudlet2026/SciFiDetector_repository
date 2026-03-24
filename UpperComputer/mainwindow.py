# This Python file uses the following encoding: utf-8
import sys
import os
import serial
import serial.tools.list_ports
import numpy as np
import math
import matplotlib.pyplot as plt
from datetime import datetime, timedelta

from PySide2.QtWidgets import QApplication, QMainWindow, QFileDialog, QMessageBox, QWidget, QVBoxLayout, QLabel, QLineEdit
from PySide2.QtCore import Qt, QThread, Signal, QTimer, Slot
from PySide2.QtGui import QFont, QColor

from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

# 重要：
# 需要运行以下命令来生成 ui_form.py 文件
#     pyside2-uic form.ui -o ui_form.py

from ui_form import Ui_MainWindow

# ==================== 全局字体设置 ====================
# 界面字体设置
APP_FONT_FAMILY = "Microsoft YaHei"
APP_FONT_SIZE = 10

# Matplotlib绘图字体设置
plt.rcParams['font.sans-serif'] = ['TimesSimSun', 'Microsoft YaHei', 'SimHei', 'SimSun', 'FangSong', 'KaiTi']
plt.rcParams['axes.unicode_minus'] = False
plt.rcParams['font.size'] = 12
plt.rcParams['axes.titlesize'] = 12
plt.rcParams['axes.labelsize'] = 12
plt.rcParams['xtick.labelsize'] = 12
plt.rcParams['ytick.labelsize'] = 12
plt.rcParams['legend.fontsize'] = 12
# ==================== 串口处理线程 ====================

class SerialWorkThread(QThread):
    raw_data_signal = Signal(str)
    plot_data_signal = Signal(list)
    daq_done = Signal()
    timeout_signal = Signal()
    
    def __init__(self, serial_inst, mode='wave', target_count=64, start_time=None, acq_time=None, timeout=5000):
        super().__init__()
        self.serial_inst = serial_inst
        self.running = False
        self.mode = mode
        self.target_count = target_count
        self.buffer = []
        self.start_time = start_time
        self.acq_time = acq_time
        self.timeout = timeout
        
    def set_target_count(self, count):
        self.target_count = count
        self.buffer = []
        
    def run(self):
        self.running = True
        self.buffer = []
        current_mode = None
        
        while self.running and self.serial_inst.is_open:
            try:
                if self.start_time is not None and self.acq_time is not None:
                    if datetime.now() - self.start_time >= self.acq_time:
                        self.daq_done.emit()  
                        self.running = False
                        break
                if self.serial_inst.in_waiting > 0:
                    line = self.serial_inst.readline().decode('utf-8', errors='ignore').strip()
                    if line:
                        try:
                            # 根据数据前缀自适应解析模式
                            if line.startswith('wave_ack,'):
                                current_mode = 'wave'
                                data_part = line.split(',', 1)[1]
                                parts = data_part.split(',') if ',' in data_part else data_part.split()
                            elif line.startswith('daq_ack,'):
                                current_mode = 'daq'
                                data_part = line.split(',', 1)[1]
                                parts = data_part.split(',') if ',' in data_part else data_part.split()
                            else:
                                # 没有前缀，使用初始化时的mode
                                current_mode = self.mode
                                parts = line.split(',') if ',' in line else line.split()
                            
                            values = [float(x) for x in parts if x]
                            
                            if current_mode == 'wave':
                                self.buffer.append(values)
                                self.plot_data_signal.emit(values)  
                                
                                # 对于单个波形数据包，通常为1行
                                if self.target_count > 0 and len(self.buffer) >= self.target_count:
                                    self.daq_done.emit()  
                                    self.running = False
                                    break
                                    
                            elif current_mode == 'daq':
                                if len(values) >= 2:
                                    self.buffer.append(values)
                                    self.plot_data_signal.emit(values)
                                else:
                                    self.msleep(5)
                                
                        except ValueError:
                            pass
            except Exception as e:
                self.raw_data_signal.emit(f"串口错误: {str(e)}")  
                break

# ==================== Matplotlib 画布 ====================

class MplCanvas(FigureCanvas):
    def __init__(self, parent=None, width=10, height=5, dpi=100):
        self.fig = Figure(figsize=(width, height), dpi=dpi, facecolor='#ffffff')
        self.ax = self.fig.add_subplot(111, facecolor='#ffffff')
            
        super().__init__(self.fig)
        self.setParent(parent)  
        self.setup_style()
        
    def setup_style(self):
        self.ax.tick_params(labelsize=10)
        self.ax.grid(True, alpha=0.3, linestyle='--', linewidth=0.8)
        self.fig.tight_layout(pad=2.0)

# ==================== 主窗口 ====================

class MainWindow(QMainWindow):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.ui = Ui_MainWindow()
        self.setWindowTitle("8通道采集上位机")
        self.ui.setupUi(self)
        
        # --- 初始化 ---
        self.serial_inst = serial.Serial()
        self.wave_data = []  # 波形的独立缓冲区
        self.daq_data = [] # 获取数据的独立缓冲区
        self.channel_amp_data = {i: [] for i in range(8)}  # 每个通道的幅度数据
        self.channel_count_data = {i: 0 for i in range(8)}  # 每个通道的计数
        self.counting_rate_data = []  # 计数率记录数据
        self.counting_rate_timer = None  # 计数率记录定时器
        self.daq_start_timestamp = None  # 采集开始时间戳
        self.is_acquiring = False
        self.acq_time = 10  # 默认记录时间
        
        # --- 设置全局字体 ---
        app_font = QFont(APP_FONT_FAMILY, APP_FONT_SIZE)
        QApplication.setFont(app_font)
        
        # --- 用户界面设置 ---
        self.setup_charts()
        self.setup_connections()
        self.refresh_ports()
        
        # --- 时钟定时器 ---
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_clock)  
        self.timer.start(1000)
        self.update_clock()
        
        # --- 图表刷新定时器 (1秒刷新一次) ---
        self.plot_timer = QTimer(self)
        self.plot_timer.timeout.connect(self.refresh_plots)
        self.plot_timer.start(1000)
        
        # --- 图表刷新标志 ---
        self.amp_plot_needs_update = False
        self.counter_plot_needs_update = False
        
        # --- 初始化默认值 ---
        self.ui.inp_acq_time.setText(str(self.acq_time))
        self.ui.inp_acq_time.editingFinished.connect(self.update_acq_time)  
        
        # --- 初始化按钮状态 ---
        self.ui.btn_single.setEnabled(False)
        self.ui.btn_start.setEnabled(False)
        self.ui.btn_stop.setEnabled(False)
        
        self.log("应用程序启动", "info")

    def update_acq_time(self):
        try:
            val = int(self.ui.inp_acq_time.text())
            self.acq_time = val
            self.log(f"采集时间设置为 {val}{self.ui.combo_time.currentText()}", "info")
        except ValueError:
            self.log("无效的采集时间", "error")
            self.ui.inp_acq_time.setText(str(self.acq_time))

    def setup_charts(self):
        self.wave_canvas = MplCanvas(self, width=8, height=5, dpi=100)
        wave_layout = QVBoxLayout(self.ui.widget_wave)
        wave_layout.addWidget(self.wave_canvas)

        self.amp_canvas = MplCanvas(self, width=4, height=3, dpi=100)
        amp_layout = QVBoxLayout(self.ui.widget_amp)
        amp_layout.addWidget(self.amp_canvas)

        self.counter_canvas = MplCanvas(self, width=4, height=3, dpi=100)
        counter_layout = QVBoxLayout(self.ui.widget_counter)
        counter_layout.addWidget(self.counter_canvas)

    def setup_connections(self):
        # 串口
        self.ui.btn_refresh.clicked.connect(self.refresh_ports)  
        self.ui.btn_connect.clicked.connect(self.toggle_serial)  
        
        # 采集
        self.ui.btn_single.clicked.connect(self.single_wave)  
        self.ui.btn_stop.clicked.connect(self.force_stop)  
        self.ui.btn_start.clicked.connect(self.start_daq)  
        #  参数
        self.ui.btn_send.clicked.connect(self.send_params)  
        self.ui.btn_fit.clicked.connect(self.fit_params)  
        
        # 文件操作
        self.ui.btn_save_wave.clicked.connect(self.save_image)
        self.ui.btn_save_data.clicked.connect(self.save_data)
        self.ui.btn_clear.clicked.connect(self.clear_display)

        # 通道切换
        self.ui.combo_ch.currentIndexChanged.connect(self.on_channel_changed)  
        
    def log(self, message, msg_type="info"):
        timestamp = datetime.now().strftime("%H:%M:%S")
        # 简单记录到 log_text
        formatted_msg = f"[{timestamp}] [{msg_type.upper()}] {message}"
        self.ui.log_text.appendPlainText(formatted_msg)
        # 自动滚动
        scrollbar = self.ui.log_text.verticalScrollBar()
        scrollbar.setValue(scrollbar.maximum())

    def update_clock(self):
        self.ui.clock_label.setText(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

    def refresh_ports(self):
        self.ui.combo_ports.clear()
        ports = [p.device for p in serial.tools.list_ports.comports()]
        if ports:
            self.ui.combo_ports.addItems(ports)
            self.log(f"发现串口设备: {', '.join(ports)}", "info")
        else:
            self.log("未发现串口设备", "warning")

    def toggle_serial(self):
        if not self.serial_inst.is_open:
            try:
                port = self.ui.combo_ports.currentText()
                baud = self.ui.combo_baud.currentText()
                if not port:
                    self.log("未选择端口", "error")
                    return
                    
                self.serial_inst.port = port
                self.serial_inst.baudrate = int(baud) if baud else 115200
                self.serial_inst.timeout = 2
                self.serial_inst.open()
                
                self.ui.btn_connect.setText("断开")
                self.ui.port_status.setText(f"连接到: {port}")
                self.log(f"连接到 {port} @ {baud}bps", "success")
                
                self.ui.statusbar.showMessage("设备已连接")
                self.ui.btn_single.setEnabled(True)
                self.ui.btn_start.setEnabled(True)
                
            except Exception as e:
                self.log(f"连接失败: {str(e)}", "error")
                QMessageBox.critical(self, "连接错误", f"无法打开端口: {str(e)}")
        else:
            if hasattr(self, 'reader') and self.reader.isRunning():
                self.reader.running = False
                self.reader.wait(1000)
            self.serial_inst.close()
            self.ui.btn_connect.setText("连接设备")
            self.ui.port_status.setText("已断开连接")
            self.log("串口已断开", "warning")
            self.ui.statusbar.showMessage("设备已断开")
            self.ui.btn_single.setEnabled(False)
            self.ui.btn_stop.setEnabled(False)
            self.ui.btn_start.setEnabled(False)

    def single_wave(self):
        """单次波形采集模式"""
        if not self.serial_inst.is_open:
            self.log("错误：串口未连接", "error")
            return

        self.wave_data = [] # 清除波形缓冲区
        self.is_acquiring = True
        cmd = f"wave_start\n"
        self.serial_inst.write(cmd.encode())
        
        self.ui.btn_start.setEnabled(False)
        self.ui.btn_single.setEnabled(False)
        self.ui.btn_stop.setEnabled(True)
        
        # 目标计数1表示一个数据包（一个波形）
        self.reader = SerialWorkThread(self.serial_inst, mode='wave', target_count=1)
        self.reader.raw_data_signal.connect(lambda x: self.log(x, "data") if "Error" in x else None)  
        self.reader.plot_data_signal.connect(self.append_wave_data)  
        self.reader.daq_done.connect(self.wave_daq_complete)  
        self.reader.start()
        
        self.log(f"开始单次波形采样", "info")
        self.ui.statusbar.showMessage(f"采集中...")

    def start_daq(self):
        """开始采集"""
        if not self.serial_inst.is_open:
            self.log("错误：串口未连接", "error")
            return
            
        self.daq_data = [] # 清除获取数据缓冲区
        self.counting_rate_data = []  # 清除计数率记录
        self.is_acquiring = True
        cmd = f"daq_start\n"
        self.serial_inst.write(cmd.encode())
        self.start_time = datetime.now()
        self.daq_start_timestamp = datetime.now()  # 记录采集开始时间戳

        self.ui.btn_start.setEnabled(False)
        self.ui.btn_single.setEnabled(False)
        self.ui.btn_stop.setEnabled(True)
        
        # 重置 LCD 计数器
        self.ui.acq_counter.display(0)
        self.ui.acq_counting_rate.display(0)
        
        # 无限目标计数 (0)
        acq_unit = self.ui.combo_time.currentText()
        try:
            acq_val = float(self.ui.inp_acq_time.text() or "0")
        except Exception:
            self.log("采集时间格式错误", "error")
            return
        seconds = acq_val * 3600 if acq_unit == "h" else acq_val * 60 if acq_unit == "min" else acq_val
        if seconds <= 0:
            self.log("采集时间必须大于 0", "error")
            return
        
        # 如果采样时间大于1分钟，启动计数率记录定时器
        if seconds >= 60:
            self.counting_rate_timer = QTimer(self)
            self.counting_rate_timer.timeout.connect(self.record_counting_rate)
            self.counting_rate_timer.start(60000)  # 每60秒触发一次
        
        self.reader = SerialWorkThread(self.serial_inst, mode='daq', target_count=0, start_time=self.start_time, acq_time=timedelta(seconds=seconds))
        self.reader.raw_data_signal.connect(lambda x: self.log(x, "data") if "Error" in x else None)  
        self.reader.plot_data_signal.connect(self.append_daq_data)  
        self.reader.daq_done.connect(self.acq_daq_complete)  
        self.reader.start()
        
        self.log(f"开始数据采集", "info")
        self.ui.statusbar.showMessage(f"采集中...")

    def append_wave_data(self, values):
        """波形数据回调"""
        self.wave_data.append(values)

    def append_daq_data(self, values):
        """获取数据回调"""
        self.daq_data.append(values)
        count = len(self.daq_data)
        self.ui.acq_counter.display(count)

        if len(values) >= 2:
            ch = int(values[0])
            amplitude = values[1]
            if 0 <= ch < 8:
                self.channel_amp_data[ch].append(amplitude)
                self.channel_count_data[ch] += 1
            # 标记图表需要更新，而不是立即更新
            self.amp_plot_needs_update = True
            self.counter_plot_needs_update = True

        if self.daq_start_timestamp:
            elapsed_seconds = (datetime.now() - self.daq_start_timestamp).total_seconds()
            if elapsed_seconds > 0:
                counting_rate = count / elapsed_seconds
                self.ui.acq_counting_rate.display(int(counting_rate))

    def record_counting_rate(self):
        """记录计数率（每分钟调用一次）"""
        if self.daq_start_timestamp and self.is_acquiring:
            elapsed_seconds = (datetime.now() - self.daq_start_timestamp).total_seconds()
            count = len(self.daq_data)
            if elapsed_seconds > 0:
                counting_rate = count / elapsed_seconds
                self.counting_rate_data.append(counting_rate)
                self.log(f"记录计数率: {int(counting_rate)} counts/s", "info")

    def wave_daq_complete(self):
        """单次波形采集完成回调"""
        self.is_acquiring = False
        
        self.ui.btn_start.setEnabled(True)
        self.ui.btn_single.setEnabled(True)
        self.ui.btn_stop.setEnabled(False)
        
        self.update_wave()
        
        self.log(f"波形采集完成", "success")
        self.ui.statusbar.showMessage(f"完成")

    def acq_daq_complete(self):
        """数据采集完成回调"""
        self.is_acquiring = False
        
        if self.counting_rate_timer:
            self.counting_rate_timer.stop()
            self.counting_rate_timer = None
        
        self.ui.btn_start.setEnabled(True)
        self.ui.btn_single.setEnabled(True)
        self.ui.btn_stop.setEnabled(False)
        
        # 强制刷新图表显示最终数据
        self.update_amp_histogram()
        self.update_counter_histogram()
        self.amp_plot_needs_update = False
        self.counter_plot_needs_update = False
        
        self.log(f"数据采集完成", "success")
        self.ui.statusbar.showMessage(f"完成")

    def force_stop(self):
        if hasattr(self, 'reader'):
            self.reader.running = False
            self.reader.wait(500)
        self.is_acquiring = False
        
        if self.counting_rate_timer:
            self.counting_rate_timer.stop()
            self.counting_rate_timer = None
        
        cmd = f"stop\n"
        self.serial_inst.write(cmd.encode())
        
        self.ui.btn_start.setEnabled(True)
        self.ui.btn_single.setEnabled(True)
        self.ui.btn_stop.setEnabled(False)
        
        self.log("用户强制停止", "warning")
        self.ui.statusbar.showMessage("已停止")

    # 更新2D画布
    def update_wave(self):
        self.wave_canvas.ax.clear()
        self.wave_canvas.setup_style()
        
        if len(self.wave_data) > 0:
            data = np.array(self.wave_data)
            # Colors
            colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
            for i in range(len(data)):  
                label = f'波形 {i+1}'
                color = colors[i % len(colors)]
                self.wave_canvas.ax.plot(data[i], linewidth=1.5, color=color, label=label, alpha=0.9)
            
            self.wave_canvas.ax.set_xlabel("采样点")
            self.wave_canvas.ax.set_ylabel("幅度")
            self.wave_canvas.ax.set_title(f"采样波形")

            # 如果波形很多，图例可能会很拥挤
            if len(data) <= 5:
                self.wave_canvas.ax.legend(loc='upper right')
            
        self.wave_canvas.draw()

    def fit_params(self):
        self.update_wave()
        if not self.wave_data:
            self.log("没有可拟合的波形", "warning")
            return
        try:
            # 取最新的波形数据
            data = np.array(self.wave_data[-1])
            
            # 基线校正
            # 假设前10个点为基线噪声
            baseline_window = min(10, len(data))
            baseline = np.mean(data[:baseline_window])
            data_corr = data - baseline
            
            # 寻找峰值
            idx_max = np.argmax(data_corr)
            val_max = data_corr[idx_max]
            
            if val_max <= 0:
                self.log("波形幅度过低，无法拟合", "error")
                return

            # 确定起始位置
            # 使用上升沿最大斜率点切线与基线交点作为起始时间
            # 计算微分
            if idx_max < 2:
                self.log("波形峰值位置过早", "error")
                return
                
            diff = np.diff(data_corr[:idx_max+1])
            if len(diff) == 0:
                self.log("无法找到上升沿", "error")
                return
                
            idx_slope = np.argmax(diff)
            max_slope = diff[idx_slope]
            
            if max_slope <= 0:
                 self.log("上升沿斜率异常", "error")
                 return
                 
            # 切线方程: y - y0 = m(x - x0) => 0 - y0 = m(x_start - x0) => x_start = x0 - y0/m
            # x0 是 idx_slope (对应 diff 的索引 i 代表 data[i] 到 data[i+1])，取 i 作为点
            t_slope = idx_slope
            y_slope = data_corr[t_slope]
            
            t_start = t_slope - y_slope / max_slope
            
            # 峰值时间 t_M (相对于 t_start)
            t_M = idx_max - t_start
            
            if t_M <= 1e-6: # 防止被零或负数除
                self.log("峰值时间计算错误 (t_M <= 0)", "error")
                return

            # 确定 tau_F (慢时间常数)
            # 选取下降沿区域，例如从峰值的 60% 下降到 10%
            # 根据经验和图片描述，选取 t > 3*tau_R 区域，即远离峰值的尾部
            
            post_peak_data = data_corr[idx_max:]
            # 选取范围: 0.6 * Vm 到 0.1 * Vm
            mask_tail = (post_peak_data < 0.6 * val_max) & (post_peak_data > 0.1 * val_max)
            tail_indices = np.where(mask_tail)[0] + idx_max
            
            if len(tail_indices) < 5:
                self.log("用于拟合的尾部数据点不足，尝试放宽范围", "warning")
                mask_tail = (post_peak_data < 0.8 * val_max) & (post_peak_data > 0.05 * val_max)
                tail_indices = np.where(mask_tail)[0] + idx_max
                if len(tail_indices) < 3:
                    self.log("拟合失败：无法提取有效尾部", "error")
                    return

            t_tail = tail_indices - t_start # 相对于 t_start 的时间
            y_tail = data_corr[tail_indices]
            
            # 线性回归 ln(V) = ln(A) - t/tau_F
            # Y = C + K * X
            # K = -1/tau_F
            
            ln_y = np.log(y_tail)
            slope, intercept = np.polyfit(t_tail, ln_y, 1)
            
            tau_F = -1.0 / slope
            # A_est = np.exp(intercept)
            
            if tau_F <= 0:
                self.log("拟合得到无效的 tau_F (<=0)", "error")
                return

            # 确定 tau_R (快时间常数)
            # 公式: t_M / tau_F = ln(k) / (k - 1)  ; k = tau_F / tau_R
            
            ratio = t_M / tau_F
            
            # 检查限制：比率必须在 (0, 1) 范围内
            if ratio >= 1 or ratio <= 0:
                self.log(f"t_M/tau_F 比值异常 ({ratio:.3f})，无法求解 tau_R", "error")
                return

            # 使用二分搜索求解 k
            # 函数: f(k) = ln(k)/(k-1) - ratio = 0
            # k = tau_F / tau_R > 1
            
            def func_val(k):
                if k == 1: return 1.0
                return np.log(k) / (k - 1.0)

            k_min = 1.0001
            k_max = 10000.0
            
            # 检查边界：如果 ratio 非常接近 1，k 接近 1；如果 ratio 非常小，k 非常大
            if func_val(k_min) < ratio: 
                 # 比率非常接近1，k接近1
                 k_sol = 1.0001 
            elif func_val(k_max) > ratio:
                 #比率很小，k很大
                 k_sol = k_max
            else:
                for _ in range(50):
                    k_mid = (k_min + k_max) / 2
                    val = func_val(k_mid)
                    if val > ratio: # 功能正在减少。值 > 比率意味着我们位于解的左侧
                        k_min = k_mid
                    else:
                        k_max = k_mid
                k_sol = (k_min + k_max) / 2
            
            tau_R = tau_F / k_sol
            
            # 更新 UI 和 Log
            self.ui.inp_tauR.setText(f"{tau_R:.2f}")
            self.ui.inp_tauF.setText(f"{tau_F:.2f}")
            
            self.log("--------------- 拟合结果 ---------------", "info")
            self.log(f"峰值 Vm: {val_max:.2f} @ index {idx_max}", "info")
            self.log(f"计算 t_start: {t_start:.2f}, t_M: {t_M:.2f}", "info")
            self.log(f"拟合 tau_F: {tau_F:.2f} (采样点)", "success")
            self.log(f"计算 tau_R: {tau_R:.2f} (采样点)", "success")
            self.log(f"比值 k: {k_sol:.2f}", "info")
            
            
            # --- 绘制拟合曲线 ---
            self.plot_fit_curve(data, baseline, t_start, tau_R, tau_F, val_max, idx_max)

        except Exception as e:
            self.log(f"拟合过程出错: {str(e)}", "error")

    def plot_fit_curve(self, data, baseline, t_start, tau_R, tau_F, val_max, idx_max):
        """绘制拟合曲线和原始数据"""
        self.wave_canvas.ax.clear()
        self.wave_canvas.setup_style()
        
        # 绘制原始数据
        self.wave_canvas.ax.plot(data, 'b-', linewidth=1.5, label='原始数据', alpha=0.8)
        
        # 生成拟合曲线
        # 双指数函数: y(t) = A * (exp(-t/tau_R) - exp(-t/tau_F))
        # 归一化: A = 1 / (exp(-t_M/tau_R) - exp(-t_M/tau_F))，其中 t_M 是峰值时间
        t_M = idx_max - t_start
        n_points = len(data)
        t = np.arange(n_points)
        
        # 相对时间（相对于 t_start）
        t_rel = t - t_start
        
        # 避免负时间值
        t_rel = np.maximum(t_rel, 0)
        
        # 计算归一化常数 A
        exp_R = np.exp(-t_M / tau_R) if tau_R > 0 else 0
        exp_F = np.exp(-t_M / tau_F) if tau_F > 0 else 0
        denom = exp_R - exp_F
        
        if abs(denom) > 1e-9:
            A = val_max / denom
            fit_curve = A * (np.exp(-t_rel / tau_R) - np.exp(-t_rel / tau_F)) + baseline
        else:
            fit_curve = np.zeros(n_points) + baseline
        
        # 绘制拟合曲线
        self.wave_canvas.ax.plot(fit_curve, 'r--', linewidth=2, label='拟合曲线', alpha=0.9)
        
        # 标记峰值位置
        self.wave_canvas.ax.axvline(x=idx_max, color='green', linestyle=':', alpha=0.7, label=f'峰值 @ {idx_max}')
        
        # 标记起始位置
        self.wave_canvas.ax.axvline(x=int(t_start), color='orange', linestyle=':', alpha=0.7, label=f'起始 @ {int(t_start)}')
        
        # 设置坐标轴标签和标题
        self.wave_canvas.ax.set_xlabel("采样点")
        self.wave_canvas.ax.set_ylabel("幅度")
        self.wave_canvas.ax.set_title("波形拟合结果")
        
        # 添加图例
        self.wave_canvas.ax.legend(loc='upper right', fontsize=9)
        
        # 刷新画布
        self.wave_canvas.draw()
        self.log("拟合曲线已绘制", "info")

        self.log("---------------------------------------", "info")

    # 发送
    def send_params(self):
        if not self.serial_inst.is_open:
            self.log("错误：串口未连接", "error")
            return
        # --- 计算寄存器值 ---
        try:
            na_text = self.ui.inp_na.text()
            nb_na_text = self.ui.inp_nb_na.text()
            tau_F_text = self.ui.inp_tauF.text()
            tau_R_text = self.ui.inp_tauR.text()
            tau_F = float(tau_F_text)
            tau_R = float(tau_R_text)
            if not na_text or not nb_na_text or not tau_F_text or not tau_R_text:
                    self.log("请填写 na 和 nb-na 以计算寄存器值", "warning")
            else:
                na = int(na_text)
                nb = int(na_text)+int(nb_na_text)
                
                a = math.exp(-1.0 / tau_F)
                b = math.exp(-1.0 / tau_R)
                
                denominator = na * (a - b)
                if abs(denominator) < 1e-9:
                        self.log("寄存器计算错误：除数为零 (na*(a-b))", "error")
                else:
                    inv_na = 1.0 / denominator
                    a_over_na = a * inv_na
                    
                    na_bits = na & 0x1FF
                    nb_bits = nb & 0x1FF
                    
                    self.reg1_value = (nb_bits << 16) | na_bits
                    self.reg2_value = int(round(a_over_na * (1 << 30)))
                    self.reg3_value = int(round(inv_na * (1 << 30)))
                    self.reg4_value = int(round(b * (1 << 30)))
                    self.reg5_value = int((0x08 << 24) | (0x0c << 16) | 0x1e)
                    
                    self.log(f"Reg1: 0x{self.reg1_value:08X}", "success")
                    self.log(f"Reg2: {self.reg2_value}", "success")
                    self.log(f"Reg3: {self.reg3_value}", "success")
                    self.log(f"Reg4: {self.reg4_value}", "success")
                    self.log(f"Reg5: 0x{self.reg5_value:08X}", "success")
        except Exception as e_reg:
            self.log(f"寄存器计算错误: {str(e_reg)}", "error")
        try:
            if(self.ui.combo_time.currentText() == "h"):
                acq_time = int(float(self.ui.inp_acq_time.text())) * 3600
            elif(self.ui.combo_time.currentText() == "min"):
                acq_time = int(float(self.ui.inp_acq_time.text())) * 60
            reg1_value = self.reg1_value
            reg2_value = self.reg2_value
            reg3_value = self.reg3_value
            reg4_value = self.reg4_value
            reg5_value = self.reg5_value
        except Exception:
            self.log("参数格式错误，无法发送", "error")
            return
        cmd = f"params,{acq_time},0x{self.reg1_value:08X},{reg2_value},{reg3_value},{reg4_value},0x{self.reg5_value:08X}\n"
        self.serial_inst.write(cmd.encode())
        self.log(f"已发送参数: {cmd.strip()}", "success")

    def save_image(self):
        if not self.wave_data and not self.channel_amp_data:
            self.log("没有可保存的数据", "warning")
            return
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        data_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")
        if not os.path.exists(data_dir):
            os.makedirs(data_dir)
        
        if self.wave_data:
            default_name = f"{timestamp}_wave.png"
            wave_path = os.path.join(data_dir, default_name)
            try:
                self.wave_canvas.fig.savefig(wave_path, dpi=300, bbox_inches='tight')
                self.log(f"波形图已保存: {wave_path}", "success")
            except Exception as e:
                self.log(f"保存波形图失败: {str(e)}", "error")
        
        channel = self.ui.combo_ch.currentIndex()
        amp_data = self.channel_amp_data.get(channel, [])
        
        if len(amp_data) > 0:
            default_name = f"{timestamp}_amplitude_spectrum_ch{channel+1}.png"
            amp_path = os.path.join(data_dir, default_name)
            try:
                self.amp_canvas.fig.savefig(amp_path, dpi=300, bbox_inches='tight')
                self.log(f"幅度谱图已保存: {amp_path}", "success")
            except Exception as e:
                self.log(f"保存幅度谱图失败: {str(e)}", "error")
        
        if self.channel_count_data and any(v > 0 for v in self.channel_count_data.values()):
            default_name = f"{timestamp}_channel_consistency.png"
            counter_path = os.path.join(data_dir, default_name)
            try:
                self.counter_canvas.fig.savefig(counter_path, dpi=300, bbox_inches='tight')
                self.log(f"多通道一致性谱图已保存: {counter_path}", "success")
            except Exception as e:
                self.log(f"保存多通道一致性谱图失败: {str(e)}", "error")
                
    def save_data(self):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        data_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")
        if not os.path.exists(data_dir):
            os.makedirs(data_dir)
        
        if self.wave_data:
            wave_data = np.array(self.wave_data)
            
            default_name = f"{timestamp}_wave.npy"
            wave_path = os.path.join(data_dir, default_name)
            try:
                if wave_path.endswith('.npy'):
                    np.save(wave_path, wave_data)
                else:
                    np.savetxt(wave_path, wave_data, delimiter=",", comments="")
                self.log(f"波形数据已保存: {wave_path}", "success")
            except Exception as e:
                self.log(f"保存波形数据失败: {str(e)}", "error")
        
        if self.channel_amp_data:
            all_amp_data = []
            for ch in range(8):
                ch_data = self.channel_amp_data.get(ch, [])
                all_amp_data.append(ch_data)
            
            if any(len(d) > 0 for d in all_amp_data):
                default_name = f"{timestamp}_amplitude_spectrum.npy"
                amp_path = os.path.join(data_dir, default_name)
                try:
                    amp_data_arr = np.array(all_amp_data, dtype=object)
                    if amp_path.endswith('.npy'):
                        np.save(amp_path, amp_data_arr)
                    else:
                        np.savetxt(amp_path, amp_data_arr, delimiter=",", comments="")
                    self.log(f"幅度谱数据已保存: {amp_path}", "success")
                except Exception as e:
                    self.log(f"保存幅度谱数据失败: {str(e)}", "error")
        
        if self.counting_rate_data:
            counting_rate_arr = np.array(self.counting_rate_data)
            default_name = f"{timestamp}_counting_rate.npy"
            rate_path = os.path.join(data_dir, default_name)
            try:
                if rate_path.endswith('.npy'):
                    np.save(rate_path, counting_rate_arr)
                else:
                    np.savetxt(rate_path, counting_rate_arr, delimiter=",", comments="")
                self.log(f"计数率数据已保存: {rate_path}", "success")
            except Exception as e:
                self.log(f"保存计数率数据失败: {str(e)}", "error")
        
        if self.channel_count_data and any(v > 0 for v in self.channel_count_data.values()):
            default_name = f"{timestamp}_channel_consistency.npy"
            consistency_path = os.path.join(data_dir, default_name)
            try:
                consistency_arr = np.array([self.channel_count_data.get(ch, 0) for ch in range(8)])
                if consistency_path.endswith('.npy'):
                    np.save(consistency_path, consistency_arr)
                else:
                    np.savetxt(consistency_path, consistency_arr, delimiter=",", comments="")
                self.log(f"多通道一致性谱数据已保存: {consistency_path}", "success")
            except Exception as e:
                self.log(f"保存多通道一致性谱数据失败: {str(e)}", "error")
        
        if self.daq_data:
            daq_arr = np.array(self.daq_data)
            default_name = f"{timestamp}_daq_wave.npy"
            daq_path = os.path.join(data_dir, default_name)
            try:
                if daq_path.endswith('.npy'):
                    np.save(daq_path, daq_arr)
                else:
                    np.savetxt(daq_path, daq_arr, delimiter=",", comments="")
                self.log(f"采样波形谱数据已保存: {daq_path}", "success")
            except Exception as e:
                self.log(f"保存采样波形谱数据失败: {str(e)}", "error")
        
        if not self.wave_data and not self.channel_amp_data and not self.counting_rate_data and not self.channel_count_data and not self.daq_data:
            self.log("没有可保存的数据", "warning")
                
    def clear_display(self):
        self.wave_data = []
        self.daq_data = []
        self.channel_amp_data = {i: [] for i in range(8)}
        self.channel_count_data = {i: 0 for i in range(8)}
        self.counting_rate_data = []
        self.daq_start_timestamp = None

        self.wave_canvas.ax.clear()
        self.wave_canvas.setup_style()
        self.wave_canvas.draw()

        self.amp_canvas.ax.clear()
        self.amp_canvas.setup_style()
        self.amp_canvas.draw()

        self.counter_canvas.ax.clear()
        self.counter_canvas.setup_style()
        self.counter_canvas.draw()

        self.ui.acq_counter.display(0)
        self.ui.acq_counting_rate.display(0)
        self.log("显示已清除", "info")

    def refresh_plots(self):
        """定时刷新图表 (1秒一次)"""
        if self.amp_plot_needs_update:
            self.update_amp_histogram()
            self.amp_plot_needs_update = False
        if self.counter_plot_needs_update:
            self.update_counter_histogram()
            self.counter_plot_needs_update = False

    def on_channel_changed(self):
        """通道切换时刷新幅度谱"""
        self.update_amp_histogram()

    def update_amp_histogram(self):
        """更新当前通道的幅度谱直方图"""
        channel = self.ui.combo_ch.currentIndex()
        amp_data = self.channel_amp_data.get(channel, [])

        self.amp_canvas.ax.clear()
        self.amp_canvas.setup_style()

        if len(amp_data) > 0:
            bins = 50
            self.amp_canvas.ax.hist(amp_data, bins=bins, color='#1f77b4', alpha=0.7, edgecolor='black')
            self.amp_canvas.ax.set_xlabel("幅度")
            self.amp_canvas.ax.set_ylabel("计数")
            self.amp_canvas.ax.set_title(f"通道{channel+1} 幅度谱")
        else:
            self.amp_canvas.ax.text(0.5, 0.5, "无数据", ha='center', va='center', transform=self.amp_canvas.ax.transAxes)
            self.amp_canvas.ax.set_title(f"通道{channel+1} 幅度谱")

        self.amp_canvas.draw()

    def update_counter_histogram(self):
        """更新多通道一致性谱直方图"""
        self.counter_canvas.ax.clear()
        self.counter_canvas.setup_style()

        has_data = False
        for ch in range(8):
            count = self.channel_count_data.get(ch, 0)
            if count > 0:
                has_data = True
                self.counter_canvas.ax.bar(ch, count, color='#1f77b4', alpha=0.7, edgecolor='black')

        if has_data:
            self.counter_canvas.ax.set_xlabel("通道")
            self.counter_canvas.ax.set_ylabel("计数")
            self.counter_canvas.ax.set_xticks(range(8))
            self.counter_canvas.ax.set_xticklabels([f"Ch{i+1}" for i in range(8)])
            self.counter_canvas.ax.set_title("多通道一致性谱")
        else:
            self.counter_canvas.ax.text(0.5, 0.5, "无数据", ha='center', va='center', transform=self.counter_canvas.ax.transAxes)
            self.counter_canvas.ax.set_title("多通道一致性谱")

        self.counter_canvas.draw()


    def closeEvent(self, event):
        if self.serial_inst.is_open:
            if hasattr(self, 'reader') and self.reader.isRunning():
                self.reader.running = False
                self.reader.wait(1000)
            self.serial_inst.close()
        event.accept()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    widget = MainWindow()
    widget.show()
    sys.exit(app.exec_())
