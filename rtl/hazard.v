`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/02 23:52:35
// Design Name: 
// Module Name: hazard
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


module hazard (
    input  wire        id_valid,
    input  wire        ex_valid,
    input  wire        mem_valid,
    input  wire        wb_valid,
    input  wire        ID_jr,
    input  wire        ID_branch,
    input  wire [19:0] ID_rsrtrd,
    input  wire [19:0] EX_rsrtrd,
    input  wire        EX_memtoreg,
    input  wire        EX_regwrite,
    input  wire [ 4:0] EX_waddr,
    input  wire [31:0] MEM_aluout,
    input  wire        MEM_memtoreg,
    input  wire        MEM_memwrite,
    input  wire        MEM_regwrite,
    input  wire [ 4:0] MEM_waddr,
    input  wire        WB_regwrite,
    input  wire [ 4:0] WB_waddr,
    output wire        IF_stall,
    output wire        ID_stall,
    output reg         ID_forward1,
    output reg         ID_forward2,
    output wire        EX_flush,
    output reg  [ 1:0] EX_forward1,
    output reg  [ 1:0] EX_forward2
);

localparam UART1 = 32'hbfd003f8;
localparam UART2 = 32'hbfd003fc;

wire [ 4:0] ID_rs, ID_rt, ID_rd;
wire [ 4:0] EX_rs, EX_rt, EX_rd;
wire        lwstall;
wire        branchstall;
wire        jrstall;
wire        pcstall;
wire        id_valid_ex;
wire        id_valid_mem;
wire        ex_valid_mem;
wire        ex_valid_wb;

assign uart = (MEM_aluout == UART1) || (MEM_aluout == UART2);
assign ID_rs = ID_rsrtrd[19:15];
assign ID_rt = ID_rsrtrd[14:10];
assign ID_rd = ID_rsrtrd[ 9:5];
assign EX_rs = EX_rsrtrd[19:15];
assign EX_rt = EX_rsrtrd[14:10];
assign EX_rd = EX_rsrtrd[ 9:5];
assign id_valid_ex = id_valid && ex_valid;
assign id_valid_mem = id_valid && mem_valid;
assign ex_valid_mem = ex_valid && mem_valid;
assign ex_valid_wb = ex_valid && wb_valid;
assign lwstall = ((ID_rs==EX_rt) || (ID_rt==EX_rt)) && EX_memtoreg && id_valid_ex;
assign branchstall =  (ID_branch && EX_regwrite && ((ID_rs==EX_waddr)||(ID_rt==EX_waddr)) && id_valid_ex)
                   || (ID_branch && MEM_memtoreg && ((ID_rs==MEM_waddr)||(ID_rt==MEM_waddr)) && id_valid_mem);
assign jrstall =  (ID_jr && EX_regwrite && (ID_rs==EX_waddr) && id_valid_ex)
               || (ID_jr && MEM_memtoreg && (ID_rs==MEM_waddr) && id_valid_mem); 
// assign jrstall = 0;               
assign pcstall = !(uart || MEM_aluout[22] || (!MEM_memwrite && !MEM_memtoreg)) && mem_valid;               
assign IF_stall = lwstall || branchstall || jrstall || pcstall;
assign ID_stall = lwstall || branchstall || jrstall || pcstall;
assign EX_flush = lwstall || branchstall || jrstall || pcstall;

always @(*) begin
    if ((ID_rs!=5'b0) && (ID_rs==MEM_waddr) && MEM_regwrite && id_valid_mem)
        ID_forward1 <= 1'b1;
    else
        ID_forward1 <= 1'b0;
end

always @(*) begin
    if ((ID_rt!=5'b0) && (ID_rt==MEM_waddr) && MEM_regwrite && id_valid_mem)
        ID_forward2 <= 1'b1;
    else
        ID_forward2 <= 1'b0;
end
//可能会存在冲突，只要往同一单元连续写多次
always @(*) begin
    if ((EX_rs!=5'b0) && (EX_rs==MEM_waddr) && MEM_regwrite && ex_valid_mem)
        EX_forward1 <= 2'b10;
    else if ((EX_rs!=5'b0) && (EX_rs==WB_waddr) && WB_regwrite && ex_valid_wb) 
        EX_forward1 <= 2'b01;
    else
        EX_forward1 <= 2'b00;
end

always @(*) begin
    if ((EX_rt!=5'b0) && (EX_rt==MEM_waddr) && MEM_regwrite && ex_valid_mem)
        EX_forward2 <= 2'b10;
    else if ((EX_rt!=5'b0) && (EX_rt==WB_waddr) && WB_regwrite && ex_valid_wb) 
        EX_forward2 <= 2'b01;
    else
        EX_forward2 <= 2'b00;
end

endmodule
