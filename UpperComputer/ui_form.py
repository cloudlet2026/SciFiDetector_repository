# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'form.ui'
##
## Created by: Qt User Interface Compiler version 5.15.2
##
## WARNING! All changes made in this file will be lost when recompiling UI file!
################################################################################

from PySide2.QtCore import *
from PySide2.QtGui import *
from PySide2.QtWidgets import *


class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        if not MainWindow.objectName():
            MainWindow.setObjectName(u"MainWindow")
        MainWindow.resize(1200, 880)
        MainWindow.setMinimumSize(QSize(1200, 880))
        self.centralwidget = QWidget(MainWindow)
        self.centralwidget.setObjectName(u"centralwidget")
        self.gridLayout_5 = QGridLayout(self.centralwidget)
        self.gridLayout_5.setObjectName(u"gridLayout_5")
        self.widget_left = QWidget(self.centralwidget)
        self.widget_left.setObjectName(u"widget_left")
        sizePolicy = QSizePolicy(QSizePolicy.Preferred, QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.widget_left.sizePolicy().hasHeightForWidth())
        self.widget_left.setSizePolicy(sizePolicy)
        self.widget_left.setMinimumSize(QSize(0, 0))
        self.widget_left.setMaximumSize(QSize(240, 16777215))
        self.gridLayout_3 = QGridLayout(self.widget_left)
        self.gridLayout_3.setObjectName(u"gridLayout_3")
        self.sample_card = QGroupBox(self.widget_left)
        self.sample_card.setObjectName(u"sample_card")
        sizePolicy1 = QSizePolicy(QSizePolicy.Preferred, QSizePolicy.Fixed)
        sizePolicy1.setHorizontalStretch(0)
        sizePolicy1.setVerticalStretch(0)
        sizePolicy1.setHeightForWidth(self.sample_card.sizePolicy().hasHeightForWidth())
        self.sample_card.setSizePolicy(sizePolicy1)
        font = QFont()
        font.setBold(False)
        self.sample_card.setFont(font)
        self.sample_card.setAlignment(Qt.AlignLeading|Qt.AlignLeft|Qt.AlignVCenter)
        self.sample_card.setFlat(False)
        self.sample_card.setCheckable(False)
        self.gridLayout = QGridLayout(self.sample_card)
        self.gridLayout.setObjectName(u"gridLayout")
        self.lbl_port = QLabel(self.sample_card)
        self.lbl_port.setObjectName(u"lbl_port")
        sizePolicy.setHeightForWidth(self.lbl_port.sizePolicy().hasHeightForWidth())
        self.lbl_port.setSizePolicy(sizePolicy)
        self.lbl_port.setMaximumSize(QSize(16777215, 16777215))

        self.gridLayout.addWidget(self.lbl_port, 0, 0, 1, 1)

        self.horizontalLayout_2 = QHBoxLayout()
        self.horizontalLayout_2.setObjectName(u"horizontalLayout_2")
        self.combo_ports = QComboBox(self.sample_card)
        self.combo_ports.setObjectName(u"combo_ports")
        sizePolicy1.setHeightForWidth(self.combo_ports.sizePolicy().hasHeightForWidth())
        self.combo_ports.setSizePolicy(sizePolicy1)
        self.combo_ports.setMaximumSize(QSize(16777215, 16777215))

        self.horizontalLayout_2.addWidget(self.combo_ports)

        self.btn_refresh = QToolButton(self.sample_card)
        self.btn_refresh.setObjectName(u"btn_refresh")
        sizePolicy.setHeightForWidth(self.btn_refresh.sizePolicy().hasHeightForWidth())
        self.btn_refresh.setSizePolicy(sizePolicy)
        self.btn_refresh.setMinimumSize(QSize(28, 28))
        self.btn_refresh.setMaximumSize(QSize(28, 28))

        self.horizontalLayout_2.addWidget(self.btn_refresh, 0, Qt.AlignHCenter|Qt.AlignVCenter)


        self.gridLayout.addLayout(self.horizontalLayout_2, 0, 1, 1, 1)

        self.lbl_baud = QLabel(self.sample_card)
        self.lbl_baud.setObjectName(u"lbl_baud")
        sizePolicy.setHeightForWidth(self.lbl_baud.sizePolicy().hasHeightForWidth())
        self.lbl_baud.setSizePolicy(sizePolicy)
        self.lbl_baud.setMaximumSize(QSize(16777215, 16777215))

        self.gridLayout.addWidget(self.lbl_baud, 1, 0, 1, 1)

        self.combo_baud = QComboBox(self.sample_card)
        self.combo_baud.addItem("")
        self.combo_baud.addItem("")
        self.combo_baud.addItem("")
        self.combo_baud.addItem("")
        self.combo_baud.addItem("")
        self.combo_baud.addItem("")
        self.combo_baud.addItem("")
        self.combo_baud.addItem("")
        self.combo_baud.addItem("")
        self.combo_baud.addItem("")
        self.combo_baud.addItem("")
        self.combo_baud.setObjectName(u"combo_baud")
        sizePolicy2 = QSizePolicy(QSizePolicy.Preferred, QSizePolicy.Fixed)
        sizePolicy2.setHorizontalStretch(1)
        sizePolicy2.setVerticalStretch(0)
        sizePolicy2.setHeightForWidth(self.combo_baud.sizePolicy().hasHeightForWidth())
        self.combo_baud.setSizePolicy(sizePolicy2)
        self.combo_baud.setMaximumSize(QSize(16777215, 16777215))

        self.gridLayout.addWidget(self.combo_baud, 1, 1, 1, 1)

        self.btn_connect = QPushButton(self.sample_card)
        self.btn_connect.setObjectName(u"btn_connect")
        sizePolicy1.setHeightForWidth(self.btn_connect.sizePolicy().hasHeightForWidth())
        self.btn_connect.setSizePolicy(sizePolicy1)

        self.gridLayout.addWidget(self.btn_connect, 2, 0, 1, 2)


        self.gridLayout_3.addWidget(self.sample_card, 0, 0, 1, 2)

        self.param_card = QGroupBox(self.widget_left)
        self.param_card.setObjectName(u"param_card")
        sizePolicy1.setHeightForWidth(self.param_card.sizePolicy().hasHeightForWidth())
        self.param_card.setSizePolicy(sizePolicy1)
        self.param_card.setMinimumSize(QSize(0, 278))
        self.gridLayout_2 = QGridLayout(self.param_card)
        self.gridLayout_2.setObjectName(u"gridLayout_2")
        self.btn_send = QPushButton(self.param_card)
        self.btn_send.setObjectName(u"btn_send")

        self.gridLayout_2.addWidget(self.btn_send, 8, 0, 1, 2)

        self.inp_nb_na = QLineEdit(self.param_card)
        self.inp_nb_na.setObjectName(u"inp_nb_na")
        self.inp_nb_na.setMaximumSize(QSize(100, 16777215))

        self.gridLayout_2.addWidget(self.inp_nb_na, 1, 1, 1, 1)

        self.lbl_tauR = QLabel(self.param_card)
        self.lbl_tauR.setObjectName(u"lbl_tauR")

        self.gridLayout_2.addWidget(self.lbl_tauR, 3, 0, 1, 1)

        self.lbl_tauF = QLabel(self.param_card)
        self.lbl_tauF.setObjectName(u"lbl_tauF")

        self.gridLayout_2.addWidget(self.lbl_tauF, 4, 0, 1, 1)

        self.lbl_na = QLabel(self.param_card)
        self.lbl_na.setObjectName(u"lbl_na")

        self.gridLayout_2.addWidget(self.lbl_na, 0, 0, 1, 1)

        self.inp_na = QLineEdit(self.param_card)
        self.inp_na.setObjectName(u"inp_na")
        self.inp_na.setMaximumSize(QSize(100, 16777215))

        self.gridLayout_2.addWidget(self.inp_na, 0, 1, 1, 1)

        self.inp_tauR = QLineEdit(self.param_card)
        self.inp_tauR.setObjectName(u"inp_tauR")
        self.inp_tauR.setMaximumSize(QSize(100, 16777215))

        self.gridLayout_2.addWidget(self.inp_tauR, 3, 1, 1, 1)

        self.inp_tauF = QLineEdit(self.param_card)
        self.inp_tauF.setObjectName(u"inp_tauF")
        self.inp_tauF.setMaximumSize(QSize(100, 16777215))

        self.gridLayout_2.addWidget(self.inp_tauF, 4, 1, 1, 1)

        self.lbl_nb_ba = QLabel(self.param_card)
        self.lbl_nb_ba.setObjectName(u"lbl_nb_ba")

        self.gridLayout_2.addWidget(self.lbl_nb_ba, 1, 0, 1, 1)

        self.btn_fit = QPushButton(self.param_card)
        self.btn_fit.setObjectName(u"btn_fit")

        self.gridLayout_2.addWidget(self.btn_fit, 2, 0, 1, 2)


        self.gridLayout_3.addWidget(self.param_card, 3, 0, 1, 2)

        self.acq_card = QGroupBox(self.widget_left)
        self.acq_card.setObjectName(u"acq_card")
        sizePolicy1.setHeightForWidth(self.acq_card.sizePolicy().hasHeightForWidth())
        self.acq_card.setSizePolicy(sizePolicy1)
        self.gridLayout_7 = QGridLayout(self.acq_card)
        self.gridLayout_7.setObjectName(u"gridLayout_7")
        self.btn_single = QPushButton(self.acq_card)
        self.btn_single.setObjectName(u"btn_single")
        self.btn_single.setCheckable(False)
        self.btn_single.setAutoRepeat(False)
        self.btn_single.setAutoExclusive(False)
        self.btn_single.setAutoDefault(False)
        self.btn_single.setFlat(False)

        self.gridLayout_7.addWidget(self.btn_single, 2, 0, 1, 2)

        self.horizontalLayout_1 = QHBoxLayout()
        self.horizontalLayout_1.setObjectName(u"horizontalLayout_1")
        self.btn_start = QPushButton(self.acq_card)
        self.btn_start.setObjectName(u"btn_start")
        sizePolicy3 = QSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed)
        sizePolicy3.setHorizontalStretch(0)
        sizePolicy3.setVerticalStretch(0)
        sizePolicy3.setHeightForWidth(self.btn_start.sizePolicy().hasHeightForWidth())
        self.btn_start.setSizePolicy(sizePolicy3)

        self.horizontalLayout_1.addWidget(self.btn_start)

        self.btn_stop = QPushButton(self.acq_card)
        self.btn_stop.setObjectName(u"btn_stop")
        sizePolicy3.setHeightForWidth(self.btn_stop.sizePolicy().hasHeightForWidth())
        self.btn_stop.setSizePolicy(sizePolicy3)

        self.horizontalLayout_1.addWidget(self.btn_stop)


        self.gridLayout_7.addLayout(self.horizontalLayout_1, 1, 0, 1, 2)

        self.inp_acq_time = QLineEdit(self.acq_card)
        self.inp_acq_time.setObjectName(u"inp_acq_time")
        sizePolicy3.setHeightForWidth(self.inp_acq_time.sizePolicy().hasHeightForWidth())
        self.inp_acq_time.setSizePolicy(sizePolicy3)
        self.inp_acq_time.setMaximumSize(QSize(130, 16777215))

        self.gridLayout_7.addWidget(self.inp_acq_time, 0, 0, 1, 1)

        self.combo_time = QComboBox(self.acq_card)
        self.combo_time.addItem("")
        self.combo_time.addItem("")
        self.combo_time.setObjectName(u"combo_time")
        sizePolicy3.setHeightForWidth(self.combo_time.sizePolicy().hasHeightForWidth())
        self.combo_time.setSizePolicy(sizePolicy3)
        self.combo_time.setMaximumSize(QSize(60, 16777215))

        self.gridLayout_7.addWidget(self.combo_time, 0, 1, 1, 1)


        self.gridLayout_3.addWidget(self.acq_card, 2, 0, 1, 2)


        self.gridLayout_5.addWidget(self.widget_left, 0, 0, 2, 1)

        self.clock_label = QLabel(self.centralwidget)
        self.clock_label.setObjectName(u"clock_label")
        self.clock_label.setMaximumSize(QSize(16777215, 21))
        self.clock_label.setAlignment(Qt.AlignCenter)

        self.gridLayout_5.addWidget(self.clock_label, 0, 1, 1, 1)

        self.widget_plot = QWidget(self.centralwidget)
        self.widget_plot.setObjectName(u"widget_plot")
        sizePolicy.setHeightForWidth(self.widget_plot.sizePolicy().hasHeightForWidth())
        self.widget_plot.setSizePolicy(sizePolicy)
        self.widget_plot.setMinimumSize(QSize(0, 370))
        self.gridLayout_4 = QGridLayout(self.widget_plot)
        self.gridLayout_4.setObjectName(u"gridLayout_4")
        self.splitter_2 = QSplitter(self.widget_plot)
        self.splitter_2.setObjectName(u"splitter_2")
        self.splitter_2.setOrientation(Qt.Vertical)
        self.widget = QWidget(self.splitter_2)
        self.widget.setObjectName(u"widget")
        self.verticalLayout_4 = QVBoxLayout(self.widget)
        self.verticalLayout_4.setObjectName(u"verticalLayout_4")
        self.verticalLayout_4.setContentsMargins(0, 0, 0, 0)
        self.widget_wave = QWidget(self.widget)
        self.widget_wave.setObjectName(u"widget_wave")
        self.widget_wave.setMinimumSize(QSize(0, 230))
        self.widget_wave.setMaximumSize(QSize(16777215, 320))

        self.verticalLayout_4.addWidget(self.widget_wave)

        self.lbl_sample_title = QLabel(self.widget)
        self.lbl_sample_title.setObjectName(u"lbl_sample_title")
        self.lbl_sample_title.setMaximumSize(QSize(16777215, 31))
        self.lbl_sample_title.setAlignment(Qt.AlignCenter)

        self.verticalLayout_4.addWidget(self.lbl_sample_title)

        self.splitter_2.addWidget(self.widget)
        self.splitter = QSplitter(self.splitter_2)
        self.splitter.setObjectName(u"splitter")
        self.splitter.setOrientation(Qt.Horizontal)
        self.widget1 = QWidget(self.splitter)
        self.widget1.setObjectName(u"widget1")
        self.verticalLayout = QVBoxLayout(self.widget1)
        self.verticalLayout.setObjectName(u"verticalLayout")
        self.verticalLayout.setContentsMargins(0, 0, 0, 0)
        self.widget_amp = QWidget(self.widget1)
        self.widget_amp.setObjectName(u"widget_amp")
        self.widget_amp.setMinimumSize(QSize(0, 230))

        self.verticalLayout.addWidget(self.widget_amp)

        self.lbl_amp_title = QLabel(self.widget1)
        self.lbl_amp_title.setObjectName(u"lbl_amp_title")
        self.lbl_amp_title.setAlignment(Qt.AlignCenter)

        self.verticalLayout.addWidget(self.lbl_amp_title)

        self.splitter.addWidget(self.widget1)
        self.widget2 = QWidget(self.splitter)
        self.widget2.setObjectName(u"widget2")
        self.verticalLayout_2 = QVBoxLayout(self.widget2)
        self.verticalLayout_2.setObjectName(u"verticalLayout_2")
        self.verticalLayout_2.setContentsMargins(0, 0, 0, 0)
        self.widget_counter = QWidget(self.widget2)
        self.widget_counter.setObjectName(u"widget_counter")
        self.widget_counter.setMinimumSize(QSize(0, 230))

        self.verticalLayout_2.addWidget(self.widget_counter)

        self.lbl_counter_title = QLabel(self.widget2)
        self.lbl_counter_title.setObjectName(u"lbl_counter_title")
        self.lbl_counter_title.setMaximumSize(QSize(16777215, 31))
        self.lbl_counter_title.setAlignment(Qt.AlignCenter)

        self.verticalLayout_2.addWidget(self.lbl_counter_title)

        self.splitter.addWidget(self.widget2)
        self.splitter_2.addWidget(self.splitter)

        self.gridLayout_4.addWidget(self.splitter_2, 0, 0, 1, 1)


        self.gridLayout_5.addWidget(self.widget_plot, 1, 1, 1, 1)

        self.widget_bottom = QWidget(self.centralwidget)
        self.widget_bottom.setObjectName(u"widget_bottom")
        self.horizontalLayout = QHBoxLayout(self.widget_bottom)
        self.horizontalLayout.setObjectName(u"horizontalLayout")
        self.file_card = QGroupBox(self.widget_bottom)
        self.file_card.setObjectName(u"file_card")
        self.file_card.setMinimumSize(QSize(220, 0))
        self.file_card.setMaximumSize(QSize(16777215, 16777215))
        font1 = QFont()
        font1.setItalic(False)
        self.file_card.setFont(font1)
        self.gridLayout_8 = QGridLayout(self.file_card)
        self.gridLayout_8.setObjectName(u"gridLayout_8")
        self.lbl_ch = QLabel(self.file_card)
        self.lbl_ch.setObjectName(u"lbl_ch")

        self.gridLayout_8.addWidget(self.lbl_ch, 0, 0, 1, 1)

        self.combo_ch = QComboBox(self.file_card)
        self.combo_ch.addItem("")
        self.combo_ch.addItem("")
        self.combo_ch.addItem("")
        self.combo_ch.addItem("")
        self.combo_ch.addItem("")
        self.combo_ch.addItem("")
        self.combo_ch.addItem("")
        self.combo_ch.addItem("")
        self.combo_ch.setObjectName(u"combo_ch")

        self.gridLayout_8.addWidget(self.combo_ch, 0, 1, 1, 1)

        self.btn_save_wave = QPushButton(self.file_card)
        self.btn_save_wave.setObjectName(u"btn_save_wave")

        self.gridLayout_8.addWidget(self.btn_save_wave, 1, 0, 1, 2)

        self.btn_save_data = QPushButton(self.file_card)
        self.btn_save_data.setObjectName(u"btn_save_data")

        self.gridLayout_8.addWidget(self.btn_save_data, 2, 0, 1, 2)

        self.btn_clear = QPushButton(self.file_card)
        self.btn_clear.setObjectName(u"btn_clear")

        self.gridLayout_8.addWidget(self.btn_clear, 3, 0, 1, 2)


        self.horizontalLayout.addWidget(self.file_card)

        self.status_card = QGroupBox(self.widget_bottom)
        self.status_card.setObjectName(u"status_card")
        self.status_card.setMaximumSize(QSize(200, 16777215))
        self.gridLayout_9 = QGridLayout(self.status_card)
        self.gridLayout_9.setObjectName(u"gridLayout_9")
        self.horizontalSpacer_4 = QSpacerItem(40, 20, QSizePolicy.Expanding, QSizePolicy.Minimum)

        self.gridLayout_9.addItem(self.horizontalSpacer_4, 0, 0, 1, 1)

        self.gridLayout_6 = QGridLayout()
        self.gridLayout_6.setObjectName(u"gridLayout_6")
        self.horizontalSpacer_2 = QSpacerItem(40, 20, QSizePolicy.Expanding, QSizePolicy.Minimum)

        self.gridLayout_6.addItem(self.horizontalSpacer_2, 0, 2, 1, 1)

        self.port_status = QLabel(self.status_card)
        self.port_status.setObjectName(u"port_status")
        self.port_status.setMinimumSize(QSize(0, 0))
        self.port_status.setAlignment(Qt.AlignCenter)

        self.gridLayout_6.addWidget(self.port_status, 0, 1, 1, 1)

        self.horizontalSpacer_1 = QSpacerItem(40, 20, QSizePolicy.Expanding, QSizePolicy.Minimum)

        self.gridLayout_6.addItem(self.horizontalSpacer_1, 0, 0, 1, 1)


        self.gridLayout_9.addLayout(self.gridLayout_6, 1, 0, 1, 1)

        self.horizontalLayout_4 = QHBoxLayout()
        self.horizontalLayout_4.setObjectName(u"horizontalLayout_4")
        self.lbl_counting_rate = QLabel(self.status_card)
        self.lbl_counting_rate.setObjectName(u"lbl_counting_rate")
        self.lbl_counting_rate.setAlignment(Qt.AlignCenter)

        self.horizontalLayout_4.addWidget(self.lbl_counting_rate)

        self.acq_counting_rate = QLCDNumber(self.status_card)
        self.acq_counting_rate.setObjectName(u"acq_counting_rate")
        self.acq_counting_rate.setMinimumSize(QSize(0, 40))
        self.acq_counting_rate.setMaximumSize(QSize(16777215, 40))

        self.horizontalLayout_4.addWidget(self.acq_counting_rate)


        self.gridLayout_9.addLayout(self.horizontalLayout_4, 2, 0, 1, 1)

        self.horizontalLayout_3 = QHBoxLayout()
        self.horizontalLayout_3.setObjectName(u"horizontalLayout_3")
        self.lbl_counter = QLabel(self.status_card)
        self.lbl_counter.setObjectName(u"lbl_counter")
        self.lbl_counter.setMinimumSize(QSize(0, 0))
        self.lbl_counter.setMaximumSize(QSize(16777215, 16777215))
        self.lbl_counter.setAlignment(Qt.AlignCenter)

        self.horizontalLayout_3.addWidget(self.lbl_counter)

        self.acq_counter = QLCDNumber(self.status_card)
        self.acq_counter.setObjectName(u"acq_counter")
        sizePolicy.setHeightForWidth(self.acq_counter.sizePolicy().hasHeightForWidth())
        self.acq_counter.setSizePolicy(sizePolicy)
        self.acq_counter.setMinimumSize(QSize(0, 40))
        self.acq_counter.setMaximumSize(QSize(16777215, 40))

        self.horizontalLayout_3.addWidget(self.acq_counter)


        self.gridLayout_9.addLayout(self.horizontalLayout_3, 3, 0, 1, 1)


        self.horizontalLayout.addWidget(self.status_card)

        self.log_card = QGroupBox(self.widget_bottom)
        self.log_card.setObjectName(u"log_card")
        self.log_card.setMaximumSize(QSize(16777215, 16777215))
        self.verticalLayout_3 = QVBoxLayout(self.log_card)
        self.verticalLayout_3.setObjectName(u"verticalLayout_3")
        self.log_text = QPlainTextEdit(self.log_card)
        self.log_text.setObjectName(u"log_text")
        self.log_text.setMinimumSize(QSize(0, 0))

        self.verticalLayout_3.addWidget(self.log_text)


        self.horizontalLayout.addWidget(self.log_card)


        self.gridLayout_5.addWidget(self.widget_bottom, 2, 0, 1, 2)

        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QMenuBar(MainWindow)
        self.menubar.setObjectName(u"menubar")
        self.menubar.setGeometry(QRect(0, 0, 1200, 25))
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QStatusBar(MainWindow)
        self.statusbar.setObjectName(u"statusbar")
        MainWindow.setStatusBar(self.statusbar)

        self.retranslateUi(MainWindow)

        self.combo_baud.setCurrentIndex(7)
        self.btn_single.setDefault(False)


        QMetaObject.connectSlotsByName(MainWindow)
    # setupUi

    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(QCoreApplication.translate("MainWindow", u"MainWindow", None))
        self.sample_card.setTitle(QCoreApplication.translate("MainWindow", u"\u901a\u8baf\u8bbe\u7f6e", None))
        self.lbl_port.setText(QCoreApplication.translate("MainWindow", u"\u4e32\u53e3\u7aef\u53e3", None))
        self.btn_refresh.setText("")
        self.lbl_baud.setText(QCoreApplication.translate("MainWindow", u"\u6ce2\u7279\u7387", None))
        self.combo_baud.setItemText(0, QCoreApplication.translate("MainWindow", u"19200", None))
        self.combo_baud.setItemText(1, QCoreApplication.translate("MainWindow", u"38400", None))
        self.combo_baud.setItemText(2, QCoreApplication.translate("MainWindow", u"57600", None))
        self.combo_baud.setItemText(3, QCoreApplication.translate("MainWindow", u"115200", None))
        self.combo_baud.setItemText(4, QCoreApplication.translate("MainWindow", u"128000", None))
        self.combo_baud.setItemText(5, QCoreApplication.translate("MainWindow", u"230400", None))
        self.combo_baud.setItemText(6, QCoreApplication.translate("MainWindow", u"256000", None))
        self.combo_baud.setItemText(7, QCoreApplication.translate("MainWindow", u"460800", None))
        self.combo_baud.setItemText(8, QCoreApplication.translate("MainWindow", u"512000", None))
        self.combo_baud.setItemText(9, QCoreApplication.translate("MainWindow", u"750000", None))
        self.combo_baud.setItemText(10, QCoreApplication.translate("MainWindow", u"921600", None))

        self.combo_baud.setCurrentText(QCoreApplication.translate("MainWindow", u"460800", None))
        self.btn_connect.setText(QCoreApplication.translate("MainWindow", u"\u8fde\u63a5\u8bbe\u5907", None))
        self.param_card.setTitle(QCoreApplication.translate("MainWindow", u"\u6210\u5f62\u53c2\u6570", None))
        self.btn_send.setText(QCoreApplication.translate("MainWindow", u"\u53d1\u9001\u53c2\u6570", None))
        self.inp_nb_na.setText(QCoreApplication.translate("MainWindow", u"20", None))
        self.lbl_tauR.setText(QCoreApplication.translate("MainWindow", u"tauR", None))
        self.lbl_tauF.setText(QCoreApplication.translate("MainWindow", u"tauF", None))
        self.lbl_na.setText(QCoreApplication.translate("MainWindow", u"na", None))
        self.inp_na.setText(QCoreApplication.translate("MainWindow", u"10", None))
        self.inp_tauR.setText(QCoreApplication.translate("MainWindow", u"2", None))
        self.inp_tauF.setText(QCoreApplication.translate("MainWindow", u"10", None))
        self.lbl_nb_ba.setText(QCoreApplication.translate("MainWindow", u"nb-na", None))
        self.btn_fit.setText(QCoreApplication.translate("MainWindow", u"\u62df\u5408\u53c2\u6570", None))
        self.acq_card.setTitle(QCoreApplication.translate("MainWindow", u"\u91c7\u6837\u8bbe\u7f6e", None))
        self.btn_single.setText(QCoreApplication.translate("MainWindow", u"\u5355\u6b21\u6ce2\u5f62\u91c7\u6837", None))
        self.btn_start.setText(QCoreApplication.translate("MainWindow", u"\u5f00\u59cb\u91c7\u96c6", None))
        self.btn_stop.setText(QCoreApplication.translate("MainWindow", u"\u505c\u6b62\u91c7\u96c6", None))
        self.combo_time.setItemText(0, QCoreApplication.translate("MainWindow", u"min", None))
        self.combo_time.setItemText(1, QCoreApplication.translate("MainWindow", u"h", None))

        self.clock_label.setText(QCoreApplication.translate("MainWindow", u"\u65f6\u95f4", None))
        self.lbl_sample_title.setText(QCoreApplication.translate("MainWindow", u"\u5355\u6b21\u91c7\u6837\u6ce2\u5f62", None))
        self.lbl_amp_title.setText(QCoreApplication.translate("MainWindow", u"\u5355\u901a\u9053\u5e45\u5ea6\u8c31", None))
        self.lbl_counter_title.setText(QCoreApplication.translate("MainWindow", u"\u591a\u901a\u9053\u4e00\u81f4\u6027\u8c31", None))
        self.file_card.setTitle(QCoreApplication.translate("MainWindow", u"\u6570\u636e\u7ba1\u7406", None))
        self.lbl_ch.setText(QCoreApplication.translate("MainWindow", u"\u9009\u62e9\u901a\u9053", None))
        self.combo_ch.setItemText(0, QCoreApplication.translate("MainWindow", u"\u901a\u90531", None))
        self.combo_ch.setItemText(1, QCoreApplication.translate("MainWindow", u"\u901a\u90532", None))
        self.combo_ch.setItemText(2, QCoreApplication.translate("MainWindow", u"\u901a\u90533", None))
        self.combo_ch.setItemText(3, QCoreApplication.translate("MainWindow", u"\u901a\u90534", None))
        self.combo_ch.setItemText(4, QCoreApplication.translate("MainWindow", u"\u901a\u90535", None))
        self.combo_ch.setItemText(5, QCoreApplication.translate("MainWindow", u"\u901a\u90536", None))
        self.combo_ch.setItemText(6, QCoreApplication.translate("MainWindow", u"\u901a\u90537", None))
        self.combo_ch.setItemText(7, QCoreApplication.translate("MainWindow", u"\u901a\u90538", None))

        self.btn_save_wave.setText(QCoreApplication.translate("MainWindow", u"\u4fdd\u5b58\u5f53\u524d\u56fe\u7247", None))
        self.btn_save_data.setText(QCoreApplication.translate("MainWindow", u"\u5bfc\u51fa\u91c7\u96c6\u6570\u636e", None))
        self.btn_clear.setText(QCoreApplication.translate("MainWindow", u"\u6e05\u7a7a\u663e\u793a", None))
        self.status_card.setTitle(QCoreApplication.translate("MainWindow", u"\u7cfb\u7edf\u72b6\u6001", None))
        self.port_status.setText(QCoreApplication.translate("MainWindow", u"\u4e32\u53e3\u672a\u8fde\u63a5", None))
        self.lbl_counting_rate.setText(QCoreApplication.translate("MainWindow", u"\u8ba1\u6570\u7387", None))
        self.lbl_counter.setText(QCoreApplication.translate("MainWindow", u"\u603b\u8ba1\u6570", None))
        self.log_card.setTitle(QCoreApplication.translate("MainWindow", u"\u7cfb\u7edf\u65e5\u5fd7", None))
    # retranslateUi

