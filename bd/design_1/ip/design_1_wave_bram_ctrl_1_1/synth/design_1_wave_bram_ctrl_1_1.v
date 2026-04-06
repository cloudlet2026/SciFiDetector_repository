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


// IP VLNV: xilinx.com:user:wave_bram_ctrl:1.0
// IP Revision: 4

(* X_CORE_INFO = "wave_bram_ctrl,Vivado 2018.3" *)
(* CHECK_LICENSE_TYPE = "design_1_wave_bram_ctrl_1_1,wave_bram_ctrl,{}" *)
(* CORE_GENERATION_INFO = "design_1_wave_bram_ctrl_1_1,wave_bram_ctrl,{x_ipProduct=Vivado 2018.3,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=wave_bram_ctrl,x_ipVersion=1.0,x_ipCoreRevision=4,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,BRAM_DATA_WIDTH=32,BRAM_ADDR_WIDTH=32,BRAM_DATA_DEPTH=4096,BRAM_STRB_WIDTH=4}" *)
(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_wave_bram_ctrl_1_1 (
  sys_clk,
  sys_rstn,
  adc_fifo_data,
  addra,
  clka,
  dina,
  douta,
  ena,
  rsta,
  wea,
  wave_en,
  mux_sel_en,
  wave_intr_clr,
  wave_intr,
  wave_intr_clr_ack
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sys_clk, ASSOCIATED_RESET sys_rstn, FREQ_HZ 66666672, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 sys_clk CLK" *)
input wire sys_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sys_rstn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 sys_rstn RST" *)
input wire sys_rstn;
input wire [13 : 0] adc_fifo_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *)
output wire [31 : 0] addra;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *)
output wire clka;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *)
output wire [31 : 0] dina;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *)
input wire [31 : 0] douta;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *)
output wire ena;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA RST" *)
output wire rsta;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 16384, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE BRAM_CTRL, READ_WRITE_MODE READ_WRITE, READ_LATENCY 1" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *)
output wire [3 : 0] wea;
input wire wave_en;
input wire mux_sel_en;
input wire wave_intr_clr;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME wave_intr, SENSITIVITY LEVEL_HIGH, PortWidth 1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 wave_intr INTERRUPT" *)
output wire wave_intr;
output wire wave_intr_clr_ack;

  wave_bram_ctrl #(
    .BRAM_DATA_WIDTH(32),
    .BRAM_ADDR_WIDTH(32),
    .BRAM_DATA_DEPTH(4096),
    .BRAM_STRB_WIDTH(4)
  ) inst (
    .sys_clk(sys_clk),
    .sys_rstn(sys_rstn),
    .adc_fifo_data(adc_fifo_data),
    .addra(addra),
    .clka(clka),
    .dina(dina),
    .douta(douta),
    .ena(ena),
    .rsta(rsta),
    .wea(wea),
    .wave_en(wave_en),
    .mux_sel_en(mux_sel_en),
    .wave_intr_clr(wave_intr_clr),
    .wave_intr(wave_intr),
    .wave_intr_clr_ack(wave_intr_clr_ack)
  );
endmodule
