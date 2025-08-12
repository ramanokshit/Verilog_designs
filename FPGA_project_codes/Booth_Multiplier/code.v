module MAIN (input signed [5:0] A,B,output reg signed [11:0] P);
reg signed [5:0] M, Q;
reg Q_1;
reg [5:0] Acc;
reg [2:0] count;
  
always @(*) begin
M = A;
Q = B;
Q_1 = 0;
Acc = 0;
count = 6;
repeat (6) begin
case ({Q[0], Q_1})
2'b01: Acc = Acc + M;
2'b10: Acc = Acc – M;
endcase
{Acc, Q, Q_1} = {Acc[5], Acc, Q};
count = count - 1;
end
P = {Acc,Q};
end
endmodule
