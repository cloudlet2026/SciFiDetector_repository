
`timescale 1 ns / 1 ps

	module wave_bram_ctrl #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Bram Bus Interface BRAM_PORT
		parameter integer BRAM_DATA_WIDTH	= 32,
		parameter integer BRAM_ADDR_WIDTH	= 32,
		parameter integer BRAM_DATA_DEPTH	= 4096,
		parameter integer BRAM_STRB_WIDTH	= BRAM_DATA_WIDTH / 8
	)
	(
		input                                                  sys_clk                    ,//时钟
		input                                                  sys_rstn                   ,//复位,低电平有效
		// ADC端口
		input                [  13: 0]                         adc_fifo_data              ,//成形幅值
		// BRAM端口
		(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *)
		output reg           [BRAM_ADDR_WIDTH-1: 0]           addra                       ,//BRAM地址
		(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *)
		output                                                 clka                        ,//BRAM时钟
		(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *)
		output reg           [BRAM_DATA_WIDTH-1: 0]            dina                        ,//BRAM写数据
		(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 16384, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE BRAM_CTRL, READ_WRITE_MODE READ_WRITE, READ_LATENCY 1" *)
		(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *)
		input                [BRAM_DATA_WIDTH-1: 0]            douta                       ,//BRAM读数据
		(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *)
		output reg                                             ena                         ,//BRAM使能端口
		(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA RST" *)
		output                                                 rsta                        ,//BRAM复位,高电平有效
		(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *)
		output reg           [BRAM_STRB_WIDTH-1: 0]             wea                         ,//BRAM读写使能,字节选通
		
		input                                                  wave_en                     ,//采样波形使能
		input                                                  mux_sel_en                  ,//选择使能
		// 中断   
		input                                                  wave_intr_clr               ,//清除中断信号
		output reg                                             wave_intr                   ,//中断信号
		output reg                                             wave_intr_clr_ack            //清除中断响应
	);

    localparam                          BRAM_DEPTH                  = BRAM_DATA_DEPTH * BRAM_STRB_WIDTH;
    localparam                          IDLE                        = 3'd0;
    localparam                          WAIT_SEL                    = 3'd1;
    localparam                          WRITE_BRAM                  = 3'd2;
    localparam                          STOP_WRITE                  = 3'd3;
    localparam                          CLEAR_BRAM                  = 3'd4;
    localparam                          RESP                        = 3'd5;

    reg                [   2: 0]                         state;
    reg                                                  wave_en_d1;
    reg                                                  wave_en_d2;
    
    // 跨时钟域同步信号
    reg                                                  mux_sel_en_sync1;
    reg                                                  mux_sel_en_sync2;
    
    assign clka = sys_clk;
    assign rsta = ~sys_rstn;

    // mux_sel_en 同步
    always @(posedge sys_clk or negedge sys_rstn) begin
        if (!sys_rstn) begin
            mux_sel_en_sync1 <= 1'b0;
            mux_sel_en_sync2 <= 1'b0;
        end else begin
            mux_sel_en_sync1 <= mux_sel_en;
            mux_sel_en_sync2 <= mux_sel_en_sync1;
        end
    end
    
    // wave_en 上升沿检测
    always @(posedge sys_clk or negedge sys_rstn) begin
        if(~sys_rstn) begin
            wave_en_d1 <= 1'b0;
            wave_en_d2 <= 1'b0;
        end else begin
            wave_en_d1 <= wave_en;
            wave_en_d2 <= wave_en_d1;
        end
    end
    
    wire waveform_start = wave_en_d1 & ~wave_en_d2;

    // 主状态机
    always @(posedge sys_clk or negedge sys_rstn) begin
        if (~sys_rstn) begin
            state     <= IDLE;
            dina       <= {BRAM_DATA_WIDTH{1'b0}};
            ena        <= 1'b0;
            wea        <= {BRAM_STRB_WIDTH{1'b0}};
            addra      <= {BRAM_ADDR_WIDTH{1'b0}};
            wave_intr      <= 1'b0;
            wave_intr_clr_ack <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    wave_intr_clr_ack <= 1'b0;
                    ena        <= 1'b0;
                    wea        <= {BRAM_STRB_WIDTH{1'b0}};
                    wave_intr      <= 1'b0;
                    
                    if(waveform_start) begin
                        state <= WAIT_SEL;
                        addra <= {BRAM_ADDR_WIDTH{1'b0}};
                    end
                end
                
                WAIT_SEL: begin
                    if(mux_sel_en_sync2) begin
                        state <= WRITE_BRAM;
                        ena    <= 1'b1;
                        wea    <= {BRAM_STRB_WIDTH{1'b1}};
                        dina   <= {{(BRAM_DATA_WIDTH-14){1'b0}}, adc_fifo_data};
                    end
                end
                
                WRITE_BRAM: begin
                    if(!mux_sel_en_sync2) begin
                        state <= STOP_WRITE;
                        ena    <= 1'b0;
                        wea    <= {BRAM_STRB_WIDTH{1'b0}};
                        wave_intr  <= 1'b1;
                    end else begin
                        if (addra < BRAM_DEPTH - (BRAM_DATA_WIDTH/8)) begin
                            addra  <= addra + (BRAM_DATA_WIDTH/8);
                            dina   <= {{(BRAM_DATA_WIDTH-14){1'b0}}, adc_fifo_data};
                            ena    <= 1'b1;
                            wea    <= {BRAM_STRB_WIDTH{1'b1}};
                        end else begin
                            ena    <= 1'b0;
                            wea    <= {BRAM_STRB_WIDTH{1'b0}};
                        end
                    end
                end
                
                STOP_WRITE: begin
                    if(wave_intr_clr) begin
                        state <= CLEAR_BRAM;
                        wave_intr  <= 1'b0;
                        
                        addra  <= {BRAM_ADDR_WIDTH{1'b0}};
                        dina   <= {BRAM_DATA_WIDTH{1'b0}};
                        ena    <= 1'b1;
                        wea    <= {BRAM_STRB_WIDTH{1'b1}};
                    end
                end
                
                CLEAR_BRAM: begin
                    if (addra >= BRAM_DEPTH - (BRAM_DATA_WIDTH/8)) begin
                        state <= RESP;
                        ena    <= 1'b0;
                        wea    <= {BRAM_STRB_WIDTH{1'b0}};
                    end else begin
                        addra  <= addra + (BRAM_DATA_WIDTH/8);
                        dina   <= {BRAM_DATA_WIDTH{1'b0}};
                        ena    <= 1'b1;
                        wea    <= {BRAM_STRB_WIDTH{1'b1}};
                    end
                end
                
                RESP: begin
                    wave_intr_clr_ack <= 1'b1;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
