`timescale 1ns/1ps

module tb_DualFIFO;
  parameter FIFOD  = 8, DATAD  = 8;

  reg clk_w, clk_r, rst;
  reg wr, rd;
  reg [DATAD-1:0] in;
  wire [DATAD-1:0] out;
  wire full, empty;

  FIFO_2clk #(.FIFOD(FIFOD), .DATAD(DATAD)) dut (.clk_r(clk_r), .clk_w(clk_w), .rst(rst), .in(in), .out(out), .wr(wr), .rd(rd), .empty(empty), .full(full));

  initial begin
    clk_w=0; clk_r=0;
    forever #5 clk_w=~clk_w;  // 100 MHz write clock
    forever #7 clk_r=~clk_r; // 71 MHZ read clock
  end

  initial begin
    rst = 1; wr  = 0; rd  = 0; in  = 0;
    #20 rst = 0;

    repeat (5) begin
      @(negedge clk_w);
      if (!full) begin
        in = $random;
        wr = 1;
      end
      @(negedge clk_w);
      wr = 0;
    end
    
    #50;
    repeat (5) begin
      @(negedge clk_r);
      if (!empty) begin
        rd = 1;
      end
      @(negedge clk_r);
      rd = 0;
    end

    repeat (FIFOD+2) begin
      @(negedge clk_w);
      if (!full) begin
        in = $random;
        wr = 1;
      end
      @(negedge clk_w);
      wr = 0;
    end

    repeat (FIFOD+2) begin
      @(negedge clk_r);
      if (!empty) begin
        rd = 1;
      end
      @(negedge clk_r);
      rd = 0;
    end

    #100 $finish;
  end
  
  initial begin
    $monitor("T=%0t | wr=%b rd=%b in=%h out=%h full=%b empty=%b", $time, wr, rd, in, out, full, empty);
  end
endmodule
