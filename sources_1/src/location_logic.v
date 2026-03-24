`timescale 1ns / 1ps
module location_logic(
        input                               sys_clk                    ,
        input                               sys_rstn                   ,
        input        signed  [  17: 0]      triangle_alg_data          ,
        output reg                          peak_start_flag            ,
        // 超阈值和连续超阈值计数阈值
        input        signed  [  13: 0]      peak_threshold             ,
        input                [   5: 0]      peak_threshold_count
    );

    parameter                           INTERVAL                    = 8     ;

    reg     signed     [  17: 0]        triangle_data_temp[4:0]     ;
    reg                [   7: 0]        interval_count              ;

    reg                [  11: 0]        threshold_count             ;

    // 记录大于阈值的连续计数
    always@(posedge sys_clk) begin
        if(!sys_rstn) begin
            threshold_count <= 'd0;
        end
        else if(triangle_alg_data >= peak_threshold) begin
            threshold_count <= threshold_count + 1'b1;
        end
        else begin
            threshold_count <= 'd0;
        end
    end

    // 位移存储三角成形算法的五个输出值
    always@(posedge sys_clk) begin
        if(!sys_rstn) begin
            triangle_data_temp[0] <= 18'd0;
            triangle_data_temp[1] <= 18'd0;
            triangle_data_temp[2] <= 18'd0;
            triangle_data_temp[3] <= 18'd0;
            triangle_data_temp[4] <= 18'd0;
        end
        else begin
            triangle_data_temp[0] <= triangle_alg_data;
            triangle_data_temp[1] <= triangle_data_temp[0];
            triangle_data_temp[2] <= triangle_data_temp[1];
            triangle_data_temp[3] <= triangle_data_temp[2];
            triangle_data_temp[4] <= triangle_data_temp[3];
        end
    end

    // 脉冲起始位置判断逻辑
    always@(posedge sys_clk) begin
        if(!sys_rstn) begin
            peak_start_flag <= 1'd0;
            interval_count <= INTERVAL;
        end
        // 必须满足连续多点超阈值，过滤瞬态噪声
        else if(
            (triangle_data_temp[1] >= triangle_data_temp[0])&&
            (triangle_data_temp[1] >= triangle_data_temp[2])&&      // triangle_data_temp[1]为局部极大值
            (triangle_data_temp[1] >= peak_threshold)&&             // 超阈值
            (threshold_count >= peak_threshold_count)&&             // 连续超阈值
            (interval_count >= INTERVAL)                            // 检测间隔INTERVAL（8）个时钟周期
        ) begin
            peak_start_flag <= 1'd1;
            interval_count <= 8'd0;
        end
        else begin
            peak_start_flag <= 1'd0;
            // 消除瞬态波动
            interval_count <= (interval_count >= INTERVAL) ? INTERVAL : interval_count + 1;
        end
    end

endmodule

