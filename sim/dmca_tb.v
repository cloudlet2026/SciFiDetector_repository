`timescale 1ns / 1ps
module dmca_tb();
    reg                                                  sys_clk                     ;
    reg                                                  sys_rstn                    ;
    reg                                                  alg_en                      ;
    wire                                                 peak_value_ok               ;
    wire               [  13: 0]                         peak_value                  ;
    wire               [  17: 0]                         trapezd_data                ;
    wire               [  17: 0]                         triangle_data               ;

    integer i;
    reg    signed     [  13: 0]                         adc_fifo_data ;

    reg [11:0] pulse_data [0:255];
    initial begin
        $readmemh("../../../../SciFiMuonDetectorAXILite.srcs/sim_1/pulse_data.hex", pulse_data);
    end

    initial begin
        for (i = 0; i < 255; i = i + 1) begin
            @(posedge sys_clk);
            if(sys_rstn)
                adc_fifo_data = $signed(pulse_data[i] - 13'd2048);
        end
    end

    dmca dmca_uut (
        .peak_threshold                     (100                       ),
        .peak_threshold_count               (12                        ),
        .na                                 (40                        ),
        .nb                                 (80                        ),
        .a_over_na_mul_a_minus_b            (128807239                 ),
        .inv_na_mul_a_minus_b               (132065508                 ),
        .b                                  (829002852                 ),
        .peakext_delay_time                 (20                        ),
        .sys_clk                            (sys_clk                   ),
        .sys_rstn                           (sys_rstn                  ),
        .alg_en                             (alg_en                    ),
        .adc_fifo_data                      (adc_fifo_data             ),
        .peak_value_ok                      (peak_value_ok             ),
        .peak_value                         (peak_value                ),
        .trapezd_data                       (trapezd_data              ),
        .triangle_data                      (triangle_data             )
    );

    initial begin
        sys_rstn = 0;
        sys_clk = 0;
        alg_en = 0;
        #200 sys_rstn = 1;
        #100 alg_en = 1;
    end

    initial begin
        forever begin
            #7.5 sys_clk = ~sys_clk;
        end
    end

endmodule
