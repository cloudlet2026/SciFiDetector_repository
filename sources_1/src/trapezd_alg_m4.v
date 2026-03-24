`timescale 1ns / 1ps
// ²î·ÖÑÓ³Ù
// H(z) = 1 - z^{-na}
// v_4[n] = v_3[n] - v_3[n-na]
module trapezd_alg_m4(
    input                                                  sys_clk                    ,
    input                                                  sys_rstn                   ,
    input        signed  [  51: 0]                         trapezd_alg_m3_datain      ,
    input                [   8: 0]                         na                         ,

    output       signed  [  17: 0]                         trapezd_alg_m4_dataout      
    );
    
    parameter                           REG_GLOBAL_LIMIT            = 400                  ;
    reg     signed     [  51: 0]                         trapezd_alg                 ;
    reg                                                  rd_en,wr_en                 ;
    reg                [   7: 0]                         wr_addr,rd_addr             ;
    wire    signed     [  51: 0]                         trapezd_alg_m3_delay_na     ;
    assign                              trapezd_alg_m4_dataout      = trapezd_alg[29] ? (trapezd_alg[47:30] + 1'b1) : trapezd_alg[47:30];
    always @(posedge sys_clk or negedge sys_rstn) begin
        if (!sys_rstn) begin
            wr_addr <= 'd0;
            rd_addr <= 'd0;
            wr_en <= 1'b0;
            rd_en <= 1'b0;
        end else begin
            wr_en <= 1'b1;
            wr_addr <= wr_addr + 1'b1;
            rd_addr <= wr_addr - na;
            if(wr_addr - na > 0)
                rd_en <= 1'b1;
        end
    end
    always@(posedge sys_clk) begin
        if(!sys_rstn)
            trapezd_alg <= 52'sd0;
        else
            trapezd_alg <=  trapezd_alg_m3_datain - trapezd_alg_m3_delay_na;
    end
    blk_mem_gen_delay_na u1_blk_mem_gen_delay_na (
    .clka                               (sys_clk                   ),// input wire clka
    .ena                                (wr_en                     ),// input wire ena
    .wea                                (1'b1                      ),// input wire [0 : 0] wea
    .addra                              (wr_addr                   ),// input wire [7 : 0] addra
    .dina                               (trapezd_alg_m3_datain     ),// input wire [51 : 0] dina
    .clkb                               (sys_clk                   ),// input wire clkb
    .enb                                (rd_en                     ),// input wire enb
    .addrb                              (rd_addr                   ),// input wire [7 : 0] addrb
    .doutb                              (trapezd_alg_m3_delay_na   ) // output wire [51 : 0] doutb
    );

endmodule