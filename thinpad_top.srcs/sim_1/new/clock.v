`timescale 1ps / 1ps

module clock (
    output reg clk_50M,
    output reg clk_11M0592,
    output reg clk_10M
);

initial begin
    clk_50M = 0;
    clk_11M0592 = 0;
    clk_10M = 0;
end

always #(90422/2) clk_11M0592 = ~clk_11M0592;
always #(20000/2) clk_50M = ~clk_50M;
always #(100000/2) clk_10M = ~clk_10M;

endmodule
