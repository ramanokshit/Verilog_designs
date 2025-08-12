module Booth_Multiplier #(parameter n=10)(input signed [n-1:0] M, Q, input rst, output reg signed [2*n-1:0] P);
  reg signed [n-1:0]A,Q1;
  integer i;
  localparam k=$clog2(n);
  reg q;
  always@(posedge rst) begin
    A<=0; q<=0;Q1<=Q;
  for(i=0; i<n; i=i+1) begin
    case({Q1[0],q})
      2'b10:A<=A-M;
      2'b01:A<=A+M;
      default:A<=A;
    endcase
    {A,Q1,q}={A,Q1,q}>>1;
  end
  P={A,Q1};
  end
endmodule

