`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/10 22:48:19
// Design Name: 
// Module Name: sll
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


module sll (
    input  wire [31:0] in,
    input  wire [ 4:0] sa,
    output wire [31:0] out
);

genvar i;
generate for (i=0; i<32; i=i+1) begin : gen_for_sll
    assign out[i] = (i < sa) ? 0 : (in[i-sa]);
end endgenerate

// genvar i;
// generate for (i=0; i<32; i=i+1) begin : gen_for_sll
    // assign out[i] = (i < sa) ? (in[i+32-sa]) : (in[i-sa]);
// end endgenerate

endmodule
