`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2026 07:44:55 PM
// Design Name: 
// Module Name: apb_slave
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


module apb_slave(

    input  wire clk,
    input  wire   rst,
   
    input  wire    psel,
    input  wire   penable,
    input  wire  pwrite,
    input  wire [31:0] pwdata,
    output wire [31:0] prdata,
    output wire   pready,
    output wire    pslverr,
    
    output wire   wr_en,
    output wire rd_en,
    output wire [7:0]  data_in,
    input  wire [7:0]  data_out,
    input  wire   full,
    input  wire    empty
);

    wire access = psel && penable;

    assign wr_en   = access &&  pwrite && !full;
    assign rd_en   = access && !pwrite && !empty;
    assign data_in = pwdata[7:0];

    assign prdata  = {24'b0, data_out};
    assign pready  = 1'b1;
    assign pslverr = access && ((pwrite && full) || (!pwrite && empty));

endmodule
