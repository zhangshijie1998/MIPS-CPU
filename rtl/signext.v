`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/28 23:44:26
// Design Name: 
// Module Name: signext
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


module signext (
    input  wire [15:0] a,
    input  wire        b,
    output wire [31:0] y
);

reg [15:0] sigs;

assign y[15:0] = a;
assign y[31:16] = sigs;

always @(*)
case (b)
    1'b0:    sigs = {16{a[15]}};
    1'b1:    sigs = 16'b0;
    default: sigs = 16'b0;
endcase

endmodule
