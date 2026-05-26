module branch_comp (
    input [31:0] a,
    input [31:0] b,
    input        BrUn,
    output       BrEq,
    output       BrLt
);

assign BrEq = (a==b);
assign BrLt = BrUn? (a < b) : ( $signed (a) < $signed (b) );

endmodule 
