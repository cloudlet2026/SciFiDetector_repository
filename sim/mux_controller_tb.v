`timescale 1 ns / 1 ps
module mux_controller_tb;
    // inports reg
    reg        	sys_clk;
    reg        	sys_rstn;
    reg [7:0]    cmp_in;
    reg          mux_en;
    // outports wire
    wire [2:0] 	mux_sel;
    wire       	mux_sel_en;

    mux_controller #(
                       .HOLD_US 	( 1         ))
                   u_mux_controller(
                       .sys_clk     	( sys_clk ),
                       .sys_rstn     	( sys_rstn    ),
                       .mux_en          ( mux_en   ),
                       .cmp_in      	( cmp_in   ),
                       .mux_sel     	( mux_sel      ),
                       .mux_sel_en  	( mux_sel_en   )
                   );

    initial begin
        sys_clk = 0;
        forever
            #2 sys_clk = ~sys_clk; // 250 MHz 时钟周期为 4 ns
    end
    initial begin
        $dumpfile("e:/workspace/Vivado/vivado2018.3/SciFiMuonDetector/user/sim/mux_controller.vcd");
        $dumpvars(0, mux_controller_tb);
        // 初始化信号
        sys_rstn = 0;
        mux_en = 0;
        cmp_in = 8'b00000000;

        // 释放复位
        #10;
        sys_rstn = 1;
        mux_en = 1;

        // 产生比较器脉冲
        #500;
        cmp_in = 8'b00000010; // 通道 1 上升沿
        #400;
        cmp_in = 8'b00000000; // 脉冲结束

        #2000;
        cmp_in = 8'b00000100; // 通道 2 上升沿

        #300;
        cmp_in = 8'b00000110; // 通道 1 上升沿
        #100;
        cmp_in = 8'b00000010; // 通道 1 结束
        #300;
        cmp_in = 8'b00000000; // 脉冲结束

        #2000;
        cmp_in = 8'b00000010; // 通道 6 上升沿
        #300;
        cmp_in = 8'b00000000; // 脉冲结束
        // 等待一段时间以观察输出
        #10000;
        $finish();

    end

endmodule
