`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/01 22:06:50
// Design Name: 
// Module Name: IF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IF #(
    parameter DATA_W = 32
)(    
    input  wire              jr,
    input  wire              jump,
    input  wire              pcsrc,
    input  wire              pcvalid,
    input  wire [DATA_W-1:0] pcjr,
    input  wire [DATA_W-1:0] pcjump,
    input  wire [DATA_W-1:0] pcbranch,
    input  wire [DATA_W-1:0] pc,
    output reg  [DATA_W-1:0] pcnext,
    output wire [DATA_W-1:0] pcplus4
);

localparam DATA_FOUR = 32'h0000_0004;

wire [3:0] op;

assign op = {pcvalid, pcsrc, jr, jump};

adder adder (
    .a (pc),
    .b (DATA_FOUR),
    .s (pcplus4)
);

always @(*) 
case (op)
    4'b0000: pcnext = pc;
    4'b0001: pcnext = pc;
    4'b0010: pcnext = pc;
    4'b0100: pcnext = pc;
    4'b1000: pcnext = pcplus4;
    4'b1001: pcnext = pcjump;
    4'b1010: pcnext = pcjr;
    4'b1100: pcnext = pcbranch;
    default: pcnext = pc;
endcase

endmodule
