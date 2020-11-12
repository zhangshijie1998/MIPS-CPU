`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/29 21:13:49
// Design Name: 
// Module Name: datapath
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


module datapath #(
    parameter DATA_W = 32
)(
    input  wire              clk,
    input  wire              rst,
    input  wire              alusrc,
	input  wire              regdst,
    input  wire              regwrite,
    input  wire [3:0]        alucontrol,
    input  wire              re,
    input  wire              wb,    //wb=1字节操作，8位    wb=0字操作，32位
    input  wire              eq,
    input  wire              jump,
    input  wire              branch,
    input  wire              memtoreg,
    input  wire              memwrite,
    input  wire              sign,
    input  wire              jr,  
    //指令内存信号
    input  wire [DATA_W-1:0] ID_instr,
    output wire              ID_instr_ce,
    output wire              IF_instr_ce,
    output wire [DATA_W-1:0] IF_pc_out,
    //数据内存信号
    output wire [DATA_W-1:0] EX_dataadr,
    output wire [DATA_W-1:0] EX_wdata,    
    output wire              EX_we,
    output wire              EX_oe,
    output reg               EX_wb,    
    output wire [DATA_W-1:0] MEM_dataadr,
    output reg  [DATA_W-1:0] MEM_wdata,
    input  wire [DATA_W-1:0] MEM_rdata, 
    output wire              MEM_we,    
    output wire              MEM_oe, 
    output reg               MEM_wb    
);
//本地参数
localparam ENABLE = 1'b1;
localparam DISABLE = 1'b0;
localparam RESET_ENABLE = 1'b1;
localparam RESET_PC = 32'h8000_0000;
localparam DATA_ZERO = 32'b0;
//小写前缀是用于流水线控制的信号
wire validin;
wire validout;
wire out_allow;

reg  if_valid;
wire if_allin;
wire if_ready_go;
wire if_valid_ns;

reg  id_valid;
wire id_allin;
wire id_ready_go;
wire id_valid_ns;

reg  ex_valid;
wire ex_allin;
wire ex_ready_go;
wire ex_valid_ns;
wire ex_rst;

reg  mem_valid;
wire mem_allin;
wire mem_ready_go;
wire mem_valid_ns;

reg  wb_valid;
wire wb_allin;
wire wb_ready_go;
wire wb_valid_ns;
//IF取指，ID返回
reg  [DATA_W-1:0] IF_pc;
wire [DATA_W-1:0] IF_pcnext;
wire [DATA_W-1:0] IF_pcplus4;
wire              IF_stall;

reg  [DATA_W-1:0] ID_pcplus4;
wire [DATA_W-1:0] ID_rdata1;    
wire [DATA_W-1:0] ID_rdata2;
wire [DATA_W-1:0] ID_signlmm;
wire [19:0]       ID_rsrtrd;  
wire              ID_wb;
wire              ID_eq;
wire              ID_jump;
wire              ID_jr;
wire              ID_alusrc;
wire              ID_regdst;
wire              ID_regwrite;
wire [3:0]        ID_alucontrol;
wire              ID_branch;
wire              ID_memtoreg;
wire              ID_memwrite;
wire              ID_stall;
wire              ID_sign;
wire [DATA_W-1:0] ID_pcbranch;
wire [DATA_W-1:0] ID_pcjump;
wire              ID_pcsrc;
wire              ID_forward1;
wire              ID_forward2;
wire              ID_re;

reg  [DATA_W-1:0] EX_pcplus4;
reg  [DATA_W-1:0] EX_rdata1;
reg  [DATA_W-1:0] EX_rdata2;
reg  [DATA_W-1:0] EX_signlmm;
reg  [19:0]       EX_rsrtrd;
reg               EX_re;
reg               EX_alusrc;
reg               EX_regdst;
reg               EX_regwrite;
reg  [3:0]        EX_alucontrol;
reg               EX_memtoreg;
reg               EX_memwrite;
wire [4:0]        EX_waddr;
wire [DATA_W-1:0] EX_aluout;
wire [1:0]        EX_forward1;
wire [1:0]        EX_forward2;
wire              EX_flush;
wire              EX_zero;
wire              EX_overflow;

reg  [DATA_W-1:0] MEM_aluout;
reg  [4:0]        MEM_waddr;
reg               MEM_zero;
reg               MEM_regwrite;
reg               MEM_memtoreg;
reg               MEM_memwrite;

wire [DATA_W-1:0] WB_readdata;
reg  [DATA_W-1:0] WB_aluout;
reg  [4:0]        WB_waddr;
reg               WB_regwrite;
reg               WB_memtoreg;
wire [DATA_W-1:0] WB_wdata;

assign ID_wb = wb;
assign ID_jr = jr;
assign ID_eq = eq;
assign ID_jump = jump;
assign ID_alusrc = alusrc;
assign ID_regdst = regdst;
assign ID_regwrite = regwrite;
assign ID_alucontrol = alucontrol; 
assign ID_branch = branch;
assign ID_memtoreg = memtoreg;
assign ID_memwrite = memwrite;
assign ID_rsrtrd = ID_instr[25:6];
assign ID_re = re;
assign ID_sign = sign;

assign IF_pc_out   = IF_pcnext;
assign IF_instr_ce = validin;
assign ID_instr_ce = if_valid_ns && id_allin;
assign EX_dataadr  = EX_aluout;
assign EX_we       = EX_memwrite && ex_valid_ns && mem_allin;
assign EX_oe       = EX_memtoreg && ex_valid;
assign MEM_dataadr = MEM_aluout;
assign MEM_we      = MEM_memwrite && mem_valid_ns && wb_allin;
assign MEM_oe      = MEM_memtoreg && mem_valid_ns && wb_allin;

assign WB_readdata = MEM_rdata;
//除了寄存器堆，所有时序电路写在流水线。控制信号和数据分开。
//流水线采用非全局复位，只复位关键部位。其他地方流水线排气泡即可。
//涉及冒险的数据需要复位,不能只控制数据有效位。
//hazard模块里需要有效位。
assign validin = !rst;
assign validout = wb_valid && wb_ready_go;
assign out_allow = ENABLE;

assign if_ready_go = !IF_stall;
assign if_allin = !if_valid || if_ready_go && id_allin;//条件运算符自右向左结合
assign if_valid_ns = if_valid && if_ready_go;
// 控制信号传递
always @(posedge clk or posedge rst) begin
    if (rst == RESET_ENABLE) begin
        if_valid <= DISABLE;
    end else if (if_allin) begin
        if_valid <= validin;
    end
end
// 数据信号传递
always @(posedge clk or posedge rst) begin
    if (rst == RESET_ENABLE) begin
        IF_pc <= RESET_PC;//pc需要复位到8000_0000
    end else if (validin && if_allin) begin
        IF_pc <= IF_pcnext;
    end
end

IF IF (
    .jr       (ID_jr),
    .jump     (ID_jump),
    .pcsrc    (ID_pcsrc),
    .pcvalid  (if_valid_ns),
    .pcjr     (ID_rdata1),
    .pcjump   (ID_pcjump),
    .pcbranch (ID_pcbranch),
    .pc       (IF_pc),
    .pcnext   (IF_pcnext),
    .pcplus4  (IF_pcplus4)
);

assign id_ready_go = !ID_stall;
assign id_allin = !id_valid || id_ready_go && ex_allin;
assign id_valid_ns = id_valid && id_ready_go;
    
always @(posedge clk or posedge rst) begin    
    if (rst == RESET_ENABLE) begin
        id_valid <= DISABLE;
    end else if (id_allin) begin
        id_valid <= if_valid_ns;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst == RESET_ENABLE) begin
        ID_pcplus4 <= DATA_ZERO;
    end else if (if_valid_ns && id_allin) begin
        ID_pcplus4 <= IF_pcplus4;      
    end
end

ID ID (
    .clk         (clk),
    .rst         (rst),
    .regwrite    (WB_regwrite),
    .waddr       (WB_waddr),
    .wdata       (WB_wdata),
    .eq          (ID_eq),
    .instr       (ID_instr),
    .pcplus4     (ID_pcplus4),
    .branch      (ID_branch),
    .sign        (ID_sign),    
    .ID_forward1 (ID_forward1),
    .ID_forward2 (ID_forward2),
    .MEM_aluout  (MEM_aluout),
    .pcsrc       (ID_pcsrc),
    .rdata1      (ID_rdata1),
    .rdata2      (ID_rdata2),
    .signlmm     (ID_signlmm),
    .pcjump      (ID_pcjump),
    .pcbranch    (ID_pcbranch)
);

assign ex_ready_go = ENABLE;
assign ex_allin = !ex_valid || ex_ready_go && mem_allin;
assign ex_valid_ns = ex_valid && ex_ready_go;
//异步复位。复位信号用rst，清零信号用ex_rst。EX_flush也会触发清零  
always @(posedge clk or posedge rst) begin
    if (rst == RESET_ENABLE) begin
        ex_valid <= DISABLE;     
    end else if (EX_flush == RESET_ENABLE) begin
        ex_valid <= DISABLE;         
    end else if (ex_allin) begin
        ex_valid <= id_valid_ns;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst == RESET_ENABLE) begin   
        EX_regwrite <= DISABLE;
        EX_memtoreg <= DISABLE;
        EX_memwrite <= DISABLE; 
        EX_rsrtrd   <= 20'b0;   
    end else if (EX_flush == RESET_ENABLE) begin 
        EX_regwrite <= DISABLE;
        EX_memtoreg <= DISABLE;
        EX_rsrtrd   <= 20'b0;       
    end else if (id_valid_ns && ex_allin) begin
        EX_wb         <=  ID_wb;          
        EX_alusrc     <=  ID_alusrc;   
        EX_regdst     <=  ID_regdst;    
        EX_regwrite   <=  ID_regwrite;  
        EX_alucontrol <=  ID_alucontrol;
        EX_memtoreg   <=  ID_memtoreg;  
        EX_memwrite   <=  ID_memwrite;  
        EX_signlmm    <=  ID_signlmm;   
        EX_rdata1     <=  ID_rdata1;    
        EX_rdata2     <=  ID_rdata2;    
        EX_rsrtrd     <=  ID_rsrtrd;
        EX_pcplus4    <=  ID_pcplus4;
        EX_re         <=  ID_re;
    end
end

EX EX (    
    .re          (EX_re),
    .regdst      (EX_regdst),
    .alusrc      (EX_alusrc),
    .alucontrol  (EX_alucontrol),
    .rsrtrd      (EX_rsrtrd),
    .pcplus4     (EX_pcplus4),
    .signlmm     (EX_signlmm),
    .rdata1      (EX_rdata1),
    .rdata2      (EX_rdata2),
    .MEM_aluout  (MEM_aluout),
    .WB_wdata    (WB_wdata),
    .EX_forward1 (EX_forward1),
    .EX_forward2 (EX_forward2),
    .wdata       (EX_wdata),
    .aluout      (EX_aluout),
    .zero        (EX_zero),
    .overflow    (EX_overflow),
    .waddr       (EX_waddr)
);

assign mem_ready_go = ENABLE;
assign mem_allin = !mem_valid || mem_ready_go && wb_allin;
assign mem_valid_ns = mem_valid && mem_ready_go;

always @(posedge clk or posedge rst) begin
    if (rst == RESET_ENABLE) begin
        mem_valid <= DISABLE;      
    end else if (mem_allin) begin
        mem_valid <= ex_valid_ns;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst == RESET_ENABLE) begin    
        MEM_regwrite <= DISABLE;
        MEM_memtoreg <= DISABLE;
        MEM_memwrite <= DISABLE;
        MEM_wb       <= DISABLE;
        MEM_aluout   <= DATA_ZERO;
        MEM_waddr    <= DATA_ZERO;
        MEM_wdata    <= DATA_ZERO;
    end else if (ex_valid_ns && mem_allin) begin
        MEM_regwrite <= EX_regwrite;    
        MEM_memtoreg <= EX_memtoreg;
        MEM_memwrite <= EX_memwrite;
        MEM_zero     <= EX_zero;    
        MEM_wb       <= EX_wb;      
        MEM_waddr    <= EX_waddr;   
        MEM_aluout   <= EX_aluout;  
        MEM_wdata    <= EX_wdata;   
    end
end

assign wb_ready_go = ENABLE;
assign wb_allin = !wb_valid || wb_ready_go && out_allow;
assign wb_valid_ns = wb_valid && wb_ready_go;

always @(posedge clk or posedge rst) begin
    if (rst == RESET_ENABLE) begin
        wb_valid <= DISABLE;
    end else if (wb_allin) begin
        wb_valid <= mem_valid_ns;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst == RESET_ENABLE) begin
        WB_regwrite <= DISABLE;
        WB_waddr    <= DATA_ZERO; 
    end else if (mem_valid_ns && wb_allin) begin
        WB_regwrite <= MEM_regwrite; 
        WB_memtoreg <= MEM_memtoreg;
        WB_waddr    <= MEM_waddr;     
        WB_aluout   <= MEM_aluout;       
    end
end

WB WB (
    .memtoreg (WB_memtoreg),
    .readdata (WB_readdata),
    .aluout   (WB_aluout),
    .wdata    (WB_wdata)
);

hazard hazard (
    .id_valid     (id_valid),
    .ex_valid     (ex_valid),
    .mem_valid    (mem_valid),
    .wb_valid     (wb_valid),
    .ID_jr        (ID_jr),
    .ID_branch    (ID_branch),
    .ID_rsrtrd    (ID_rsrtrd),
    .EX_rsrtrd    (EX_rsrtrd),
    .EX_memtoreg  (EX_memtoreg),
    .EX_regwrite  (EX_regwrite),
    .EX_waddr     (EX_waddr),
    .MEM_aluout   (MEM_aluout),
    .MEM_memtoreg (MEM_memtoreg),
    .MEM_memwrite (MEM_memwrite),
    .MEM_regwrite (MEM_regwrite),
    .MEM_waddr    (MEM_waddr),
    .WB_regwrite  (WB_regwrite),
    .WB_waddr     (WB_waddr),
    .IF_stall     (IF_stall),
    .ID_stall     (ID_stall),
    .ID_forward1  (ID_forward1),
    .ID_forward2  (ID_forward2),
    .EX_flush     (EX_flush),
    .EX_forward1  (EX_forward1),
    .EX_forward2  (EX_forward2)
);

endmodule
