`timescale 1ns / 1ps
// 差分延迟
// H(z) = 1 - z^{-nb}
// v_1[n] = v_i[n] - v_i[n-nb]
module trapezd_alg_m1(
    input                                                  sys_clk                    ,
    input                                                  sys_rstn                   ,
    input        signed  [  13: 0]                         adc_fifo_data              ,// 14位有符号输入（不扩展）
    input                [   8: 0]                         nb                         ,

    output reg   signed  [  15: 0]                         trapezd_alg_m1_dataout      // 输出16位避免溢出
    );

    parameter                           REG_GLOBAL_LIMIT            = 400                  ;
    
    reg                                                  rd_en,wr_en                 ;
    reg                [   7: 0]                         wr_addr,rd_addr             ;
    wire    signed     [  13: 0]                         adc_fifo_data_delay_nb    ;
    always @(posedge sys_clk or negedge sys_rstn) begin
        if (!sys_rstn) begin
            wr_addr <= 'd0;
            rd_addr <= 'd0;
            wr_en <= 1'b0;
            rd_en <= 1'b0;
        end else begin
            wr_en <= 1'b1;
            wr_addr <= wr_addr + 1'b1;
            rd_addr <= wr_addr - nb;
            if(wr_addr - nb > 0)
                rd_en <= 1'b1;
        end
    end
    always@(posedge sys_clk) begin
        if(!sys_rstn)
            trapezd_alg_m1_dataout <= 16'sd0;
        else
            // 14位有符号数相减，结果自动扩展为16位（避免溢出）
            trapezd_alg_m1_dataout <= adc_fifo_data - adc_fifo_data_delay_nb;
    end
    blk_mem_gen_delay_nb u1_blk_mem_gen_delay_nb (
    .clka                               (sys_clk                   ),// input wire clka
    .ena                                (wr_en                     ),// input wire ena
    .wea                                (1'b1                      ),// input wire [0 : 0] wea
    .addra                              (wr_addr                   ),// input wire [7 : 0] addra
    .dina                               (adc_fifo_data             ),// input wire [13 : 0] dina
    .clkb                               (sys_clk                   ),// input wire clkb
    .enb                                (rd_en                     ),// input wire enb
    .addrb                              (rd_addr                   ),// input wire [7 : 0] addrb
    .doutb                              (adc_fifo_data_delay_nb    ) // output wire [13 : 0] doutb
    );
endmodule