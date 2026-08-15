`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2026 07:12:34 PM
// Design Name: 
// Module Name: bridge_without_pipeline
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




module bridge_without_pipeline(

    input  hclk,
    input  hresetn,

    input      hselapb,
    input   hwrite,
    input [1:0]  htrans,
    input [31:0] haddr,
    input [31:0] hwdata,

    input [31:0] prdata,

    output reg   psel,
    output reg    penable,
    output reg   pwrite,
    output reg [31:0] paddr,
    output reg [31:0] pwdata,

    output reg  hresp,
    output reg   hready,     // hready = 1 (slave is ready to accept the data)
    output reg [31:0] hrdata
);

    parameter IDLE   = 3'b000;
    parameter READ   = 3'b001;
    parameter WWAIT  = 3'b010;
    parameter WRITE  = 3'b011;
    parameter WENABLE = 3'b100;

    reg [2:0] present_state;
    reg [2:0] next_state;

    reg [31:0] haddr_temp;
    reg [31:0] hwdata_temp;

    reg valid, hwrite_temp;

   
    always @(*) begin
        if (hselapb && ((htrans == 2'b10) || (htrans == 2'b11)))
            valid = 1'b1;
        else
            valid = 1'b0;
    end

   
    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            present_state <= IDLE;
            haddr_temp    <= 32'b0;
            hwdata_temp   <= 32'b0;
            hwrite_temp   <= 1'b0;
        end
        else begin
            present_state <= next_state;

            if (present_state == IDLE && valid) begin
                haddr_temp  <= haddr;
                hwdata_temp <= hwdata;
                hwrite_temp <= hwrite;
            end
        end
    end

    
    always @(*) begin

      
        psel       = 1'b0;
        penable    = 1'b0;
        pwrite     = 1'b0;
        paddr      = 32'b0;
        pwdata     = 32'b0;
        hready     = 1'b0;
        hresp      = 1'b0;
        hrdata     = 32'b0;
        next_state = present_state;

        case (present_state)

            IDLE: begin
                psel    = 1'b0;
                penable = 1'b0;
                hready  = 1'b1;

                if (valid == 1'b0)
                    next_state = IDLE;
                else if (hwrite == 1'b0)
                    next_state = READ;
                else
                    next_state = WWAIT;
            end

            READ: begin
                psel    = 1'b1;
                penable = 1'b1;
                pwrite  = 1'b0;
                paddr   = haddr_temp;
                hrdata  = prdata;
                hready  = 1'b1;

                if (valid == 1'b1 && hwrite == 1'b0)
                    next_state = READ;
                else if (valid == 1'b1 && hwrite == 1'b1)
                    next_state = WWAIT;
                else
                    next_state = IDLE;
            end

            WWAIT: begin
                psel    = 1'b0;
                penable = 1'b0;
                hready  = 1'b0;

                next_state = WRITE;
            end

            WRITE: begin
                psel    = 1'b1;
                paddr   = haddr_temp;
                pwdata  = hwdata_temp;
                pwrite  = 1'b1;
                penable = 1'b0;
                hready  = 1'b0;

                next_state = WENABLE;
            end

            WENABLE: begin
                psel    = 1'b1;
                penable = 1'b1;
                pwrite  = 1'b1;
                paddr   = haddr_temp;
                pwdata  = hwdata_temp;
                hready  = 1'b1;

                if (valid == 1'b1 && hwrite == 1'b0)
                    next_state = READ;
                else if (valid == 1'b1 && hwrite == 1'b1)
                    next_state = WWAIT;
                else
                    next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end

endmodule
