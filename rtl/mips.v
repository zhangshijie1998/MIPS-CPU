`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/29 20:37:21
// Design Name: 
// Module Name: mips
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


module mips (
    input  wire        clk,
    input  wire        rst,
    //指令内存信号
    input  wire [31:0] ID_instr,
    output wire        ID_instr_ce,
    output wire        IF_instr_ce,
    output wire [31:0] IF_pc_out,
    //数据内存信号
    output wire [31:0] EX_dataadr,
    output wire [31:0] EX_wdata,   
    output wire        EX_we,
    output wire        EX_oe,
    output wire        EX_wb,    
    output wire [31:0] MEM_dataadr,
    output wire [31:0] MEM_wdata,
    input  wire [31:0] MEM_rdata, 
    output wire        MEM_we,    
    output wire        MEM_oe, 
    output wire        MEM_wb    
);

wire        re;
wire        wb;
wire        eq;
wire        memwrite;
wire        memtoreg;
wire        alusrc;
wire        regdst; 
wire        regwrite;
wire        jump;
wire        branch;
wire [ 3:0] alucontrol;
wire        sign;
wire        jr;

controller controller (
    .instr      (ID_instr),
    .re         (re),
    .wb         (wb),
    .eq         (eq),
    .jump       (jump),
    .branch     (branch),
    .alusrc     (alusrc),
    .memwrite   (memwrite),
    .memtoreg   (memtoreg),
    .regwrite   (regwrite),
    .regdst     (regdst),
    .alucontrol (alucontrol),
    .sign       (sign),
    .jr         (jr)
);

datapath datapath (
    .clk          (clk),
    .rst          (rst),
    .alusrc       (alusrc),
	.regdst       (regdst),
    .regwrite     (regwrite),
    .alucontrol   (alucontrol), 
    .re           (re),
    .wb           (wb),
    .eq           (eq),
    .jump         (jump),
    .branch       (branch),
    .memtoreg     (memtoreg),
    .memwrite     (memwrite),
    .sign         (sign),
    .jr           (jr),   
    .ID_instr     (ID_instr),
    .ID_instr_ce  (ID_instr_ce),
    .IF_instr_ce  (IF_instr_ce),
    .IF_pc_out    (IF_pc_out),
    .EX_dataadr   (EX_dataadr),
    .EX_wdata     (EX_wdata),  
    .EX_we        (EX_we),
    .EX_oe        (EX_oe),
    .EX_wb        (EX_wb),    
    .MEM_dataadr  (MEM_dataadr),
    .MEM_wdata    (MEM_wdata),
    .MEM_rdata    (MEM_rdata), 
    .MEM_we       (MEM_we),    
    .MEM_oe       (MEM_oe), 
    .MEM_wb       (MEM_wb)    
);

endmodule
