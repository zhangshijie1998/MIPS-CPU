`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/20 15:26:25
// Design Name: 
// Module Name: uart_controller
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


module uart_controller (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] addr,
    input  wire [31:0] din,
    output reg  [31:0] dout,  
    input  wire        we_n,            
    input  wire        oe_n,
    //reader
    input  wire        uart_ready,      //��������׼����
    input  wire [ 7:0] uart_rx,   
    output wire        uart_clear,  
    output reg  [ 7:0] uart_buffer,     //CPU����������
    //transmitter
    input  wire        uart_busy,    
    output reg  [ 7:0] uart_tx,
    output reg         uart_start
);

localparam UART1 = 32'hbfd003f8;
localparam UART2 = 32'hbfd003fc;;
localparam RESET_ENABLE = 1'b1;

wire uart1_eq, uart2_eq;
wire null_r, null_t;
wire full_r, full_t;
reg [7:0] temp_r[127:0], temp_t[127:0];
reg [6:0] head_r, head_t;   
reg [6:0] rear_r, rear_t;

assign uart1_eq = (addr == UART1);
assign uart2_eq = (addr == UART2);
assign uart_clear = uart_ready; //�յ����ݵ�ͬʱ�������־����Ϊ������ȡ��uart_buffer��
assign null_r = (head_r == rear_r);
assign null_t = (head_t == rear_t);
assign full_r = (head_r == (rear_r + 1));
assign full_t = (head_t == (rear_t + 1));
//��CPU����ʹ�÷���ʱ��
//��0xBFD003F8ʱ������������Ϊ���ڽ��յ������ݣ�ͬʱ������ձ�־λ
always @(posedge clk or posedge rst) begin     //���
    if (rst == RESET_ENABLE) begin
        rear_r <= 0;
        uart_buffer <= 0;
    end else if (uart_ready && !full_r) begin
        rear_r <= rear_r + 1;  
        uart_buffer <= uart_rx;        
        temp_r[rear_r] <= uart_rx;
    end    
end

always @(posedge ~clk or posedge rst) begin    //����
    if (rst == RESET_ENABLE) begin
        head_r <= 0;
    end else if (!oe_n && uart1_eq && !null_r) begin
        dout <= {24'b0, temp_r[head_r]};
        head_r <= head_r + 1;
    end else if (!oe_n && uart2_eq) begin
        dout <= {30'b0, !null_r, null_t};
    end else if (!uart1_eq && !uart2_eq) begin  //
        dout <= 32'bz;
    end
end
//д0xBFD003F8ʱ��д���ݵĵ�8λ�͸����ڷ����߼����������ڷ��Ͳ���
// always @(posedge ~clk or posedge rst) begin     //���
always @(posedge ~clk or posedge rst) begin     //���
    if (rst == RESET_ENABLE) begin
        rear_t <= 0;
    end else if (!we_n && uart1_eq && !full_t) begin 
        rear_t <= rear_t + 1;    
        temp_t[rear_t] <= din[7:0];
    end        
end

always @(posedge clk or posedge rst) begin     //����
    if (rst == RESET_ENABLE) begin
        uart_tx <= 8'b0;
        uart_start <= 0;
        head_t <= 0;
    end else if (!uart_busy && !null_t && !uart_start) begin
        uart_tx <= temp_t[head_t];
        uart_start <= 1;
        head_t <= head_t + 1;
    end else begin 
        uart_start <= 0;
    end
end

endmodule
