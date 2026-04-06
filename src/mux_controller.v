`timescale 1 ns / 1 ps
module mux_controller #
    (
        parameter integer HOLD_US      = 1          // 保持时间（以微秒为单位）
    )
    (
        input  wire        sys_clk      ,   // 外部提供250 MHz时钟
        input  wire        sys_rstn     ,   // 异步低电平有效复位
        input  wire [7:0]  cmp_in       ,   // 8 个比较器脉冲输入（通常脉冲~300-500ns）
        input  wire        mux_en       ,
        output reg  [2:0]  mux_sel      ,   // mux_sel_en 置位时的编码通道索引 (0..7)
        output reg         mux_sel_en       // 当通道被锁存时，高电平保持 HOLD_US 微秒
    );

    // -----------------------------------------------------------------------------
    // 为保持计数器导出的参数
    // -----------------------------------------------------------------------------
    localparam integer HOLD_CYCLES = 250 * HOLD_US; //例如，250 *1 = 250 个周期

    // -----------------------------------------------------------------------------
    // 同步比较器输入到 sys_clk（2 级同步）并检测上升沿
    // -----------------------------------------------------------------------------
    reg [7:0] cmp_sync0, cmp_sync1, cmp_sync1_d;
    reg mux_en_sync0,mux_en_sync1,mux_en_d;

    always @(posedge sys_clk or negedge sys_rstn) begin
        if (!sys_rstn) begin
            cmp_sync0 <= 8'b0;
            cmp_sync1 <= 8'b0;
            cmp_sync1_d <= 8'b0;
            mux_en_sync0 <= 1'b0;
            mux_en_sync1 <= 1'b0;
            mux_en_d <= 1'b0;
        end
        else begin
            cmp_sync0 <= cmp_in;
            cmp_sync1 <= cmp_sync0;
            cmp_sync1_d <= cmp_sync1;
            mux_en_sync0 <= mux_en;
            mux_en_sync1 <= mux_en_sync0;
            mux_en_d <= mux_en_sync1;
        end
    end

    wire [7:0] cmp_rise = cmp_sync1 & ~cmp_sync1_d;

    // -----------------------------------------------------------------------------
    // 优先级编码器：选择最低索引位集（0 具有最高优先级）。
    // -----------------------------------------------------------------------------
    integer i;
    reg [2:0] enc_idx;
    reg       any_rise;

    always @(*) begin
        enc_idx = 3'd0;
        any_rise = 1'b0;
        for (i=0; i<8; i=i+1) begin
            if (cmp_rise[i] && !any_rise) begin
                enc_idx = i[2:0];
                any_rise = 1'b1;
            end
        end
    end

    // -----------------------------------------------------------------------------
    //锁存和保持逻辑：检测时断言 mux_sel 和 mux_sel_en，保持 HOLD_CYCLES。
    //当 mux_sel_en 置位时，忽略进一步的比较器事件。
    // -----------------------------------------------------------------------------
    reg [31:0] hold_cnt;
    reg        in_hold;

    always @(posedge sys_clk or negedge sys_rstn) begin
        if (!sys_rstn) begin
            mux_sel <= 3'd0;
            mux_sel_en <= 1'b0;
            hold_cnt <= 32'd0;
            in_hold <= 1'b0;
        end
        else begin
            if (!in_hold && mux_en_d) begin
                if (any_rise) begin
                    mux_sel <= enc_idx;
                    mux_sel_en <= 1'b1;
                    hold_cnt <= HOLD_CYCLES - 1;
                    in_hold <= 1'b1;
                end
                else begin
                    mux_sel_en <= 1'b0;
                end
            end
            else begin
                if (hold_cnt == 0) begin
                    // 保持完成，释放并允许下一次检测
                    mux_sel_en <= 1'b0;
                    in_hold <= 1'b0;
                end
                else begin
                    hold_cnt <= hold_cnt - 1;
                    mux_sel_en <= 1'b1;
                end
            end
        end
    end


endmodule
