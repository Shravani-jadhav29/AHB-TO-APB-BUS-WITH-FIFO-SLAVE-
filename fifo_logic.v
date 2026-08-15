`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2026 07:46:47 PM
// Design Name: 
// Module Name: FIFO
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


module FIFO(

    input   clk,
    input   rst,
    input     wr_en,
    input    rd_en,
    input  [7:0] data_in,
    output [7:0] data_out,
    output   full,
    output  empty
);

    reg [7:0] mem [7:0];
    reg [2:0] wr_ptr;
    reg [2:0] rd_ptr;
    reg [3:0] count;
    integer   i;

    wire do_write = wr_en && !full;
    wire do_read  = rd_en && !empty;

    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 3'd0;
            rd_ptr <= 3'd0;
            count  <= 4'd0;
            for (i = 0; i < 8; i = i + 1)
                mem[i] <= 8'd0;
        end
        else begin
            if (do_write) begin
                mem[wr_ptr] <= data_in;
                wr_ptr      <= wr_ptr + 1'b1;
            end

            if (do_read)
                rd_ptr <= rd_ptr + 1'b1;

            case ({do_write, do_read})
                2'b10:   count <= count + 1'b1;   // write only
                2'b01:   count <= count - 1'b1;   // read only
                default: count <= count;          // both or neither -> unchanged
            endcase
        end
    end

    assign data_out = mem[rd_ptr];   // combinational look-ahead of the head entry
    assign full      = (count == 4'd8);
    assign empty     = (count == 4'd0);

endmodule
