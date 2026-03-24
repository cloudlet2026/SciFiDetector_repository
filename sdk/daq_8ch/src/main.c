#include "xil_printf.h"
#include "xscugic.h"
#include "xuartps.h"
#include "sleep.h"
#include "xscutimer.h"
#include "daq_axi_lite.h"
#include "axi_lite_ctrl.h"
#include "xparameters.h"
#include "xil_io.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <math.h>
#include <string.h>

#define AXI_LITE_BASE         XPAR_AXI_LITE_CTRL_0_S00_AXI_BASEADDR
#define DAQ_AXI_LITE_BASE     XPAR_DAQ_AXI_LITE_0_S00_AXI_BASEADDR
#define WAVE_BRAM_BASE        XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR

#define SLV_REG0_OFFSET       AXI_LITE_CTRL_S00_AXI_SLV_REG0_OFFSET
#define SLV_REG1_OFFSET       AXI_LITE_CTRL_S00_AXI_SLV_REG1_OFFSET
#define SLV_REG2_OFFSET       AXI_LITE_CTRL_S00_AXI_SLV_REG2_OFFSET
#define SLV_REG3_OFFSET       AXI_LITE_CTRL_S00_AXI_SLV_REG3_OFFSET
#define SLV_REG4_OFFSET       AXI_LITE_CTRL_S00_AXI_SLV_REG4_OFFSET
#define SLV_REG5_OFFSET       AXI_LITE_CTRL_S00_AXI_SLV_REG5_OFFSET

#define DAQ_REG0_OFFSET       DAQ_AXI_LITE_S00_AXI_SLV_REG0_OFFSET
#define DAQ_REG1_OFFSET       DAQ_AXI_LITE_S00_AXI_SLV_REG1_OFFSET
#define DAQ_REG2_OFFSET       DAQ_AXI_LITE_S00_AXI_SLV_REG2_OFFSET

#define INTC_DEVICE_ID        XPAR_SCUGIC_SINGLE_DEVICE_ID
#define DAQ_INTR_ID           XPAR_FABRIC_DAQ_AXI_LITE_0_DAQ_INTR_INTR
#define BRAM_INTR_ID          XPAR_FABRIC_WAVE_BRAM_CTRL_0_WAVE_INTR_INTR
#define UART_DEVICE_ID        XPAR_XUARTPS_0_DEVICE_ID
#define UART_BASEADDR         XPAR_XUARTPS_0_BASEADDR

// 定时器
#define TMRCTR_DEVICE_ID      XPAR_XSCUTIMER_0_DEVICE_ID
#define TIMER_LOAD_VALUE      (XPAR_PS7_CORTEXA9_0_CPU_CLK_FREQ_HZ/2 -1) // 1秒
XScuTimer TimerInstance;

// 全局设置
typedef struct {
    int time;         // 采集时间(秒)
    uint32_t reg1;
    uint32_t reg2;
    uint32_t reg3;
    uint32_t reg4;
    uint32_t reg5;
} SystemConfig;

SystemConfig sysConfig = {10, 0, 0, 0, 0, 0}; // 默认值

// 外设
XScuGic INTCInst;
XUartPs UartInstance;

// 缓冲区
#define CMD_BUFFER_SIZE 256
static char rx_buffer[CMD_BUFFER_SIZE];
static int rx_index = 0;

// 标志位
volatile int Daq_Intr_Flag = 0;
volatile int Bram_Intr_Flag = 0;
volatile int TimerExpired = 0;
volatile int AppMode = 0; // 0: Idle, 1: 采集 , 2: 波形

// 函数声明
int IntrInitFuntion(u16 DeviceId);
void DaqIntrHandler(void *InstancePtr);
void BramIntrHandler(void *InstancePtr);
int UartInit(u16 DeviceId);
int TimerInit(XScuTimer * TimerInstancePtr, u16 TimerDeviceId);
void Execute_Command(char *cmd_line);
void Uart_Parse_Byte(char c);
void Send_Wave_Data();
void Send_Daq_Data();

