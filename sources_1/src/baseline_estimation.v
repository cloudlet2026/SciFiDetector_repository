`timescale 1ns / 1ps
module baseline_estimation #(
        parameter                           REG_GLOBAL_LIMIT            = 511   ,
        parameter                           BASELINE_AVR_POINT          = 8     // 基线平均点数
    )(
        input                               sys_clk, sys_rstn          ,
        input                               peak_start_flag            ,
        input        signed  [  17: 0]      trapezd_alg_datain         ,
        output reg   signed  [  17: 0]      trapezd_baseline           ,
        // 成形参数输入
        input                [   8: 0]      na                         ,
        input                [   8: 0]      nb
    );


    // 求平均值除法需要右移的位数
    localparam integer          divide = clogb2(BASELINE_AVR_POINT - 1);
    localparam integer          EXTRA_CONS = 5; //固定补偿值（5），补偿基线延迟和间隔时间计数器


    reg                [   9: 0]        interval_count              ;// 间隔计数器

    wire               [   9: 0]        interval_time               ;//Peak spacing, distance from peak tail to peak head
    reg     signed     [  31: 0]        add_temp_trapezd            ;

    assign                              interval_time               = nb + na + BASELINE_AVR_POINT + EXTRA_CONS;// 间隔时间

    // 计算BRAM地址位宽
    localparam                          ADDR_WIDTH                  = $clog2(REG_GLOBAL_LIMIT);

    // BRAM读写地址
    reg                [ADDR_WIDTH-1: 0]                         wr_addr                     ;
    reg                [ADDR_WIDTH-1: 0]                         rd_addr    [7:0]  ;// 8个并行读取地址

    // BRAM输出数据
    wire    signed     [17: 0]                         rd_data    [7:0]  ;

    // 生成8个读取地址（对应原8个连续寄存器地址）
    integer i;
    always @(*) begin
        for(i = 0; i < 8; i = i + 1) begin
            // 计算读取地址，等效于原delay_temp_trapezd[na + EXTRA_CONS + BASELINE_AVR_POINT - 1 - i]
            rd_addr[i] = (na + EXTRA_CONS + BASELINE_AVR_POINT - 1 - i) % REG_GLOBAL_LIMIT;
        end
    end

    // 写地址循环计数
    always @(posedge sys_clk or negedge sys_rstn) begin
        if(!sys_rstn) begin
            wr_addr <= {ADDR_WIDTH{1'b0}};
        end else begin
            wr_addr <= wr_addr + 1'b1;
        end
    end

    // 例化8个Xilinx BRAM IP核(同步读写)
    // 每个BRAM配置为: 512x18位, 同步读写, 无输出寄存器, 初始化为0
    genvar j;
    generate
        for(j = 0; j < 8; j = j + 1) begin : bram_delay512_inst
            blk_mem_gen_delay512 blk_mem_gen_delay512_inst (
            .clka                               (sys_clk                   ),// 写时钟
            .wea                                (1'b1                      ),// 写使能(始终有效)
            .addra                              (wr_addr                   ),// 写地址
            .dina                               (trapezd_alg_datain        ),// 18位有符号输入数据
            .clkb                               (sys_clk                   ),// 读时钟(与写时钟同频)
            .addrb                              (rd_addr[j]                ),// 读地址
            .doutb                              (rd_data[j]                ) // 18位有符号输出数据
            );
        end
    endgenerate

    // 计算8点求和（增加位宽防止溢出）
    always @(posedge sys_clk or negedge sys_rstn) begin
        if(!sys_rstn) begin
            add_temp_trapezd <= 32'sd0;
        end else begin
            add_temp_trapezd <= rd_data[0] + rd_data[1] +
                                rd_data[2] + rd_data[3] +
                                rd_data[4] + rd_data[5] +
                                rd_data[6] + rd_data[7];
        end
    end

    //计算基线平均值
    always@(posedge sys_clk) begin
        if(!sys_rstn) begin
            trapezd_baseline <= 18'd0;
        end
        else if(peak_start_flag&&(interval_count>=interval_time)) begin// 未发生堆积更新当前基线值
            trapezd_baseline <= add_temp_trapezd >> divide;
        end
        else if(peak_start_flag&&(interval_count<interval_time)) begin// 发生堆积保持前一个基线值
            trapezd_baseline <= trapezd_baseline;
        end
    end
    // 间隔计数器
    always@(posedge sys_clk) begin
        if(!sys_rstn) begin
            interval_count <= interval_time;
        end
        else if(peak_start_flag) begin
            interval_count <= 10'd0;
        end
        else if(interval_count>=interval_time) begin
            interval_count <= interval_time;
        end
        else begin
            interval_count <= interval_count + 1'b1;
        end
    end

    // 求一个值的位宽
    function integer clogb2 (input integer bit_depth);
        begin
            for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
                bit_depth = bit_depth >> 1;
        end
    endfunction

endmodule
