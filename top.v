`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2026 07:49:15 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(

    input hclk,
    input hresetn,

    input  hselapb,
    input   hwrite,
    input [1:0]  htrans,
    input [31:0] haddr,
    input [31:0] hwdata,

    output [31:0] hrdata,
    output    hready,
    output        hresp
);

wire    psel;
wire    penable;
wire  pwrite;
wire [31:0] paddr;
wire [31:0] pwdata;

wire [31:0] prdata;

wire uart_sel;
wire gpio_sel;
wire fifo_sel;
wire pwm_sel;

wire [7:0] fifo_prdata;
wire  fifo_pready;
wire       fifo_pslverr;

wire    fifo_wr_en;
wire       fifo_rd_en;
wire [7:0] fifo_data_in;
wire [7:0] fifo_data_out;
wire   fifo_full;
wire     fifo_empty;



bridge_without_pipeline bridge (

    .hclk     (hclk),
    .hresetn  (hresetn),

    .hselapb  (hselapb),
    .hwrite   (hwrite),
    .htrans   (htrans),
    .haddr    (haddr),
    .hwdata   (hwdata),

    .prdata   (prdata),

    .psel     (psel),
    .penable  (penable),
    .pwrite   (pwrite),
    .paddr    (paddr),
    .pwdata   (pwdata),

    .hresp    (hresp),
    .hready   (hready),
    .hrdata   (hrdata)
);



apb_decoder decoder (

    .psel     (psel),
    .paddr    (paddr[7:0]),

    .uart_sel (uart_sel),
    .gpio_sel (gpio_sel),
    .fifo_sel (fifo_sel),
    .pwm_sel  (pwm_sel)
);


apb_slave fifo_slave (

    .clk   (hclk),
    .rst   (~hresetn),

    .psel   (fifo_sel),
    .penable (penable),
    .pwrite (pwrite),
    .pwdata (pwdata[7:0]),

    .prdata  (fifo_prdata),
    .pready    (fifo_pready),
    .pslverr   (fifo_pslverr),

    .wr_en   (fifo_wr_en),
    .rd_en (fifo_rd_en),
    .data_in (fifo_data_in),

    .data_out (fifo_data_out),
    .full      (fifo_full),
    .empty (fifo_empty)
);

FIFO fifo (
    .clk(hclk),
    .rst(~hresetn),

    .wr_en(fifo_wr_en),
    .rd_en(fifo_rd_en),
    .data_in(fifo_data_in),

    .data_out(fifo_data_out),
    .full(fifo_full),
    .empty(fifo_empty)
);


assign prdata = {24'b0, fifo_prdata};


endmodule
