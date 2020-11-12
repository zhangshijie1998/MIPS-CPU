`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/02 10:28:46
// Design Name: 
// Module Name: WB
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


module WB (
    input  wire        memtoreg,
    input  wire [31:0] readdata,
    input  wire [31:0] aluout,
    output wire [31:0] wdata
);

mux2 mux2 (
    .in0 (aluout),
    .in1 (readdata),
    .sel (memtoreg),
    .out (wdata)
);

endmodule
