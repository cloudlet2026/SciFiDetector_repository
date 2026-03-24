// (c) Copyright 1995-2026 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:dmca:1.0
// IP Revision: 1

(* X_CORE_INFO = "dmca,Vivado 2018.3" *)
(* CHECK_LICENSE_TYPE = "design_1_dmca_0_0,dmca,{}" *)
(* CORE_GENERATION_INFO = "design_1_dmca_0_0,dmca,{x_ipProduct=Vivado 2018.3,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=dmca,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_dmca_0_0 (
  peak_threshold,
  peak_threshold_count,
  na,
  nb,
  a_over_na_mul_a_minus_b,
  inv_na_mul_a_minus_b,
  b,
  peakext_delay_time,
  sys_clk,
  sys_rstn,
  alg_en,
  adc_fifo_data,
  peak_value_ok,
  peak_value,
  trapezd_data,
  triangle_data
);

(* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS peak_threshold" *)
input wire [13 : 0] peak_threshold;
(* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS peak_threshold_count" *)
input wire [5 : 0] peak_threshold_count;
(* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS na" *)
input wire [8 : 0] na;
(* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS nb" *)
input wire [8 : 0] nb;
(* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS a_over_na_mul_a_minus_b" *)
input wire [31 : 0] a_over_na_mul_a_minus_b;
(* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS inv_na_mul_a_minus_b" *)
input wire [31 : 0] inv_na_mul_a_minus_b;
(* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS b" *)
input wire [31 : 0] b;
(* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS peakext_delay_time" *)
input wire [8 : 0] peakext_delay_time;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sys_clk, ASSOCIATED_RESET sys_rstn, FREQ_HZ 66666672, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 sys_clk CLK" *)
input wire sys_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sys_rstn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 sys_rstn RST" *)
input wire sys_rstn;
input wire alg_en;
input wire [13 : 0] adc_fifo_data;
output wire peak_value_ok;
output wire [13 : 0] peak_value;
output wire [17 : 0] trapezd_data;
output wire [17 : 0] triangle_data;

  dmca inst (
    .peak_threshold(peak_threshold),
    .peak_threshold_count(peak_threshold_count),
    .na(na),
    .nb(nb),
    .a_over_na_mul_a_minus_b(a_over_na_mul_a_minus_b),
    .inv_na_mul_a_minus_b(inv_na_mul_a_minus_b),
    .b(b),
    .peakext_delay_time(peakext_delay_time),
    .sys_clk(sys_clk),
    .sys_rstn(sys_rstn),
    .alg_en(alg_en),
    .adc_fifo_data(adc_fifo_data),
    .peak_value_ok(peak_value_ok),
    .peak_value(peak_value),
    .trapezd_data(trapezd_data),
    .triangle_data(triangle_data)
  );
endmodule
