`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/02 10:28:46
// Design Name: 
// Module Name: ID
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


module ID (
    input  wire        clk,
    input  wire        rst,
    input  wire        regwrite,
    input  wire [ 4:0] waddr,
    input  wire [31:0] wdata,
    input  wire        eq,
    input  wire [31:0] instr,
    input  wire [31:0] pcplus4,
    input  wire        branch,
    input  wire        sign,
    input  wire        ID_forward1,
    input  wire        ID_forward2,   
    input  wire [31:0] MEM_aluout,
    output wire        pcsrc,
    output wire [31:0] rdata1,
    output wire [31:0] rdata2,
    output wire [31:0] signlmm,
    output wire [31:0] pcjump,
    output wire [31:0] pcbranch
);

wire [31:0] sl2_1in;
wire [31:0] sl2_1out;
wire [31:0] temp1;
wire [31:0] temp2;

assign sl2_1in = signlmm;
assign pcjump = {pcplus4[31:28], instr[25:0], 2'b00};
assign pcsrc = eq ? ((rdata1==rdata2) && branch)
                  : ((rdata1!=rdata2) && branch);

regfile regfile (
    .clk    (~clk),
    .rst    (rst),
    .raddr1 (instr[25:21]),
    .rdata1 (temp1),
    .raddr2 (instr[20:16]),
    .rdata2 (temp2),
    .we     (regwrite),     
    .waddr  (waddr),
    .wdata  (wdata)
);

signext signext (
    .a (instr[15:0]),
    .b (sign),
    .y (signlmm)
);

sl2 sl2_1 (
    .a (sl2_1in),
    .y (sl2_1out)
);

adder adder (
    .a (sl2_1out),
    .b (pcplus4),
    .s (pcbranch)
);

mux2 mux2_1 (
    .in0 (temp1),
    .in1 (MEM_aluout),
    .sel (ID_forward1),
    .out (rdata1)
);

mux2 mux2_2 (
    .in0 (temp2),
    .in1 (MEM_aluout),
    .sel (ID_forward2),
    .out (rdata2)
);

endmodule
