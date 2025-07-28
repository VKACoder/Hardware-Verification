module FA (
  input A, B, Cin,
  output sum, cout
);
  assign sum = A ^ B ^ Cin;
  assign cout = (A && B) || (B && Cin) || (A && Cin);
  
endmodule

module addsub (
  input [3:0] A, B,
  input Cin,
  output [3:0] sum,
  output cout
);
  
  wire [3:0] B_ = B ^ {4{Cin}};
  wire [4:0] C;
  
  assign C[0] = Cin;
  
  genvar i;
  
  generate 
    for (i = 0; i < 4; i++) begin
      FA fa(A[i], B_[i], C[i], sum[i], C[i+1]);
    end
  endgenerate
  
  assign cout = C[4] ^ Cin;
  
endmodule  
