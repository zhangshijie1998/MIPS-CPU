`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/10 23:43:56
// Design Name: 
// Module Name: srl
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


module srl (
    input  wire [31:0] in,
    input  wire [ 4:0] sa,
    output wire [31:0] out
);

genvar i;
generate for (i=0; i<32; i=i+1) begin : gen_for_srl
    assign out[i] = (i < (32-sa)) ? (in[i+sa]) : 0;
end endgenerate

// genvar i;
// generate for (i=0; i<32; i=i+1) begin : gen_for_srl
    // assign out[i] = (i < (32-sa)) ? (in[i+sa]) : (in[i+sa-32]);
// end endgenerate

endmodule
