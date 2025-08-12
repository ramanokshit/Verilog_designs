module mult_tb ();
  logic [3:0] x,y;
  logic [7:0] prod;

  multiplier a1(x,y,prod);

  initial begin
    x=0;y=0;
    #9 $display("x=%d, y=%d, prod=%d",x,y,prod);
    #1 x=-4; y=5;
    #9 $display("x=%d, y=%d, prod=%d",x,y,prod);
    #1 x=5; y=6;
    #9 $display("x=%d, y=%d, prod=%d",x,y,prod);
    #1 x=-4; y=2;
    #9 $display("x=%d, y=%d, prod=%d",x,y,prod);
    #10 $stop;
  end
endmodule
