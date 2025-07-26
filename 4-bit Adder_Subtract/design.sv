module FA (
  input A, B, Cin,
  output sum, cout
);
  assign sum = A ^ B ^ Cin;
  assign cout = (A && B) || (B && Cin) || (A && Cin);
  
endmodule

