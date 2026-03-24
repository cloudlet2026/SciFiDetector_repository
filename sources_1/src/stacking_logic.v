`timescale 1ns / 1ps
module stacking_logic
    (
        input                               sys_clk                    ,
        input                               sys_rstn                   ,
        input                               peak_start_flag            ,
        output reg                          stacking_flag              ,
        // 最小间隔参数输入
        input                [   8: 0]      nb
    );

    reg                [   9: 0]        interval_count              ;// 脉冲起始位置间隔计数
    // 最小峰值堆积间隔，即两个脉冲之间的最小间隔，可以用梯形来区分，这里采用nb作为间隔
    wire               [   9: 0]        min_interval                ;
    assign                              min_interval                = nb;

    always@(posedge sys_clk) begin
        if(!sys_rstn) begin
            interval_count <= min_interval;
        end
        else if(peak_start_flag) begin
            interval_count <= 10'd0;
        end
        else if(interval_count >= min_interval) begin
            interval_count <= min_interval;
        end
        else begin
            interval_count <= interval_count + 1'b1;
        end
    end

    always@(posedge sys_clk) begin
        if(!sys_rstn) begin
            stacking_flag <= 1'b0;
        end
        else if((interval_count < min_interval) &
                peak_start_flag) begin
            stacking_flag <= 1'b1;
        end
        else begin
            stacking_flag <= 1'b0;
        end
    end

endmodule
