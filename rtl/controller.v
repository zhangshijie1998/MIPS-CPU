`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/26 16:56:55
// Design Name: 
// Module Name: controller
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


module controller (
    input  wire [31:0] instr,
    output wire        re,
    output wire        wb,
    output wire        eq,
    output wire        jump,
    output wire        branch,
    output wire        alusrc,
    output wire        memwrite,
    output wire        memtoreg,
    output wire        regwrite,
    output wire        regdst,
    output wire [ 3:0] alucontrol,
    output wire        sign,
    output wire        jr
);

wire [2:0] aluop;

main_decoder main_decoder (
    .op       (instr[31:26]),
    .re       (re),
    .wb       (wb),
    .eq       (eq),
    .jump     (jump),
    .branch   (branch),
    .alusrc   (alusrc),
    .memwrite (memwrite),
    .memtoreg (memtoreg),
    .regwrite (regwrite),
    .regdst   (regdst),
    .aluop    (aluop)
);

alu_decoder alu_decoder (
    .funct      (instr[5:0]),
    .aluop      (aluop),
    .alucontrol (alucontrol),
    .sign       (sign),
    .jr         (jr)
);

endmodule
