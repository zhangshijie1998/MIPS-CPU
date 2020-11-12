`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/02 10:28:46
// Design Name: 
// Module Name: EX
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


module EX (
    input  wire        re,
    input  wire        regdst,
    input  wire        alusrc,
    input  wire [ 3:0] alucontrol,
    input  wire [19:0] rsrtrd,
    input  wire [31:0] pcplus4,
    input  wire [31:0] signlmm,
    input  wire [31:0] rdata1,
    input  wire [31:0] rdata2,
    input  wire [31:0] MEM_aluout,
    input  wire [31:0] WB_wdata,
    input  wire [ 1:0] EX_forward1,
    input  wire [ 1:0] EX_forward2,
    output wire [31:0] wdata,
    output wire [31:0] aluout,
    output wire        zero,
    output wire        overflow,
    output wire [ 4:0] waddr
);

wire [31:0] srca;
wire [31:0] srcb;
wire [31:0] srca_temp;
wire [31:0] srcb_temp;
wire [ 4:0] waddr_temp;
wire [ 4:0] rs;
wire [ 4:0] rt;
wire [ 4:0] rd;
wire [ 4:0] sa;

assign rs = rsrtrd[19:15];
assign rt = rsrtrd[14:10];
assign rd = rsrtrd[ 9:5];
assign sa = rsrtrd[ 4:0];

alu alu (
    .num1     (srca),
    .num2     (srcb),
    .sa       (sa),
    .op       (alucontrol),
    .result   (aluout),
    .zero     (zero),
    .overflow (overflow)
);

mux2 mux2_1 (
    .in0 (wdata),
    .in1 (signlmm),
    .sel (alusrc),
    .out (srcb_temp)
);

mux2 mux2_2 (
    .in0 (srcb_temp),
    .in1 (pcplus4),
    .sel (re),
    .out (srcb)
);

mux2 mux2_3 (
    .in0 (srca_temp),
    .in1 (32'h4),
    .sel (re),
    .out (srca)
);

mux2 #(5) mux2_4 (
    .in0 (rt),
    .in1 (rd),
    .sel (regdst),
    .out (waddr_temp)
);

mux2 #(5) mux2_5 (
    .in0 (waddr_temp),
    .in1 (5'b11111),
    .sel (re),
    .out (waddr)
);

mux3 mux3_1 (
    .in0 (rdata1),
    .in1 (WB_wdata),
    .in2 (MEM_aluout),
    .sel (EX_forward1),
    .out (srca_temp)
);

mux3 mux3_2 (
    .in0 (rdata2),
    .in1 (WB_wdata),
    .in2 (MEM_aluout),
    .sel (EX_forward2),
    .out (wdata)
);

endmodule
