`timescale 1ns/1ps
module Barrelshift_tb;
  parameter DEPTH = 8;
  
  reg Di;
  reg [($clog2(DEPTH)-1):0] n;
  reg [(DEPTH-1):0] I;
  wire [(DEPTH-1):0] Out;

  Barrelshift #(DEPTH) uut ( .Out(Out), .Di(Di), .n(n), .I(I));

  initial begin
    $monitor("Time=%0t | Di=%b | n=%0d | I=%b | Out=%b", $time, Di, n, I, Out);

    //Left Shift
    I = 8'b10110011; n = 0; Di = 1; #10; // shift by 0
    I = 8'b10110011; n = 1; Di = 1; #10; // shift by 1
    I = 8'b10110011; n = 2; Di = 1; #10; // shift by 2
    I = 8'b10110011; n = 3; Di = 1; #10; // shift by 3

    //Right shift
    I = 8'b10110011; n = 1; Di = 0; #10; // shift by 1
    I = 8'b10110011; n = 2; Di = 0; #10; // shift by 2
    I = 8'b10110011; n = 3; Di = 0; #10; // shift by 3
    I = 8'b10110011; n = 7; Di = 0; #10; // shift by 7
    $finish;
  end

endmodule