int main() {
    int Status;
    u8 RecvBuffer[1];
    int BytesReceived;

    // 初始化中断控制器
    Status = IntrInitFuntion(INTC_DEVICE_ID);
    if (Status != XST_SUCCESS) {
        xil_printf("中断控制器初始化失败\r\n");
        return XST_FAILURE;
    }

    // 初始化串口
    Status = UartInit(UART_DEVICE_ID);
    if (Status != XST_SUCCESS) {
        xil_printf("串口初始化失败\r\n");
        return XST_FAILURE;
    }

    // 初始化定时器
    Status = TimerInit(&TimerInstance, TMRCTR_DEVICE_ID);
    if (Status != XST_SUCCESS) {
        xil_printf("定时器初始化失败\r\n");
        return XST_FAILURE;
    }

    // 清除 UART FIFO
    XUartPs_ReadReg(UART_BASEADDR, XUARTPS_FIFO_OFFSET);

    xil_printf("系统就绪。等待指令...\r\n");

    while (1) {
        // 处理串口输入
        BytesReceived = XUartPs_Recv(&UartInstance, RecvBuffer, 1);
        if (BytesReceived > 0) {
            Uart_Parse_Byte((char)RecvBuffer[0]);
        }

        // 处理定时器倒计时（自动停止）
        if (XScuTimer_IsExpired(&TimerInstance)) {
            XScuTimer_ClearInterruptStatus(&TimerInstance);
            TimerExpired++;
            if (AppMode == 1 && TimerExpired >= sysConfig.time) {
                // 采集时间结束
                xil_printf("采集时间结束\r\n");
                // 停止硬件
                AXI_LITE_CTRL_mWriteReg(AXI_LITE_BASE, SLV_REG0_OFFSET, 0x00);
                XScuTimer_Stop(&TimerInstance);
                AppMode = 0;
            }
        }

        // 处理数据采集中断
        if (Daq_Intr_Flag) {
            Daq_Intr_Flag = 0;
            // 清除中断标志位（设置位8 -> 0x101）
            AXI_LITE_CTRL_mWriteReg(AXI_LITE_BASE, SLV_REG0_OFFSET, 0x101);

            if (AppMode == 1) {
                Send_Daq_Data();
            }
        }

        // 处理波形中断
        if (Bram_Intr_Flag) {
            Bram_Intr_Flag = 0;

            if (AppMode == 2) {
                Send_Wave_Data();
                // 清除中断标志位（设置位16 -> 0x10001）
                AXI_LITE_CTRL_mWriteReg(AXI_LITE_BASE, SLV_REG0_OFFSET, 0x10001);
                AppMode = 0;
                xil_printf("波形采集完成\r\n");
            }
        }
    }

    return XST_SUCCESS;
}

