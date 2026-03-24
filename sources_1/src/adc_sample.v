
`timescale 1 ns / 1 ps

// -----------------------------------------------------------------------------
// AD9238为12位ADC，测量范围是-5V~+5V，转换后的数字范围是0~+4096
// 将ADC输出转换为14位有符号数(映射到-2048~+2048范围)，并通过FIFO（256深度）缓存
// -----------------------------------------------------------------------------
    module adc_sample (
        input                                                  sys_clk                    ,
        input                                                  sys_rstn                   ,
        input                                                  adc_en                     ,
        input                [  11: 0]                         adc_data                   ,
        output       signed  [  13: 0]                         adc_fifo_data              ,
        output                                                 adc_oe                     ,
        (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 adc_clk CLK" *)
        (* X_INTERFACE_PARAMETER = "FREQ_HZ 66666672" *)  // 66.666672 MHz
        output                                                 adc_clk
    );

    wire    signed     [  13: 0]                         adc_data_signed             ;
    wire                                                 global_rstn                 ;
    wire                                                 rd_clk                      ;
    assign                              global_rstn                 = adc_en & sys_rstn;
    assign                              adc_oe                      = ~global_rstn;
    assign                              rd_clk                      = sys_clk;
    assign                              adc_clk                     = ~sys_clk;
    fifo_generator_adc u_fifo_generator_adc (
                         .clk                                (rd_clk                    ),// input wire clk
                         .srst                               (~global_rstn              ),// input wire srst
                         .din                                (adc_data_signed           ),// input wire [13 : 0] din
                         .wr_en                              (global_rstn               ),// input wire wr_en
                         .rd_en                              (global_rstn               ),// input wire rd_en
                         .dout                               (adc_fifo_data             ),// output wire [13 : 0] dout
                         .full                               (                          ),// output wire full
                         .empty                              (                          ) // output wire empty
                     );
    // 将ADC输出转换为为14位有符号数
    // 先零扩展到14位，再减偏移量，最后转为有符号
    wire [13:0] adc_data_offset;
    assign adc_data_offset = {2'b00, adc_data} - 14'd2048;
    assign adc_data_signed = $signed(adc_data_offset);
    
    endmodule
