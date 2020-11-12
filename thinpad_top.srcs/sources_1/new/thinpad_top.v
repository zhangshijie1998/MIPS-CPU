`default_nettype none

module thinpad_top(
    input wire clk_50M,             
    input wire clk_11M0592,         

    input wire clock_btn,           
    input wire reset_btn,           

    input  wire[3:0]  touch_btn,    
    input  wire[31:0] dip_sw,       
    output wire[15:0] leds,         
    output wire[7:0]  dpy0,         
    output wire[7:0]  dpy1,         
    //BaseRAM
    inout  wire[31:0] base_ram_data, 
    output wire[19:0] base_ram_addr,
    output wire[3:0]  base_ram_be_n, 
    output wire       base_ram_ce_n,      
    output wire       base_ram_oe_n,      
    output wire       base_ram_we_n,      
    //ExtRAM
    inout  wire[31:0] ext_ram_data,  
    output wire[19:0] ext_ram_addr, 
    output wire[3:0]  ext_ram_be_n,  
    output wire       ext_ram_ce_n,       
    output wire       ext_ram_oe_n,       
    output wire       ext_ram_we_n,       

    output wire txd,              
    input  wire rxd,              

    output wire [22:0] flash_a,    
    inout  wire [15:0] flash_d,    
    output wire        flash_rp_n,       
    output wire        flash_vpen,       
    output wire        flash_ce_n,       
    output wire        flash_oe_n,       
    output wire        flash_we_n,       
    output wire        flash_byte_n,     

    output wire[2:0] video_red,   
    output wire[2:0] video_green, 
    output wire[1:0] video_blue,  
    output wire      video_hsync,      
    output wire      video_vsync,      
    output wire      video_clk,        
    output wire      video_de          
);
// PLL
wire locked, clk_10M, clk_180M;
pll_example clock_gen (
  // Clock in ports
  .clk_in1(clk_50M),  
  // Clock out ports
  .clk_out1(clk_10M), 
  .clk_out2(clk_180M),
  // Status and control signals
  .reset(reset_btn),
  .locked(locked)   
);

reg reset_of_clk10M;

always@(posedge clk_10M or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
end

wire        ID_instr_ce, IF_instr_ce;
wire        MEM_we, MEM_oe, MEM_wb;
wire        EX_we, EX_oe, EX_wb;
wire [31:0] MEM_rdata, MEM_dataadr, MEM_wdata, EX_dataadr, EX_wdata, ID_instr, IF_pc_out;

mips mips (
    .clk         (clk_10M),            
    .rst         (reset_of_clk10M),    
    .ID_instr    (ID_instr),
    .ID_instr_ce (ID_instr_ce),
    .IF_instr_ce (IF_instr_ce),
    .IF_pc_out   (IF_pc_out),
    .EX_dataadr  (EX_dataadr),
    .EX_wdata    (EX_wdata),  
    .EX_we       (EX_we),
    .EX_oe       (EX_oe),
    .EX_wb       (EX_wb),    
    .MEM_dataadr (MEM_dataadr),
    .MEM_wdata   (MEM_wdata),
    .MEM_rdata   (MEM_rdata), 
    .MEM_we      (MEM_we),    
    .MEM_oe      (MEM_oe), 
    .MEM_wb      (MEM_wb)     
);
//ram
ram_controller ram_controller (
    .clk           (clk_10M), 
    .rst           (reset_of_clk10M),
    .ID_instr      (ID_instr), 
    .ID_instr_ce   (ID_instr_ce), 
    .IF_instr_ce   (IF_instr_ce),    
    .IF_pc         (IF_pc_out),   
    .EX_dataadr    (EX_dataadr),
    .EX_wdata      (EX_wdata),  
    .EX_we         (EX_we),
    .EX_oe         (EX_oe),
    .EX_wb         (EX_wb),    
    .MEM_dataadr   (MEM_dataadr),
    .MEM_wdata     (MEM_wdata),
    .MEM_rdata     (MEM_rdata), 
    .MEM_we        (MEM_we),    
    .MEM_oe        (MEM_oe), 
    .MEM_wb        (MEM_wb), 
    .base_ram_data (base_ram_data),   
    .base_ram_addr (base_ram_addr),   
    .base_ram_be_n (base_ram_be_n),   
    .base_ram_ce_n (base_ram_ce_n),   
    .base_ram_oe_n (base_ram_oe_n),   
    .base_ram_we_n (base_ram_we_n),   
    .ext_ram_data  (ext_ram_data),   
    .ext_ram_addr  (ext_ram_addr),   
    .ext_ram_be_n  (ext_ram_be_n),   
    .ext_ram_ce_n  (ext_ram_ce_n),   
    .ext_ram_oe_n  (ext_ram_oe_n),   
    .ext_ram_we_n  (ext_ram_we_n) 
);

uart_controller uart_controller (
    .clk         (clk_10M),
    .rst         (reset_of_clk10M),
    .addr        (MEM_dataadr),
    .din         (MEM_wdata),
    .dout        (MEM_rdata),  
    .we_n        (~MEM_we),         
    .oe_n        (~MEM_oe),   
    .uart_ready  (ext_uart_ready),
    .uart_rx     (ext_uart_rx),
    .uart_clear  (ext_uart_clear),
    .uart_buffer (ext_uart_buffer), 
    .uart_busy   (ext_uart_busy),   
    .uart_tx     (ext_uart_tx),
    .uart_start  (ext_uart_start)
);
// 
// assign base_ram_ce_n = 1'b1;
// assign base_ram_oe_n = 1'b1;
// assign base_ram_we_n = 1'b1;

// assign ext_ram_ce_n = 1'b1;
// assign ext_ram_oe_n = 1'b1;
// assign ext_ram_we_n = 1'b1;

// 
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

wire[7:0] number;
SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1

reg[15:0] led_bits;
assign leds = led_bits;

always@(posedge clock_btn or posedge reset_btn) begin
    if(reset_btn)begin 
        led_bits <= 16'h1;
    end else begin 
        led_bits <= {led_bits[14:0],led_bits[15]};
    end
end

localparam CLKFREQUENCY = 55_000000;        
localparam BAUD = 9600;
wire ext_uart_ready, ext_uart_clear, ext_uart_busy, ext_uart_start;
wire [7:0] ext_uart_rx, ext_uart_tx, ext_uart_buffer;

//assign number = ext_uart_buffer;
assign number = count[31:24];

async_receiver #(.ClkFrequency(CLKFREQUENCY),.Baud(BAUD))
    ext_uart_r(
        .clk(clk_10M),                      
        .RxD(rxd),                          
        .RxD_data_ready(ext_uart_ready),    
        .RxD_clear(ext_uart_clear),         
        .RxD_data(ext_uart_rx)              
    );

async_transmitter #(.ClkFrequency(CLKFREQUENCY),.Baud(BAUD))
    ext_uart_t(
        .clk(clk_10M),                 
        .TxD(txd),                     
        .TxD_busy(ext_uart_busy),      
        .TxD_start(ext_uart_start),    
        .TxD_data(ext_uart_tx)         
    );

reg [31:0] count;

always @(posedge clk_11M0592 or posedge reset_btn) begin
    if (reset_btn) begin
        count <= 0;
    end else begin   
        count <= count + 1;   
    end
end

wire [11:0] hdata;
assign video_red = hdata < 266 ? 3'b111 : 0; 
assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; 
assign video_blue = hdata >= 532 ? 2'b11 : 0; 
assign video_clk = clk_50M;
vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(clk_50M), 
    .hdata(hdata), 
    .vdata(),      
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de)
);

endmodule
