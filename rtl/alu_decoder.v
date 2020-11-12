`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/26 16:56:55
// Design Name: 
// Module Name: alu_decoder
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


module alu_decoder (
    input  wire [5:0] funct,
    input  wire [2:0] aluop,
    output reg  [3:0] alucontrol,
    output wire       sign,      //sign=1进行0扩展
    output wire       jr
);

reg [1:0] sigs;

assign {sign, jr} = sigs;
//组合逻辑
always @(*)
case (aluop)
    3'b000: begin//addi, addiu, lb, lw, sb, sw, j
        sigs = 2'b00;
        alucontrol = 4'b0010;
    end
    3'b001: begin//beq, bne, bgtz
        sigs = 2'b00;
        alucontrol = 4'b0110;
    end
    3'b010://R-type
    case (funct)
        6'b000000: begin//sll
            sigs = 2'b00;
            alucontrol = 4'b1010;
        end
        6'b000010: begin//srl
            sigs = 2'b00;
            alucontrol = 4'b1011;    
        end
        6'b001000: begin//jr
            sigs = 2'b01;
            alucontrol = 4'b0000;
        end
        6'b100000, 6'b100001: begin//add, addu
            sigs = 2'b00;
            alucontrol = 4'b0010;
        end
        6'b100010, 6'b100011: begin//sub, subu
            sigs = 2'b00;
            alucontrol = 4'b0110;
        end
        6'b100100: begin//and
            sigs = 2'b00;
            alucontrol = 4'b0000;
        end
        6'b100101: begin//or
            sigs = 2'b00;
            alucontrol = 4'b0001;
        end
        6'b101010, 6'b101011: begin//slt, sltu
            sigs = 2'b00;
            alucontrol = 4'b0111;
        end
        6'b100110: begin//xor
            sigs = 2'b00;
            alucontrol = 4'b1000;
        end
        default: begin
            sigs = 2'b00;
            alucontrol = 4'b0000;
        end    
    endcase
    3'b011: begin//andi
        sigs = 2'b10;
        alucontrol = 4'b0000;
    end
    3'b100: begin//lui
        sigs = 2'b00;
        alucontrol = 4'b1001;
    end
    3'b101: begin//ori
        sigs = 2'b10;
        alucontrol = 4'b0001;
    end
    3'b110: begin//xori
        sigs = 2'b10;
        alucontrol = 4'b1000;
    end
    3'b111: begin//mul
        sigs = 2'b00;
        alucontrol = 4'b0011;
    end
    default: begin
        sigs = 2'b00;
        alucontrol = 4'b0000;
    end    
endcase

endmodule