void Execute_Command(char *cmd_line) {
    char *token;
    char *saveptr;
    const char *delim_comma = ",";

    // 获取命令类型
    token = strtok_r(cmd_line, delim_comma, &saveptr);
    if (token == NULL) return;

    if (strcmp(token, "wave_start") == 0) {
        // ---波形模式 ---

        // 停止任何正在运行的进程
        AXI_LITE_CTRL_mWriteReg(AXI_LITE_BASE, SLV_REG0_OFFSET, 0x00);
        XScuTimer_Stop(&TimerInstance);

        AppMode = 2; // 波形模式
        Bram_Intr_Flag = 0; // 清除旧标志位

        // 开始波形采集（位 0、12 -> 0x1001）
        AXI_LITE_CTRL_mWriteReg(AXI_LITE_BASE, SLV_REG0_OFFSET, 0x1001);

    } else if (strcmp(token, "daq_start") == 0) {
        // --- 采集模式 ---

        // 停止之前的采集
        AXI_LITE_CTRL_mWriteReg(AXI_LITE_BASE, SLV_REG0_OFFSET, 0x00);

        // 设置模式
        AppMode = 1;
        TimerExpired = 0;
        Daq_Intr_Flag = 0;

        // 启动定时器
        XScuTimer_EnableAutoReload(&TimerInstance);
        XScuTimer_LoadTimer(&TimerInstance, TIMER_LOAD_VALUE);
        XScuTimer_Start(&TimerInstance);

        // 启用采集（位 0、4 -> 0x11）
        AXI_LITE_CTRL_mWriteReg(AXI_LITE_BASE, SLV_REG0_OFFSET, 0x11);

    } else if (strcmp(token, "params") == 0) {
        // --- 配置参数 ---
        // 格式：params,time,reg1,reg2,reg3,reg4,reg5

        char *arg_str = saveptr; // 字符串的剩余部分
        if (arg_str == NULL || *arg_str == '\0') return;

        // 解析时间
        token = strtok(arg_str, delim_comma);
        if (token) sysConfig.time = atoi(token);

        // 解析 Reg1
        token = strtok(NULL, delim_comma);
        if (token) sysConfig.reg1 = (uint32_t)strtoul(token, NULL, 0);

        // 解析 Reg2
        token = strtok(NULL, delim_comma);
        if (token) sysConfig.reg2 = (uint32_t)strtoul(token, NULL, 0);

        // 解析 Reg3
        token = strtok(NULL, delim_comma);
        if (token) sysConfig.reg3 = (uint32_t)strtoul(token, NULL, 0);

        // 解析 Reg4
        token = strtok(NULL, delim_comma);
        if (token) sysConfig.reg4 = (uint32_t)strtoul(token, NULL, 0);

        // 解析 Reg5
        token = strtok(NULL, delim_comma);
        if (token) sysConfig.reg5 = (uint32_t)strtoul(token, NULL, 0);

        // 写寄存器
        AXI_LITE_CTRL_mWriteReg(AXI_LITE_BASE, SLV_REG1_OFFSET, sysConfig.reg1);
        AXI_LITE_CTRL_mWriteReg(AXI_LITE_BASE, SLV_REG2_OFFSET, sysConfig.reg2);
        AXI_LITE_CTRL_mWriteReg(AXI_LITE_BASE, SLV_REG3_OFFSET, sysConfig.reg3);
        AXI_LITE_CTRL_mWriteReg(AXI_LITE_BASE, SLV_REG4_OFFSET, sysConfig.reg4);
        AXI_LITE_CTRL_mWriteReg(AXI_LITE_BASE, SLV_REG5_OFFSET, sysConfig.reg5);

        xil_printf("参数已更新: T=%d, R1=0x%X, R2=%d, R3=%d, R4=%d, R5=0x%X\r\n",
            sysConfig.time, sysConfig.reg1, sysConfig.reg2, sysConfig.reg3, sysConfig.reg4, sysConfig.reg5);

    } else if (strcmp(token, "stop") == 0) {
        // --- 停止 ---
        AXI_LITE_CTRL_mWriteReg(AXI_LITE_BASE, SLV_REG0_OFFSET, 0x00);
        XScuTimer_Stop(&TimerInstance);
        AppMode = 0;

    }  else {
        xil_printf("未知指令: %s\r\n", token);
    }
}

void Send_Wave_Data() {
    // 从 BRAM 读取波形数据并发送
    int i;
    u32 data;
    xil_printf("wave_ack,");
    for (i = 0; i < 60; i++) {
        data = Xil_In32(WAVE_BRAM_BASE + i*4);
        xil_printf("%d,", (int)data);
    }
    xil_printf("\n"); // 数据包结束
}

void Send_Daq_Data() {
    // 从 DAQ_AXI_LITE 读取寄存器
    int32_t X_Amp = (int32_t)DAQ_AXI_LITE_mReadReg(DAQ_AXI_LITE_BASE, DAQ_REG0_OFFSET);
    int32_t X_ch = (int32_t)DAQ_AXI_LITE_mReadReg(DAQ_AXI_LITE_BASE, DAQ_REG1_OFFSET);
    printf("daq_ack,%ld,%ld\n", (long)X_ch, (long)X_Amp);
}

