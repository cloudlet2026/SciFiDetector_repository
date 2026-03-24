`timescale 1ns / 1ps
// 积分运算
// H(z) = \frac{1 - b z^{-1}}{1 - z^{-1}}
// v_3[n] = v_2[n] - b v_2[n-1] + v_3[n-1]
module trapezd_alg_m3(
        input                               sys_clk                    ,
        input                               sys_rstn                   ,
        input        signed  [  49: 0]      trapezd_alg_m2_datain      ,
        input        signed  [  31: 0]      b                          ,
        output reg   signed  [  51: 0]      trapezd_alg_m3_dataout
    );

    reg     signed     [  49: 0]        vi_delay1                   ;
    wire    signed     [  81: 0]        mult2_full                  ;
    wire    signed     [  51: 0]        multiple_temp2              ;

    // 扩展为82位乘法得到Q60结果
    assign                              mult2_full                  = vi_delay1 * b;// [49][48:30][29:0]*[31][30][29:0]=[81][80:60][59:0]
    // 右移30位转换为Q30格式 (取[81:30]共52位)
    // 四舍五入处理 (使用第29位作为舍入位)
    assign                              multiple_temp2              = mult2_full[29] ? (mult2_full[81:30] + 1'b1) : mult2_full[81:30];// [51][50:30][29:0]


    always@(posedge sys_clk) begin
        if(!sys_rstn) begin
            trapezd_alg_m3_dataout <= 52'sd0;
            vi_delay1 <= 50'sd0;
        end
        else begin
            vi_delay1 <= trapezd_alg_m2_datain;
            trapezd_alg_m3_dataout <= trapezd_alg_m3_dataout + trapezd_alg_m2_datain - multiple_temp2;
        end
    end

endmodule
