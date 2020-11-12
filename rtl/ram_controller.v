`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/31 20:17:09
// Design Name: 
// Module Name: ram_controller
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


module ram_controller (
    input  wire        clk,       
    input  wire        rst,
    //PORT 1 取指
    input  wire [31:0] IF_pc,
    input  wire        IF_instr_ce,    
    input  wire        ID_instr_ce,      
    output wire [31:0] ID_instr,
    //PORT 2 访存
    input  wire [31:0] EX_dataadr, 
    input  wire [31:0] EX_wdata,   
    input  wire        EX_we,      
    input  wire        EX_oe,      
    input  wire        EX_wb,       
    input  wire [31:0] MEM_dataadr,
    input  wire [31:0] MEM_wdata,  
    output wire [31:0] MEM_rdata,  
    input  wire        MEM_we,     
    input  wire        MEM_oe,     
    input  wire        MEM_wb,         
    //base_ram信号
    inout  wire [31:0] base_ram_data,   //RAM数据，低8位与CPLD串口控制器共享
    output wire [19:0] base_ram_addr,   //RAM地址
    output wire [ 3:0] base_ram_be_n,   //RAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire        base_ram_ce_n,   //RAM片选，低有效
    output wire        base_ram_oe_n,   //RAM读使能，低有效
    output wire        base_ram_we_n,   //RAM写使能，低有效
    //ext_ram信号
    inout  wire [31:0] ext_ram_data,  
    output wire [19:0] ext_ram_addr,  
    output wire [ 3:0] ext_ram_be_n,   
    output wire        ext_ram_ce_n,   
    output wire        ext_ram_oe_n,  
    output wire        ext_ram_we_n      
);

localparam UART1 = 32'hbfd003f8;
localparam UART2 = 32'hbfd003fc;
localparam RESET_ENABLE = 1'b1;

wire uart1, uart2;
wire stall_n;
wire stop_n;
wire go_n;

assign uart1 = (EX_dataadr == UART1) 
            || (EX_dataadr == UART2);
assign uart2 = (MEM_dataadr == UART1) 
            || (MEM_dataadr == UART2); 
            
assign stall_n = uart1 || EX_dataadr[22] || (!EX_oe && !EX_we);            
// assign stall_n = uart2 || MEM_dataadr[22] || (!MEM_oe && !MEM_we);

assign go_n = stall_n || !stop_n;                        

mem_controller base_mem_controller1 (
    .clk      (clk),    
    .rst      (rst),
    .din      (32'b0),
    .dout     (ID_instr),
    .addr_in1 (IF_pc[21:0]),    
    .ce_n1    (1'b0),
    .oe_n1    (!IF_instr_ce),
    .we_n1    (1'b1), 
    .uart1    (1'b0),           //取指不访问串口
    .wb1      (1'b0),
    .addr_in2 (22'b0),     
    .ce_n2    (1'b0),
    .oe_n2    (!ID_instr_ce),
    .we_n2    (1'b1),
    .uart2    (1'b0),
    .wb2      (1'b0),
    .go_n     (!go_n),
    .stop_n   (),
    .ram_data (base_ram_data),   
    .ram_addr (base_ram_addr),   
    .ram_be_n (base_ram_be_n),   
    .ram_ce_n (base_ram_ce_n),   
    .ram_oe_n (base_ram_oe_n),   
    .ram_we_n (base_ram_we_n)   
);

mem_controller base_mem_controller2 (
    .clk      (clk),    
    .rst      (rst),
    .din      (MEM_wdata),
    .dout     (MEM_rdata),
    .addr_in1 (EX_dataadr[21:0]),    
    .ce_n1    (EX_dataadr[22]),
    .oe_n1    (!EX_oe),
    .we_n1    (!EX_we), 
    .uart1    (uart1),
    .wb1      (EX_wb),
    .addr_in2 (MEM_dataadr[21:0]),
    .ce_n2    (MEM_dataadr[22]),
    .oe_n2    (!MEM_oe),
    .we_n2    (!MEM_we), 
    .uart2    (uart2),
    .wb2      (MEM_wb),
    .go_n     (go_n),
    .stop_n   (stop_n),
    .ram_data (base_ram_data),   
    .ram_addr (base_ram_addr),   
    .ram_be_n (base_ram_be_n),   
    .ram_ce_n (base_ram_ce_n),   
    .ram_oe_n (base_ram_oe_n),   
    .ram_we_n (base_ram_we_n)   
);

mem_controller ext_mem_controller (
    .clk      (clk),  
    .rst      (rst),    
    .din      (MEM_wdata),
    .dout     (MEM_rdata),    
    .addr_in1 (EX_dataadr[21:0]),    
    .ce_n1    (!EX_dataadr[22]),
    .oe_n1    (!EX_oe),
    .we_n1    (!EX_we), 
    .uart1    (uart1),
    .wb1      (EX_wb),
    .addr_in2 (MEM_dataadr[21:0]),
    .ce_n2    (!MEM_dataadr[22]),
    .oe_n2    (!MEM_oe),
    .we_n2    (!MEM_we), 
    .uart2    (uart2),
    .wb2      (MEM_wb),    
    .go_n     (1'b0),
    .stop_n   (),
    .ram_data (ext_ram_data),   
    .ram_addr (ext_ram_addr),   
    .ram_be_n (ext_ram_be_n),   
    .ram_ce_n (ext_ram_ce_n),   
    .ram_oe_n (ext_ram_oe_n),   
    .ram_we_n (ext_ram_we_n)   
);

endmodule