void Uart_Parse_Byte(char c) {
    if (c == '\r') return; //忽略CR
    if (c == '\n') {
        if (rx_index > 0) {
            rx_buffer[rx_index] = '\0';
            Execute_Command(rx_buffer);
            rx_index = 0;
        }
    } else {
        if (rx_index < CMD_BUFFER_SIZE - 1) {
            rx_buffer[rx_index++] = c;
        } else {
            rx_index = 0; // 溢出复位
        }
    }
}

// ================= 初始化函数 =================

int IntrInitFuntion(u16 DeviceId) {
    XScuGic_Config *IntcConfig;
    int Status;
    IntcConfig = XScuGic_LookupConfig(DeviceId);
    Status = XScuGic_CfgInitialize(&INTCInst, IntcConfig, IntcConfig->CpuBaseAddress);
    if (Status != XST_SUCCESS) return XST_FAILURE;

    // 配置 DAQ 中断 (61)
    XScuGic_SetPriorityTriggerType(&INTCInst, DAQ_INTR_ID, 0xA0, 0x3); // 0x3 = 上升沿
    Status = XScuGic_Connect(&INTCInst, DAQ_INTR_ID, (Xil_ExceptionHandler)DaqIntrHandler, (void *)NULL);
    if (Status != XST_SUCCESS) return XST_FAILURE;
    XScuGic_Enable(&INTCInst, DAQ_INTR_ID);

    // 配置 BRAM 中断 (62)
    XScuGic_SetPriorityTriggerType(&INTCInst, BRAM_INTR_ID, 0xA0, 0x3); // 0x3 = 上升沿
    Status = XScuGic_Connect(&INTCInst, BRAM_INTR_ID, (Xil_ExceptionHandler)BramIntrHandler, (void *)NULL);
    if (Status != XST_SUCCESS) return XST_FAILURE;
    XScuGic_Enable(&INTCInst, BRAM_INTR_ID);

    // 启用异常处理
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, &INTCInst);
    Xil_ExceptionEnable();

    return XST_SUCCESS;
}

// ================= 中断处理函数 =================

void DaqIntrHandler(void *CallbackRef) {
    Daq_Intr_Flag = 1;
}

void BramIntrHandler(void *CallbackRef) {
    Bram_Intr_Flag = 1;
}

int UartInit(u16 DeviceId) {
    XUartPs_Config *Config;
    int Status;
    Config = XUartPs_LookupConfig(DeviceId);
    Status = XUartPs_CfgInitialize(&UartInstance, Config, Config->BaseAddress);
    if (Status != XST_SUCCESS) return XST_FAILURE;
    xil_printf("UART InputClockHz = %d Hz\r\n", UartInstance.Config.InputClockHz);
    XUartPs_SetBaudRate(&UartInstance, 460800);
    XUartPs_SetFifoThreshold(&UartInstance, 1);
    XUartPs_SetOperMode(&UartInstance, XUARTPS_OPER_MODE_NORMAL);

    return XST_SUCCESS;
}

int TimerInit(XScuTimer * TimerInstancePtr, u16 TimerDeviceId) {
    int Status;
    XScuTimer_Config *ConfigPtr;
    ConfigPtr = XScuTimer_LookupConfig(TimerDeviceId);
    Status = XScuTimer_CfgInitialize(TimerInstancePtr, ConfigPtr, ConfigPtr->BaseAddr);
    if (Status != XST_SUCCESS) return XST_FAILURE;
    Status = XScuTimer_SelfTest(TimerInstancePtr);
    if (Status != XST_SUCCESS) return XST_FAILURE;
    XScuTimer_EnableAutoReload(TimerInstancePtr);
    XScuTimer_LoadTimer(TimerInstancePtr, TIMER_LOAD_VALUE);
    return XST_SUCCESS;
}
