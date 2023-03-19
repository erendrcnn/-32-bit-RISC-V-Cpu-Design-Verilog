`timescale 1ns / 1ps
// METIN EREN DURUCAN - 201101038 - BIL361 HW1
module islemci(
        input clk,                          // 1 bit saat girisi
        input rst,                          // 1 bit devreyi baslangic durumuna ceviren giris sinyali
        input[31:0] buyruk,                 // 32 bit cevrimde yurutulen buyruk
        output reg[31:0] ps                 // 32 bit program sayaci cikisi
    );
    
    reg signed [31:0] yazmac_obegi[7:0];    // 8 adet 32 bit yazmac
    reg[31:0] buyruk_bellek[255:0];         // 256 adet 32 bit buyruk bellegi
    reg[31:0] veri_bellek[127:0];           // 128 kapasiteli 32 bit veri bellegi
                                            // 4 bayt adresleme yapilir [0x0000_0000 -> 0x0000_0004]
                                            
    reg [6:0] islemkodu;                    // 7 bit yapilan islemi ayirt eden islemkodu
    reg [31:0] sayac, sayac_sonraki;        // 32 bit sayac degerleri
    
    integer i;                              // donguler icin integer degeri
    
    initial begin
        // ilk yazmac icerisine standart olarak 0 atanir.
        yazmac_obegi[0] = 32'b00000000_00000000_00000000_00000000;
        // sayac standart olarak 0 olarak ayarlanir.
        sayac = 0;                          
    end
    
    always@(posedge clk, posedge rst) begin
        yazmac_obegi[0] = 32'b00000000_00000000_00000000_00000000;
        
        if (rst) begin
            islemkodu = 0;
            sayac_sonraki = 0;
            
            for (i = 0; i < 8; i = i + 1) begin
                yazmac_obegi[i] = 32'b00000000_00000000_00000000_00000000;
            end
            
            for (i = 0; i < 128; i = i + 1) begin
                veri_bellek[i] = 32'b00000000_00000000_00000000_00000000;
            end
            
            sayac <= sayac_sonraki;
            ps <= sayac_sonraki;
        end
        
        else if (clk) begin
            islemkodu = buyruk[6:0];   
            
            if (islemkodu == 7'b0010011) begin                              // I-Types (ADDI)
                if (buyruk[14:12] == 0) begin                               // ADDI (ADD IMMEDIATE)
                    // rd = rs1 + imm12
                    yazmac_obegi[buyruk[11:7]] = yazmac_obegi[buyruk[19:15]] + $signed(buyruk[31:20]);
                end
            end
            
            else if (islemkodu == 7'b0110011) begin                         // R-Types (ADD SUB OR AND XOR)
                if (buyruk[31:25] == 0 & buyruk[14:12] == 0) begin          // ADD 
                    yazmac_obegi[buyruk[11:7]] = yazmac_obegi[buyruk[24:20]] + yazmac_obegi[buyruk[19:15]];
                end 
                
                else if (buyruk[31:25] == 32 & buyruk[14:12] == 0) begin    // SUB (SUBTRACT)
                    yazmac_obegi[buyruk[11:7]] = yazmac_obegi[buyruk[19:15]] - yazmac_obegi[buyruk[24:20]];
                end
                
                else if (buyruk[31:25] == 0 & buyruk[14:12] == 5) begin     // OR
                    yazmac_obegi[buyruk[11:7]] = yazmac_obegi[buyruk[24:20]] | yazmac_obegi[buyruk[19:15]];
                end
                
                else if (buyruk[31:25] == 0 & buyruk[14:12] == 7) begin     // AND
                    yazmac_obegi[buyruk[11:7]] = yazmac_obegi[buyruk[24:20]] & yazmac_obegi[buyruk[19:15]];
                end
                
                else if (buyruk[31:25] == 0 & buyruk[14:12] == 4) begin     // XOR
                    yazmac_obegi[buyruk[11:7]] = yazmac_obegi[buyruk[24:20]] ^ yazmac_obegi[buyruk[19:15]];
                end
            end
            
            else if (islemkodu == 7'b1100011) begin                         // SB-Types (BEQ BNE BLT)
                if (buyruk[14:12] == 0) begin                               // BEQ (BRANCH EQUAL)
                    // pc = rs1 == rs2 ? pc + imm12, pc + 4
                    sayac_sonraki = (yazmac_obegi[buyruk[19:15]] == yazmac_obegi[buyruk[24:20]])
                        ? sayac + ({buyruk[31], buyruk[7], buyruk[30:25], buyruk[11:8]} * 4)
                        : sayac + 4;
                end
                
                else if (buyruk[14:12] == 1) begin                          // BNE (BRANCH NOT EQUAL)
                    // pc = rs1 != rs2 ? pc + imm12, pc + 4
                    sayac_sonraki = (yazmac_obegi[buyruk[19:15]] != yazmac_obegi[buyruk[24:20]])
                        ? sayac + ({buyruk[31], buyruk[7], buyruk[30:25], buyruk[11:8]} * 4)
                        : sayac + 4;
                end
                
                else if (buyruk[14:12] == 4) begin                          // BLT (BRANCH LESS THAN)
                    // pc = rs1 < rs2 ? pc + imm12, pc + 4
                    sayac_sonraki = (yazmac_obegi[buyruk[19:15] < yazmac_obegi[buyruk[24:20]]]) 
                        ? sayac + ({buyruk[31], buyruk[7], buyruk[30:25], buyruk[11:8]} * 4)
                        : sayac + 4;
                end
            end
            
            else if (islemkodu == 7'b1101111) begin                         // JAL (JUMP AND LINK)
                yazmac_obegi[buyruk[11:7]] = sayac + 4;                                         // rd = pc + 4
                sayac_sonraki = sayac + {buyruk[31], buyruk[19:12], buyruk[20], buyruk[30:21]}; // pc = pc + imm20
            end
            
            else if (islemkodu == 7'b1100111 & buyruk[14:12] == 0) begin    // JALR (JUMP AND LINK REGISTER)
                yazmac_obegi[buyruk[11:7]] = sayac + 4;                                         // rd = pc + 4
                sayac_sonraki = yazmac_obegi[buyruk[19:15]] + buyruk[31:20];                    // pc = pc + imm12 
            end
            
            else if (islemkodu == 7'b0110111) begin                         // LUI (LOAD UPPER IMMEDIATE)
                // rd = imm20 << 12
                yazmac_obegi[buyruk[11:7]] = buyruk[31:12] << 12;
            end
            
            else if (islemkodu == 7'b0010111) begin                         // AUIPC (ADD UPPER IMMEDIATE TO PC)
                // rd = pc + imm20 << 12
                yazmac_obegi[buyruk[11:7]] = sayac + buyruk[31:12] << 12;
            end
            
            else if (islemkodu == 7'b0000011) begin                         // LW (LOAD WORD)
                // $rs2 = BELLEK($rs1 + imm)
                yazmac_obegi[buyruk[11:7]] = veri_bellek[yazmac_obegi[buyruk[19:15]] + buyruk[31:20]];
            end
            
            else if (islemkodu == 7'b0100011) begin                         // SW (STORE WORD)
                // BELLEK($rs1 + imm) = $rs2
                veri_bellek[( yazmac_obegi[buyruk[19:15]] + {buyruk[31:25], buyruk[11:7]} ) >> 2] = yazmac_obegi[buyruk[24:20]];
            end
            
            sayac_sonraki = sayac + 4;
            sayac <= sayac_sonraki;
            ps <= sayac_sonraki;
        end
    end
endmodule