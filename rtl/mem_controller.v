`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/17 17:49:11
// Design Name: 
// Module Name: mem_controller
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


module mem_controller (
    input  wire        clk,        
    input  wire        rst,
    input  wire [31:0] din,
    output wire [31:0] dout,
    input  wire [21:0] addr_in1,    
    input  wire        ce_n1,
    input  wire        oe_n1,
    input  wire        we_n1,  
    input  wire        uart1,
    input  wire        wb1,        //wb=1字节操作，8位；wb=0字操作，32位
    input  wire [21:0] addr_in2,    
    input  wire        ce_n2,
    input  wire        oe_n2,
    input  wire        we_n2,  
    input  wire        uart2,
    input  wire        wb2,        
    //分时复用控制信号
    input  wire        go_n,       //go_n和stop_n为低电平有效
    output reg         stop_n,
    //RAM信号
    inout  wire [31:0] ram_data,   //RAM数据，低8位与CPLD串口控制器共享
    output reg  [19:0] ram_addr,   //RAM地址
    output reg  [ 3:0] ram_be_n,   //RAM字节使能，低有效。如果不使用字节使能，请保持为0
    output reg         ram_ce_n,   //RAM片选，低有效
    output reg         ram_oe_n,   //RAM读使能，低有效
    output reg         ram_we_n    //RAM写使能，低有效
);

localparam RESET_ENABLE = 1'b1;

reg read, write;
reg  [ 3:0] be_n;
reg  [31:0] dout_reg;   
reg  [31:0] dout_reg2;  
reg  [31:0] din_reg;
wire [19:0] addr1, addr2;

assign addr1 = addr_in1[21:2];         
assign addr2 = addr_in2[21:2];                        
assign dout = dout_reg;
assign ram_data = write ? din_reg : 32'bz; 
                      
always @(*) 
case ({wb1, addr_in1[1:0]})
    3'b100:  be_n = 4'b1110;
    3'b101:  be_n = 4'b1101;
    3'b110:  be_n = 4'b1011;
    3'b111:  be_n = 4'b0111;
    default: be_n = 4'b0000;
endcase

always @(*) 
case ({wb2, addr_in2[1:0]})
    3'b100:  din_reg = {24'b0, din[7:0]};
    3'b101:  din_reg = {16'b0, din[7:0], 8'b0};
    3'b110:  din_reg = {8'b0, din[7:0], 16'b0};
    3'b111:  din_reg = {din[7:0], 24'b0}; 
    default: din_reg = din;
endcase

always @(*) 
case ({wb2, addr_in2[1:0]})
    3'b100:  dout_reg2 = {24'b0, ram_data[7:0]};
    3'b101:  dout_reg2 = {24'b0, ram_data[15:8]};
    3'b110:  dout_reg2 = {24'b0, ram_data[23:16]};
    3'b111:  dout_reg2 = {24'b0, ram_data[31:24]}; 
    default: dout_reg2 = ram_data;
endcase
//read:taa=10ns,write:taw=8ns 
always @(posedge clk or posedge rst) begin
    if (rst == RESET_ENABLE) begin
        read <= 1'b0;
        write <= 1'b0;
        stop_n <= 1'b1;
        ram_addr <= 20'hfffff;
        ram_be_n <= 4'b1111;
        ram_ce_n <= 1'b1;
        ram_oe_n <= 1'b1;
        ram_we_n <= 1'b1;        
    end else if (go_n) begin
        read <= 1'b0;
        write <= 1'b0;
        stop_n <= 1'b1;
        ram_addr <= 20'bz;
        ram_be_n <= 4'bzzzz;
        ram_ce_n <= 1'bz;
        ram_oe_n <= 1'bz;
        ram_we_n <= 1'bz;
    end else if (!uart1 && !ce_n1 && !we_n1) begin
        read <= 1'b0;
        write <= 1'b1;
        stop_n <= 1'b0;                 
        ram_addr <= addr1;
        ram_be_n <= be_n;
        ram_ce_n <= 1'b0;
        ram_oe_n <= 1'b1;
        ram_we_n <= 1'b0;        
    end else begin
        read <= 1'b1;
        write <= 1'b0;
        stop_n <= 1'b0;  
        ram_addr <= addr1;
        ram_be_n <= be_n;
        ram_ce_n <= 1'b0;
        ram_oe_n <= 1'b0;
        ram_we_n <= 1'b1;     
    end      
end

always @(posedge clk or posedge rst) begin
    if (rst == RESET_ENABLE)
        dout_reg <= 32'b0;
    else if ((ce_n2 || uart2) && !oe_n2)    ///
        dout_reg <= 32'bz;
    else if (read && !uart2 && !ce_n2 && !oe_n2) 
        dout_reg <= dout_reg2;                  
end

// always @(posedge clk or posedge rst) begin
    // if (rst == RESET_ENABLE) begin
        // read <= 1'b0;
        // write <= 1'b0;
        // stop_n <= 1'b1;
        // ram_addr <= 20'hfffff;
        // ram_be_n <= 4'b1111;
        // ram_ce_n <= 1'b1;
        // ram_oe_n <= 1'b1;
        // ram_we_n <= 1'b1;        
    // end else if (go_n) begin
        // read <= 1'b0;
        // write <= 1'b0;
        // stop_n <= 1'b1;
        // ram_addr <= 20'bz;
        // ram_be_n <= 4'bzzzz;
        // ram_ce_n <= 1'bz;
        // ram_oe_n <= 1'bz;
        // ram_we_n <= 1'bz;
    // end else if (!uart1 && !ce_n1 && !we_n1) begin
        // read <= 1'b0;
        // write <= 1'b1;
        // stop_n <= 1'b0;                 
        // ram_addr <= addr1;
        // ram_be_n <= be_n;
        // ram_ce_n <= 1'b0;
        // ram_oe_n <= 1'b1;
        // ram_we_n <= 1'b0;        
    // end else if (!uart1 && !ce_n1 && !oe_n1) begin
        // read <= 1'b1;
        // write <= 1'b0;
        // stop_n <= 1'b0;  
        // ram_addr <= addr1;
        // ram_be_n <= be_n;
        // ram_ce_n <= 1'b0;
        // ram_oe_n <= 1'b0;
        // ram_we_n <= 1'b1;     
    // end else begin  
        // read <= 1'b0;
        // write <= 1'b0;
        // stop_n <= 1'b0;
        // ram_addr <= 20'hfffff;
        // ram_be_n <= 4'b1111;
        // ram_ce_n <= 1'b1;
        // ram_oe_n <= 1'b1;
        // ram_we_n <= 1'b1;
    // end        
// end
       
endmodule
