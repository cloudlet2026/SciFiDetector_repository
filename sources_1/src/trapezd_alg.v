`timescale 1ns / 1ps
// Q30表示法：
// 52位数据中，位51是符号位，位[50:30]：21位整数部分，位[29:0]：30位小数部分
module trapezd_alg #(
        parameter                           REG_GLOBAL_LIMIT            = 400
    )(
        //系统端口
        input                               sys_clk                    ,
        input                               sys_rstn                   ,
        //ADC数据输入
        input        signed  [  13: 0]      adc_fifo_data            ,// 兼容12-14位ADC
        //整形参数输入
        input                [   8: 0]      na, nb                     ,// na:梯形上升沿宽度;nb-na:梯形平顶宽度
        input        signed  [  31: 0]      a_over_na_mul_a_minus_b    ,// $\frac{a}{na(a-b)}$:a/(na*(a-b)的Q30定点数格式;
        input        signed  [  31: 0]      inv_na_mul_a_minus_b       ,// $\frac{1}{na(a-b)}$:1/(na*(a-b))的Q30定点数格式;
        input        signed  [  31: 0]      b                          ,// $a=e^{-1/n_f}$,nf为双指数下降沿衰减时间常数对应的采样周期数;
                                                                        // $b=e{-1/n_r}$,nr为双指数上升沿衰减时间常数对应的采样周期数;
        //梯形输出
        output       signed  [  17: 0]      trapezd_alg_dataout
    );



    wire    signed     [  15: 0]        data_temp1                  ;
    wire    signed     [  49: 0]        data_temp2                  ;
    wire    signed     [  51: 0]        data_temp3                  ;
    
    trapezd_alg_m1
        #(
            .REG_GLOBAL_LIMIT                   (REG_GLOBAL_LIMIT          )
        ) m1
        (
            .sys_clk                            (sys_clk                   ),
            .sys_rstn                           (sys_rstn                  ),
            .adc_fifo_data                      (adc_fifo_data             ),
            .nb                                 (nb                        ),
            .trapezd_alg_m1_dataout             (data_temp1                )
        );

    trapezd_alg_m2 m2
                   (
                       .sys_clk                            (sys_clk                   ),
                       .sys_rstn                           (sys_rstn                  ),
                       .trapezd_alg_m1_datain              (data_temp1                ),
                       .a_over_na_mul_a_minus_b            (a_over_na_mul_a_minus_b   ),
                       .inv_na_mul_a_minus_b               (inv_na_mul_a_minus_b      ),
                       .trapezd_alg_m2_dataout             (data_temp2                )
                   );

    trapezd_alg_m3 m3
                   (
                       .sys_clk                            (sys_clk                   ),
                       .sys_rstn                           (sys_rstn                  ),
                       .trapezd_alg_m2_datain              (data_temp2                ),
                       .b                                  (b                         ),
                       .trapezd_alg_m3_dataout             (data_temp3                )
                   );

    trapezd_alg_m4
        #(
            .REG_GLOBAL_LIMIT                   (REG_GLOBAL_LIMIT          )
        )
        m4
        (
            .sys_clk                            (sys_clk                   ),
            .sys_rstn                           (sys_rstn                  ),
            .trapezd_alg_m3_datain              (data_temp3                ),
            .na                                 (na                        ),
            .trapezd_alg_m4_dataout             (trapezd_alg_dataout       )
        );


endmodule
