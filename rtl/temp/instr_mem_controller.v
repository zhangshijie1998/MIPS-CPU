`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/17 17:49:11
// Design Name: 
// Module Name: instr_mem_controller
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


module instr_mem_controller (
    input  wire        clk,        //180Mʱ������
    input  wire        rst,
    input  wire [21:0] addr_in,
    input  wire [31:0] din,
    output wire [31:0] dout,
    input  wire        ce_n,
    input  wire        oe_n,
    input  wire        we_n,  
    input  wire        uart,
    input  wire        wb,         //wb=1�ֽڲ�����8λ��wb=0�ֲ�����32λ
    //��ʱ���ÿ����ź�
    input  wire        go_n,       //go_n��stop_nΪ�͵�ƽ��Ч
    output reg         stop_n,
    //RAM�ź�
    inout  wire [31:0] ram_data,   //RAM���ݣ���8λ��CPLD���ڿ���������
    output reg  [19:0] ram_addr,   //RAM��ַ
    output reg  [ 3:0] ram_be_n,   //RAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
    output reg         ram_ce_n,   //RAMƬѡ������Ч
    output reg         ram_oe_n,   //RAM��ʹ�ܣ�����Ч
    output reg         ram_we_n    //RAMдʹ�ܣ�����Ч
);

localparam RESET_ENABLE = 1'b1;

reg read, write;
reg  [ 3:0] be_n;
reg  [31:0] dout_reg;   //�ֲ������
reg  [31:0] dout_reg2;  //�ֽڲ������
reg  [31:0] din_reg;
reg  [31:0] din_reg2;
wire [19:0] addr;

assign addr = addr_in[21:2];
assign dout = dout_reg2;
//дʱ����din_reg���ӣ�������ݡ���ʱ���ø��裬���ⲿ���ݡ�                     
assign ram_data = write ? din_reg2 : 32'bz;             
                         
always @(*) 
case ({wb, addr_in[1:0]})
    3'b100:  be_n = 4'b1110;
    3'b101:  be_n = 4'b1101;
    3'b110:  be_n = 4'b1011;
    3'b111:  be_n = 4'b0111;
    default: be_n = 4'b0000;
endcase

always @(*) 
case ({wb, addr_in[1:0]})
    3'b100:  dout_reg2 = {24'b0, dout_reg[7:0]};
    3'b101:  dout_reg2 = {24'b0, dout_reg[15:8]};
    3'b110:  dout_reg2 = {24'b0, dout_reg[23:16]};
    3'b111:  dout_reg2 = {24'b0, dout_reg[31:24]}; 
    default: dout_reg2 = dout_reg;
endcase

always @(*) 
case ({wb, addr_in[1:0]})
    3'b100:  din_reg2 = {24'b0, din_reg[7:0]};
    3'b101:  din_reg2 = {16'b0, din_reg[7:0], 8'b0};
    3'b110:  din_reg2 = {8'b0, din_reg[7:0], 16'b0};
    3'b111:  din_reg2 = {din_reg[7:0], 24'b0}; 
    default: din_reg2 = din_reg;
endcase
//read:taa=10ns,write:taw=8ns 
always @(posedge clk or posedge rst) begin
    if (rst == RESET_ENABLE) begin
        read <= 1'b0;
        write <= 1'b0;
        stop_n <= 1'b0;
        ram_addr <= 20'hfffff;
        ram_be_n <= 4'b1111;
        ram_ce_n <= 1'b1;
        ram_oe_n <= 1'b1;
        ram_we_n <= 1'b1;        
    end if (go_n) begin
        read <= 1'b0;
        write <= 1'b0;
        stop_n <= 1'b1;
        ram_addr <= 20'bz;
        ram_be_n <= 4'bzzzz;
        ram_ce_n <= 1'bz;
        ram_oe_n <= 1'bz;
        ram_we_n <= 1'bz;
    end else if (!uart && !ce_n && !we_n) begin
        read <= 1'b0;
        write <= 1'b1;
        stop_n <= 1'b0;    
        din_reg  <= din;        
        ram_addr <= addr;
        ram_be_n <= be_n;
        ram_ce_n <= 1'b0;
        ram_oe_n <= 1'b1;
        ram_we_n <= 1'b0;        
    end else begin
        read <= 1'b1;
        write <= 1'b0;
        stop_n <= 1'b0;  
        ram_addr <= addr;
        ram_be_n <= be_n;
        ram_ce_n <= 1'b0;
        ram_oe_n <= 1'b0;
        ram_we_n <= 1'b1;     
    end       
end

always @(posedge clk or posedge rst) begin
    if (rst == RESET_ENABLE)
        dout_reg <= 32'b0;
    else if (read && !uart && !ce_n && !oe_n) 
        dout_reg <= ram_data;
end
// always @(posedge clk or posedge rst) begin
    // if (rst == RESET_ENABLE) begin
        // read <= 1'b0;
        // write <= 1'b0;
        // stop_n <= 1'b0;
        // ram_addr <= 20'hfffff;
        // ram_be_n <= 4'b1111;
        // ram_ce_n <= 1'b1;
        // ram_oe_n <= 1'b1;
        // ram_we_n <= 1'b1;        
    // end if (go_n) begin
        // read <= 1'b0;
        // write <= 1'b0;
        // stop_n <= 1'b1;
        // ram_addr <= 20'bz;
        // ram_be_n <= 4'bzzzz;
        // ram_ce_n <= 1'bz;
        // ram_oe_n <= 1'bz;
        // ram_we_n <= 1'bz;
    // end else if (!uart && !ce_n && !we_n) begin
        // read <= 1'b0;
        // write <= 1'b1;
        // stop_n <= 1'b0;    
        // din_reg  <= din;        
        // ram_addr <= addr;
        // ram_be_n <= be_n;
        // ram_ce_n <= 1'b0;
        // ram_oe_n <= 1'b1;
        // ram_we_n <= 1'b0;        
    // end else if (!uart && !ce_n && !oe_n) begin
        // read <= 1'b1;
        // write <= 1'b0;
        // stop_n <= 1'b0;  
        // ram_addr <= addr;
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

// always @(posedge clk or posedge rst) begin
    // if (rst == RESET_ENABLE)
        // dout_reg <= 32'b0;
    // else if (read) 
        // dout_reg <= ram_data;
// end
        
endmodule