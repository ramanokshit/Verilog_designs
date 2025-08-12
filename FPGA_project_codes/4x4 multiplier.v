module full_adder(input a, b, cin, output sum, cout);
assign sum =a^b^cin;
assign cout =(a&b)|(b&cin)|(a&cin);
endmodule

module multiplier(input[3:0]x,y,output[7:0]z);
wire p10,p20,p30,p01,p11,p21,p31,p02,p12,p22,p32,p03,p13,p23,p33;
wire [12:0]c;
wire [5:0]d;
assign z[0]=x[0]&y[0];
assign p10=x[1]&y[0];
assign p20=x[2]&y[0];
assign p30=~(x[3]&y[0]);
assign p01=x[0]&y[1];
assign p11=x[1]&y[1];
assign p21=x[2]&y[1];
assign p31=~(x[3]&y[1]);
assign p02=x[0]&y[2];
assign p12=x[1]&y[2];
assign p22=x[2]&y[2];
assign p32=~(x[3]&y[2]);
assign p03=~(x[0]&y[3]);
assign p13=~(x[1]&y[3]);
assign p23=~(x[2]&y[3]);
assign p33=x[3]&y[3];
full_adder a0(p01,p10,0,z[1],c[0]);
full_adder a1(p11,p20,c[0],d[0],c[1]);
full_adder a2(p21,p30,c[1],d[1],c[2]);
full_adder a3(p31,1,c[2],d[2],c[3]);
full_adder a4(p02,d[0],0,z[2],c[4]);
full_adder a5(p12,d[1],0,d[3],c[5]);
full_adder a6(p22,d[2],c[5],d[4],c[6]);
full_adder a7(p32,c[3],c[6],d[5],c[7]);
full_adder a8(p03,d[3],0,z[3],c[8]);
full_adder a9(p13,d[4],c[8],z[4],c[9]);
full_adder a10(p23,d[5],c[9],z[5],c[10]);
full_adder a11(p33,c[7],c[10],z[6],c[11]);
full_adder a12(0,1,c[11],z[7],c[12]);
endmodule
