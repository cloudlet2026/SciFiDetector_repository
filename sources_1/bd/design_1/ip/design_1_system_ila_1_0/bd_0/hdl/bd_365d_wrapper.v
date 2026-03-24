//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_365d_wrapper.bd
//Design : bd_365d_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_365d_wrapper
   (clk,
    probe0,
    probe1,
    probe2);
  input clk;
  input [0:0]probe0;
  input [2:0]probe1;
  input [7:0]probe2;

  wire clk;
  wire [0:0]probe0;
  wire [2:0]probe1;
  wire [7:0]probe2;

  bd_365d bd_365d_i
       (.clk(clk),
        .probe0(probe0),
        .probe1(probe1),
        .probe2(probe2));
endmodule
