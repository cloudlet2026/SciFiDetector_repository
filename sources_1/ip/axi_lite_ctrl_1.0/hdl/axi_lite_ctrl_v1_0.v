
`timescale 1 ns / 1 ps

	module axi_lite_ctrl_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 5
	)
	(
		// Users to add ports here
		(* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS peak_threshold" *)
        output               [  13: 0]                         peak_threshold             ,
        (* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS peak_threshold_count" *)
        output               [   5: 0]                         peak_threshold_count       ,
        (* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS na" *)
        output               [   8: 0]                         na                         ,
        (* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS nb" *)
        output               [   8: 0]                         nb                         ,
        (* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS a_over_na_mul_a_minus_b" *)
        output       signed  [  31: 0]                         a_over_na_mul_a_minus_b    ,
        (* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS inv_na_mul_a_minus_b" *)
        output       signed  [  31: 0]                         inv_na_mul_a_minus_b       ,
        (* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS b" *)
        output       signed  [  31: 0]                         b                          ,
        (* X_INTERFACE_INFO = "xilinx.com:user:SHAPE_PARAMS:1.0 SHAPE_PARAMS peakext_delay_time" *)
        output               [   8: 0]                         peakext_delay_time         ,
        output                                                 adc_en                     ,
        output                                                 daq_en                     ,
        output                                                 wave_en                    ,
        output                                                 daq_intr_clr               ,
        input                                                  daq_intr_clr_ack           ,
        output                                                 wave_intr_clr              ,
        input                                                  wave_intr_clr_ack          ,
        
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
// Instantiation of Axi Bus Interface S00_AXI
	axi_lite_ctrl_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) axi_lite_ctrl_v1_0_S00_AXI_inst (
		.peak_threshold                     (peak_threshold            ),
		.peak_threshold_count               (peak_threshold_count      ),
		.na                                 (na                        ),
		.nb                                 (nb                        ),
		.a_over_na_mul_a_minus_b            (a_over_na_mul_a_minus_b   ),
		.inv_na_mul_a_minus_b               (inv_na_mul_a_minus_b      ),
		.b                                  (b                         ),
		.peakext_delay_time                 (peakext_delay_time        ),
		.adc_en                             (adc_en                    ),
		.daq_en                             (daq_en                    ),
		.wave_en                            (wave_en                   ),
		.daq_intr_clr                       (daq_intr_clr              ),
		.daq_intr_clr_ack                   (daq_intr_clr_ack          ),
		.wave_intr_clr                      (wave_intr_clr             ),
		.wave_intr_clr_ack                  (wave_intr_clr_ack         ),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
