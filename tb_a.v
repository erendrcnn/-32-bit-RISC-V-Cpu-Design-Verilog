`timescale 1ns / 1ps
// METIN EREN DURUCAN - 201101038 - BIL361 HW1
module tb_a();

reg             clk_i;
reg             rst_i;
wire    [31:0]  ps_o;
reg     [31:0]  buyruk_i;

islemci uut (
    .clk        ( clk_i ),
    .rst        ( rst_i ),
    .ps         ( ps_o ),
    .buyruk     ( buyruk_i )       
);

always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end

reg [31:0] buyruk_bellegi [0:255];

always @(posedge clk_i) begin
    buyruk_i <= buyruk_bellegi[(ps_o & 'h0FFF_FFFC) >> 2]; // Saatin her yukselen kenarinda ps ile gosterilen adresteki buyruga eris.
end

initial begin
    buyruk_i = 'd0;
    rst_i = 1'b1;
    repeat(10) @(posedge clk_i) #2;     // 10 cevrim boyunca resetle
    rst_i = 1'b0;
    buyruk_bellegi['h000] = 'h00500093; // addi x1, x0, 5
    buyruk_bellegi['h001] = 'h00700113; // addi x2, x0, 7
    buyruk_bellegi['h002] = 'h002081b3; // add  x3, x1, x2
    buyruk_bellegi['h003] = 'h0011a023; // sw   x1, 0(x3)
    repeat(5) @(posedge clk_i) #2;      // 5 cevrim gecsin
    if (uut.yazmac_obegi[3] == 'd12) begin // x3 == 12
        $display("Yazmac erisimi ve deger dogru.");
    end
    if (uut.veri_bellek[uut.yazmac_obegi[3] >> 2] == uut.yazmac_obegi[1]) begin // Bellek[x3] (satir[x3 >> 2]) == x1
        $display("Bellek erisimi ve deger dogru.");
    end
end

endmodule