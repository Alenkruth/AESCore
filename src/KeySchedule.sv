`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   Key Schedule Module (top)                                       //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the Key Expander operation of Rijndael   //
// Reference:     https://crypto.stackexchange.com/a/1527                         //
////////////////////////////////////////////////////////////////////////////////////

module KeySchedule(
    // input key data
    input logic [255:0] key_i,
    // input clock
    input logic clk_i,
    // input hold for clock gating
    input logic hold_i,
    // input reset
    input logic rst_n,
    // enable signal
    input logic en_i,
    // output key select lines
    input logic [3:0] round_count_i,
    // output ready
    output logic done_o,
    // output busy
    output logic busy_o,
    // output keys
    output logic [127:0] key_o
    );
    
    // Round Constant rcon
    logic [7:0] rcon [6:0];
    
    assign rcon [0] = 8'h01;
    assign rcon [1] = 8'h02;
    assign rcon [2] = 8'h04;
    assign rcon [3] = 8'h08;
    assign rcon [4] = 8'h10;
    assign rcon [5] = 8'h20;
    assign rcon [6] = 8'h40;
    
    // word in 
    logic [31:0] word_i;

    // gated clock for the logic
    logic clk_g;
    assign clk_g = clk_i & hold_i;
    
    // key input
    logic [127:0] key_in;
    
    // rcon input 
    logic [7:0] rcon_in;
    
    // handshake signals
    logic enable_gxor;
    logic enable_fxor;
    
    logic ready_gxor;
    logic ready_fxor;
    
    logic busy_fxor;
    logic busy_gxor;
    
    logic rst_f;
    logic rst_fn;
    logic rst_g;
    logic rst_gn;
    
    assign rst_fn = rst_f & rst_n & hold_i;
    assign rst_gn = rst_g & rst_n & hold_i;
    
    logic [127:0] key_out_g;
    logic [127:0] key_out_f;
    
    //reg to store key value
    logic [127:0] key_reg;
    
    //reg to store previous key values
    logic [127:0] key_round1;
    logic [127:0] key_round2;
    
    FunctionF fxor
                (.clk_i       (clk_g       ),
                 .rst_n       (rst_fn      ),
                 .en_i        (enable_fxor ),
                 .ready_o     (ready_fxor  ),
                 .busy_o      (busy_fxor   ),
                 .word_i      (word_i      ),
                 .key_round2_i(key_in      ),
                 .rcon_i      (rcon_in     ),
                 .key_o       (key_out_f   ));
                 
    FunctionGXOR gxor
                    (.clk_i        (clk_g      ),
                     .rst_n        (rst_gn     ),
                     .en_i         (enable_gxor),
                     .ready_o      (ready_gxor ),
                     .busy_o       (busy_gxor  ),
                     .word_i       (word_i     ),
                     .key_o        (key_out_g  ),
                     .key_round2_i (key_in     )); 
                     
//    enum logic [3:0] {ZERO,ONE,TWO,THREE,FOUR,FIVE,
//                      SIX,SEVEN,EIGHT,NINE,TEN,ELEVEN,
//                      TWELVE,THIRTEEN,FOURTEEN,FIFTEEN} key_mux;
                      
    enum logic [1:0] {IDLE,COMPUTE,LOAD} fsm_cs, fsm_ns;
    
    always_comb
    begin
        rst_g = 1'b1;
        rst_f = 1'b1;
        done_o = 1'b0;
        enable_gxor = 1'b0;
        enable_fxor = 1'b0;
        fsm_ns = fsm_cs;
        word_i = key_round1[31:0];
        key_in = key_round2; 
	    rcon_in = 8'bzzzzzzzz;  
        
        unique case (fsm_cs)
            
            /*READY:
            begin
                ready_o = 1'b1;
                fsm_ns = IDLE;
            end*/
            
            IDLE:
            begin
                rst_g = 1'b0;
                rst_f = 1'b0;
                done_o = 1'b0;
                if ( round_count_i <= 4'b0001) begin
                    fsm_ns = LOAD;
                end         
                else fsm_ns = COMPUTE;
            end
            
            COMPUTE:
            begin
                done_o = 1'b0;
                unique case (round_count_i)
                    4'b0010:
                    begin
                        rcon_in = rcon[0];
                        word_i = key_i[31:0];
                        enable_fxor = 1'b1;
                        rst_g = 1'b0;
                        if (ready_fxor) fsm_ns = LOAD;
                    end
                    
                    4'b0100:
                    begin
                        rcon_in = rcon[1];
                        enable_fxor = 1'b1;
                        rst_g = 1'b0;
                        if (ready_fxor) fsm_ns = LOAD;
                    end
                    
                    4'b0110:
                    begin
                        rcon_in = rcon[2];
                        enable_fxor = 1'b1;
                        rst_g = 1'b0;
                        if (ready_fxor) fsm_ns = LOAD;
                    end
                    
                    4'b1000:
                    begin
                        rcon_in = rcon[3];
                        enable_fxor = 1'b1;
                        rst_g = 1'b0;
                        if (ready_fxor) fsm_ns = LOAD;
                    end
                    
                    4'b1010:
                    begin
                        rcon_in = rcon[4];
                        enable_fxor = 1'b1;
                        rst_g = 1'b0;
                        if (ready_fxor) fsm_ns = LOAD;
                    end
                    
                    4'b1100:
                    begin
                        rcon_in = rcon[5];
                        enable_fxor = 1'b1;
                        rst_g = 1'b0;
                        if (ready_fxor) fsm_ns = LOAD;
                    end
                    
                    4'b1110:
                    begin
                        rcon_in = rcon[6];
                        enable_fxor = 1'b1;
                        rst_g = 1'b0;
                        if (ready_fxor) fsm_ns = LOAD;
                    end
                    
                    4'b0011,4'b0101,
                    4'b0111,4'b1001,
                    4'b1011,4'b1101:
                    begin
                        rcon_in = 8'bzzzzzzzz;
                        enable_gxor = 1'b1;
                        rst_f = 1'b0;
                        if (ready_gxor) fsm_ns = LOAD;
                    end
                    
                    default:
                    begin
                        rcon_in = 8'bzzzzzzzz;
                        fsm_ns = LOAD;
                    end
                endcase
            end
            
            LOAD:
            begin
                done_o = 1'b1;
                fsm_ns = IDLE;
            end
	    
            default:;
        endcase
    end
    
    always_ff @(posedge clk_g, negedge rst_n)
    begin
        if (~rst_n) begin
            fsm_cs <= IDLE;
        end
        
        else if (en_i) begin
            fsm_cs <= fsm_ns;
        end
        
        else if (~en_i) begin
            fsm_cs <= fsm_cs;
        end    
    end
    
    always_ff @(posedge clk_g)
    begin
        // done_o <= 1'b0;
        if (rst_n) begin
            unique case (round_count_i)
                
                4'b0000:
                begin
                    key_reg <= key_i[255:128];
                    // done_o <= 1'b1;
                end
                
                4'b0001:
                begin
                    key_reg <= (hold_i & done_o ) ? key_i[127:  0] : key_reg;
                    // done_o <= 1'b1;
                end
                
                4'b0010,4'b0100,
                4'b0110,4'b1000,
                4'b1010,4'b1100,
                4'b1110:
                begin
                    key_reg <= (ready_fxor & hold_i & done_o) ? key_out_f : key_reg ;
                    // done_o <= 1'b1;
                end
                
                4'b0011,4'b0101,
                4'b0111,4'b1001,
                4'b1011,4'b1101:
                begin
                    key_reg <= (ready_gxor & hold_i & done_o) ? key_out_g : key_reg ;
                    // done_o <= 1'b1;
                end
                
                default:;
                
            endcase
        end
        else begin
            key_reg <= '0;
            // done_o  <= 1'b0;
        end
    end
    
    always_latch
    begin
        key_round2 = (done_o) ? key_round1 : key_round2;
        key_round1 = (done_o) ? key_reg : key_round1;
    end

    assign busy_o = busy_fxor | busy_gxor | done_o;
    assign key_o = key_reg;
    
endmodule 