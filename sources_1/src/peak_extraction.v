`timescale 1ns / 1ps
module peak_extraction #(
        parameter                           PEAK_AVR_POINT              = 32    // 平顶平均计算点数
    )(
        input                               sys_clk                    ,
        input                               sys_rstn                   ,
        input        signed  [  17: 0]      trapezd_alg_datain         ,
        input        signed  [  17: 0]      trapezd_baseline           ,
        input                               peak_start_flag            ,
        input                               adc_otr                    ,
        output reg                          peak_value_ok              ,
        output               [  13: 0]      peak_true_value            ,
        // 参数输入
        // 在取梯形平顶的平均值之前计算延迟，以确保稳定的平顶
        input                [   8: 0]      peakext_delay_time
    );

    parameter                           OTR_DELAY                   = 60    ;

    localparam integer          divide = clogb2(PEAK_AVR_POINT - 1); // 除数：右移位数

    // 状态
    parameter                           WAIT                        = 3'd0  ,
                                        DELAY = 3'd1,
                                        ACC = 3'd2,
                                        BASELINE = 3'd3,
                                        PILE_UP = 3'd4;

    reg                [   7: 0]        status                      ;// 状态机状态转换寄存器
    reg     signed     [  17: 0]        peak_value_mean             ;// 滑动平均滤波后的幅度值
    reg                [   9: 0]        delay_count                 ;// 等待梯形平顶稳定计数，峰值提取取平顶后半部分
    reg     signed     [  63: 0]        flat_sum                    ;// 平顶值之和
    reg                                 peak_start_flag_delay       ;// 延迟后的起始信号
    reg     signed     [  17: 0]        peak_value_signed           ;// 减去基线后的幅度值
    reg                                 otr_shift[OTR_DELAY-1:0]    ;
    reg                [   9: 0]        otr_sum                     ;
    reg                [   7: 0]        i                           ;
    wire    signed     [  14: 0]        peak_value                  ;
    assign                              peak_value                  = peak_value_signed[14:0];
    assign                              peak_true_value             = peak_value[13:0];

    //将起始信号延迟一个周期并与堆叠信号对齐
    always@(posedge sys_clk) begin
        if(!sys_rstn) begin
            peak_start_flag_delay <= 1'b0;
        end
        else begin
            peak_start_flag_delay <= peak_start_flag;
        end
    end

    // 状态机
    always@(posedge sys_clk) begin
        if(!sys_rstn) begin
            status <= 8'd0;
            peak_value_ok <= 1'b0;
            peak_value_signed <= 17'sd0;
            delay_count <= 10'd0;
            flat_sum <= 64'sd0;
            peak_value_mean <= 18'sd0;
        end
        else begin
            case (status)
                WAIT: begin
                    peak_value_ok <= 1'b0;
                    if(peak_start_flag_delay&(otr_sum==0)) begin
                        status <= DELAY;                            // 前一个信号与当前信号没有堆积
                    end
                end
                DELAY: begin
                    if(delay_count==peakext_delay_time) begin  //等待梯形到达稳定的平顶
                        delay_count <= 10'd0;
                        status <= ACC;
                    end
                    else begin
                        delay_count <= delay_count + 1'b1;
                    end
                end
                ACC: begin
                    if(delay_count==PEAK_AVR_POINT) begin      // 累加峰值
                        peak_value_mean <= flat_sum >> divide;     // 计算均值
                        flat_sum <= 64'd0;
                        status <= BASELINE;
                        delay_count <= 10'd0;
                    end
                    else begin
                        flat_sum <= flat_sum + trapezd_alg_datain;
                        delay_count <= delay_count + 1'b1;
                    end
                end
                BASELINE: begin
                    if(peak_value_mean < trapezd_baseline) begin// 确定峰值是否已溢出
                        peak_value_ok <= 1'b1;
                        peak_value_signed <= (18'sd262143 + peak_value_mean - trapezd_baseline);
                        status <= WAIT;
                    end
                    else begin
                        peak_value_ok <= 1'b1;
                        peak_value_signed <= (peak_value_mean - trapezd_baseline);
                        status <= WAIT;
                    end
                end
                default: begin
                    status <= 8'd0;
                    peak_value_ok <= 1'b0;
                    peak_value_signed <= 18'sd0;
                    delay_count <= 10'd0;
                    flat_sum <= 64'sd0;
                    peak_value_mean <= 18'sd0;
                end
            endcase
        end
    end
    // ADC过载检测
    always@(posedge sys_clk) begin
        if(!sys_rstn) begin
            otr_sum <= 'd0;
            for(i=0; i<OTR_DELAY; i=i+1) begin
                otr_shift[i] <= 1'b0;
            end
        end
        else begin
            otr_shift[0] <= adc_otr;
            for(i=0; i<OTR_DELAY-1; i=i+1) begin                    // 储存过载标志
                otr_shift[i+1] <= otr_shift[i];
            end

            if(peak_start_flag) begin
                for(i=0; i<OTR_DELAY; i=i+1) begin                  // 统计历史过载次数
                    otr_sum <= otr_sum + otr_shift[i];
                end
            end
            else begin
                otr_sum <= 'd0;
            end
        end
    end

    // 计算一个值的位宽
    function integer clogb2 (input integer bit_depth);
        begin
            for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
                bit_depth = bit_depth >> 1;
        end
    endfunction
endmodule
