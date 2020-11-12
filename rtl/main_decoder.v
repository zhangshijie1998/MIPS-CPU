`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/26 16:56:55
// Design Name: 
// Module Name: main_decoder
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


module main_decoder (
    input  wire [5:0] op,
    output wire       re,       // wirte return point
    output wire       wb,       // word or byte
    output wire       eq,
    output wire       jump,
    output wire       branch,
    output wire       alusrc,
    output wire       memwrite,
    output wire       memtoreg,
    output wire       regwrite,
    output wire       regdst,
    output wire [2:0] aluop
);

reg [2:0] aluop_reg;
reg [9:0] sigs;

assign aluop = aluop_reg;
assign {re, wb, eq, jump, regwrite, regdst, alusrc, branch, memwrite, memtoreg} 
       = sigs;

always @(*) 
case (op)
    6'b000000: begin//R-type, jr
        aluop_reg = 3'b010;
        sigs = 10'b0000110000;//wirte to rd
    end 
    6'b011100: begin//mul
        aluop_reg = 3'b111;
        sigs = 10'b0000110000;//wirte to rd
    end
    6'b100000: begin//lb
        aluop_reg = 3'b000;
        sigs = 10'b0100101001;
    end    
    6'b100011: begin//lw
        aluop_reg = 3'b000;
        sigs = 10'b0000101001;
    end
    6'b101000: begin//sb
        aluop_reg = 3'b000;
        sigs = 10'b0100001010;
    end
    6'b101011: begin//sw
        aluop_reg = 3'b000;
        sigs = 10'b0000001010;
    end
    6'b000100: begin//beq
        aluop_reg = 3'b001;
        sigs = 10'b0010000100;
    end
    6'b000101, 6'b000111: begin//bne, bgtz
        aluop_reg = 3'b001;
        sigs = 10'b0000000100;
    end
    6'b001000, 6'b001001: begin//addi, addiu
        aluop_reg = 3'b000;
        sigs = 10'b0000101000;//wirte to rt
    end
    6'b000010: begin//j
        aluop_reg = 3'b000;
        sigs = 10'b0001000000;
    end
    6'b000011: begin//jal
        aluop_reg = 3'b000;
        sigs = 10'b1001100000;
    end
    6'b001100: begin//andi
        aluop_reg = 3'b011;
        sigs = 10'b0000101000;//wirte to rt
    end
    6'b001101: begin//ori
        aluop_reg = 3'b101;
        sigs = 10'b0000101000;//wirte to rt
    end
    6'b001111: begin//lui
        aluop_reg = 3'b100;
        sigs = 10'b0000101000;//wirte to rt
    end
    6'b001110: begin//xori
        aluop_reg = 3'b110;
        sigs = 10'b0000101000;//wirte to rt
    end
    default: begin
        aluop_reg = 3'b000;
        sigs = 10'b0000000000;
    end
endcase
    
endmodule
