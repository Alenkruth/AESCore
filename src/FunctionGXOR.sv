`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   G Function with XORs in Key Expansion                           //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the SubBytes operation in the Key        //
//                expansion. 4 instances of the SubByte module is utilized in     //
//                parallel. The subsequent XORs are performed on the words.        //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////


 module FunctionGXOR(
    // input word
    input logic [31:0] word_i,
    // input clk_i
    input logic clk_i,
    // input reset
    input logic rst_n,
    // input enable
    input logic en_i,
    // key from i-2th round
    input logic [127:0] key_round2_i,
    // output ready
    output logic ready_o,
    // output busy
    output logic busy_o,
    // output key for the current round
    output [127:0] key_o
    );
    
    logic [ 31:0] word_g;
    logic [ 31:0] word_xor;
    logic [ 31:0] result_g;
    logic [127:0] result_xor;
    
    logic enable_g;
    logic enable_xor;
    
    logic ready_g_o;
    logic ready_xor_o;
    
    logic [127:0] key_reg;
    
    assign word_g   = word_i ;
    assign word_xor = result_g;
    assign busy_o   = enable_g | enable_xor | ready_o ;
    
    FunctionG funcG
                    (.word_i      (word_g       ),
                     .word_o      (result_g     ),
                     .clk_i       (clk_i        ),
                     .en_i        (enable_g     ),
                     .rst_n       (rst_n        ),
                     .ready_o     (ready_g_o    ));
                     
    XORkey xors
                    (.op_xor_i    (word_xor     ),
                     .clk_i       (clk_i        ),
                     .rst_n       (rst_n        ),
                     .en_i        (enable_xor   ),
                     .key_xor_i   (key_round2_i ),
                     .ready_o     (ready_xor_o  ),
                     .key_round_o (result_xor   ));
                     
    enum logic [2:0] {READY,IDLE,COMPUTE_G,COMPUTE_XOR,LOAD} fsm_cs,fsm_ns;
    
    always_comb
    begin
        enable_g = 1'b0;
        enable_xor = 1'b0;
        fsm_ns = fsm_cs;
        ready_o = 1'b0;
                
        unique case(fsm_cs)
            READY:
            begin
                ready_o = 1'b1;
                fsm_ns = IDLE;    
            end
            IDLE:
            begin
                //ready_o = 1'b0;
                fsm_ns  = COMPUTE_G;
            end
            
            COMPUTE_G:
            begin
                // ready_o = 1'b0;
                enable_g = 1'b1;
                if (ready_g_o) fsm_ns = COMPUTE_XOR;
            end
            
            COMPUTE_XOR:
            begin
                // ready_o = 1'b0;
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
    
    always_ff @(posedge clk_i,negedge rst_n)
    begin
        if(~rst_n)
            fsm_cs <= IDLE;
        else if (en_i)
            fsm_cs <= fsm_ns;
        else if (~en_i)
            fsm_cs <= fsm_cs; 
    end
    
    always_ff @(posedge clk_i)
    begin
        if (rst_n) key_reg <= (ready_xor_o) ? result_xor : key_reg ;
        // else key_reg <= '0;
    end
    
    assign key_o = key_reg;

endmodule
