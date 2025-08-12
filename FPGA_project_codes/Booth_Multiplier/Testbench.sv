module bm_tb #(parameter n=10)();
  logic signed [n-1:0] A1, A2;
  logic signed [2*n-1:0] Prod;
  
  Booth_Multiplier #(.n(n)) a1(.M(A1),.Q(A2),.P(Prod));
  
  initial begin
    A1=0; A2=0;
    #9 $display("A1=%d A2=%d Prod=%d",A1,A2,Prod);
    #1 A1=-4; A2=14;
    #9 $display("A1=%d A2=%d Prod=%d",A1,A2,Prod);
    #1 A1=218; A2=100;
    #9 $display("A1=%d A2=%d Prod=%d",A1,A2,Prod);
    #1  A1=-100; A2=-400;
    #9 $display("A1=%d A2=%d Prod=%d",A1,A2,Prod);
    #20 $stop;
  end
endmodule
