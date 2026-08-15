////////////////////////////

module top_tb;

    reg         hclk;
    reg         hresetn;
    reg         hselapb;
    reg         hwrite;
    reg [1:0]   htrans;
    reg [31:0]  haddr;
    reg [31:0]  hwdata;

    wire        hresp;
    wire        hready;
    wire [31:0] hrdata;

    
    top DUT (
        .hclk     (hclk),
        .hresetn  (hresetn),
        .hselapb  (hselapb),
        .hwrite   (hwrite),
        .htrans   (htrans),
        .haddr    (haddr),
        .hwdata   (hwdata),
        .hrdata   (hrdata),
        .hready   (hready),
        .hresp    (hresp)
    );

   
    initial begin
        hclk = 1'b0;
        forever #5 hclk = ~hclk;
    end

   
    task ahb_write(input [31:0] address, input [31:0] data);
    begin
        @(posedge hclk);
        hselapb = 1'b1;
        hwrite  = 1'b1;
        htrans  = 2'b10;   // NONSEQ
        haddr   = address;
        hwdata  = data;

        @(posedge hclk);
        hselapb = 1'b1;
        hwrite  = 1'b1;
        htrans  = 2'b10;

        @(posedge hclk);
        hselapb = 1'b0;
        hwrite  = 1'b0;
        htrans  = 2'b00;
        haddr   = 32'b0;
        hwdata  = 32'b0;

        #10;
    end
    endtask

    
    task ahb_read(input [31:0] address);
    begin
        @(posedge hclk);
        hselapb = 1'b1;
        hwrite  = 1'b0;
        htrans  = 2'b10;   // NONSEQ
        haddr   = address;

        @(posedge hclk);
        hselapb = 1'b1;
        hwrite  = 1'b0;
        htrans  = 2'b10;

        @(posedge hclk);
        hselapb = 1'b0;
        hwrite  = 1'b0;
        htrans  = 2'b00;
        haddr   = 32'b0;

        #10;
    end
    endtask

   
    initial begin
        hresetn = 1'b0;
        hselapb = 1'b0;
        hwrite  = 1'b0;
        htrans  = 2'b00;
        haddr   = 32'b0;
        hwdata  = 32'b0;

        #20;
        hresetn = 1'b1;
        #20;

        
        ahb_write(32'h0000_0020, 32'h0000_0055);

        
        ahb_read(32'h0000_0020);

       
        ahb_write(32'h0000_0020, 32'h0000_00AA);
        ahb_read(32'h0000_0020);

        #50;
        $finish;
    end

    // ---------------------------------------------------------------
    // FIFO activity monitor
    // (valid now that DUT = top, since fifo_wr_en/fifo_data_in/etc.
    //  are real internal wires of top)
    // ---------------------------------------------------------------
    always @(posedge hclk) begin
        if (DUT.fifo_wr_en)
            $display("TIME=%0t | FIFO WRITE | DATA=%h", $time, DUT.fifo_data_in);
        if (DUT.fifo_rd_en)
            $display("TIME=%0t | FIFO READ  | DATA=%h", $time, DUT.fifo_data_out);
    end

    // ---------------------------------------------------------------
    // Full bus/APB/FIFO monitor
    // ---------------------------------------------------------------
    always @(posedge hclk) begin
        $display("TIME=%0t HSEL=%b HWRITE=%b HTRANS=%b HADDR=%h HWDATA=%h",
                 $time, hselapb, hwrite, htrans, haddr, hwdata);

        $display("APB: PSEL=%b PENABLE=%b PWRITE=%b PADDR=%h PWDATA=%h",
                 DUT.psel, DUT.penable, DUT.pwrite, DUT.paddr, DUT.pwdata);

        $display("FIFO: SEL=%b WR=%b RD=%b DIN=%h DOUT=%h",
                 DUT.fifo_sel, DUT.fifo_wr_en, DUT.fifo_rd_en,
                 DUT.fifo_data_in, DUT.fifo_data_out);

        $display("HREADY=%b HRDATA=%h", hready, hrdata);
    end

endmodule
