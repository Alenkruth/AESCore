`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   F Function in Key Expansion                                     //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the F function with XORs in              //
//                the Key expansion                                               //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

module FunctionF(
    // input state
    input logic [31:0] word_i,
    // input rcon value
    input logic [7:0] rcon_i,
    //input key from i-2th round
    input logic [127:0] key_round2_i,
    // input clk_i
    input logic clk_i,
    // input reset
    input logic rst_n,
    // input enable
    input logic en_i,
    // output ready
    output logic ready_o,
    // output busy
    output logic busy_o,
    // output state
    output logic [127:0] key_o
    );
    
    // state after rotate word
    logic [31:0] result_rotate;
    // state after subbytes or G operation
    logic [31:0] result_g;
    // state after XOR with RCon is the input to the XORs
    logic [31:0] result_rcon;
    
    //127 bit key for the round
    logic [127:0] result_xor;
    logic [127:0] key_reg;
    
    // handshake signals
    logic enable_g;
    logic enable_xor;
    
    logic ready_g_o;
    logic ready_xor_o;
    
    enum logic [2:0] {READY,IDLE,COMPUTE_G_RCON,COMPUTE_XOR,LOAD} fsm_cs,fsm_ns;
           
    FunctionG funcG
                    (.word_i      (result_rotate),
                     .word_o      (result_g     ),
                     .clk_i       (clk_i        ),
                     .en_i        (enable_g     ),
                     .rst_n       (rst_n        ),
                     .ready_o     (ready_g_o    ));
                     
                     
    XORkey xors
                    (.op_xor_i    (result_rcon  ),
                     .clk_i       (clk_i        ),
                     .en_i        (enable_xor   ),
                     .rst_n       (rst_n        ),
                     .key_xor_i   (key_round2_i ),
                     .ready_o     (ready_xor_o  ),
                     .key_round_o (result_xor   ));
                     
    
    // rotate word
    assign result_rotate = (en_i) ? {word_i[23:16],word_i[15: 8],word_i[ 7: 0],word_i[31:24]} : word_i;
    // multiply with rcon
    // assign result_rcon = (enable_g & ready_g_o) ? (result_g ^ {rcon_i,24'h000000}) : result_rcon;
    assign busy_o = enable_g | enable_xor | ready_o;
    
    always_comb
    begin
        enable_g   = 1'b0;
        enable_xor = 1'b0;
        fsm_ns = fsm_cs;
        
        unique case (fsm_cs)
            READY:
            begin
                ready_o = 1'b1;
                fsm_ns = IDLE;
            end 
            
            IDLE:
            begin
                ready_o = 1'b0;
                fsm_ns = COMPUTE_G_RCON;
            end
            
            COMPUTE_G_RCON:
            begin
                ready_o = 1'b0;
                enable_g = 1'b1;
                if (ready_g_o) fsm_ns = COMPUTE_XOR;
            end
            
            COMPUTE_XOR:
            begin
                ready_o = 1'b0;
                enable_xor = 1'b1;
                if (ready_xor_o) fsm_ns = LOAD;
            end
            
            LOAD:
            begin
                ready_o = 1'b1;
                fsm_ns = READY;
            end
            
            default:;
        endcase
    end
    
    always_ff @(posedge clk_i, negedge rst_n)
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
    
    always_ff @(posedge clk_i)
    begin
        if (rst_n) key_reg <= (ready_xor_o) ? result_xor : key_reg ;
        // else key_reg <= '0;
        result_rcon <= (enable_g & ready_g_o) ? (result_g ^ {rcon_i,24'h000000}) : result_rcon;
    end
    assign key_o = key_reg;
endmodule