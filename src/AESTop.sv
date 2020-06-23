`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   Top Module for the AES core (AESStages + KeySchedule)           //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module implements a FSM for operation of Rijndael           //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

module AESTop(
    input logic clk_i,
    input logic rst_n,
    input logic [127:0] plaintext_i,
    input logic [255:0] key_i,
    input logic en_i,  // acts like a hold signal
    output logic done_o,
    output logic [127:0] ciphertext_o    
    );
    
    // input and output data for the modules
    logic [255:0] keySchedule_in;
    logic [127:0] keySchedule_out;
    logic [127:0] rkeySchedule_in;
    logic [127:0] AESround_in;
    logic [127:0] AESroundn_out;
    logic [127:0] AESround_out;
    logic [127:0] plaintext;
    logic [127:0] ciphertext;
    
    // round counter
    logic [3:0] kround_count;
    logic [3:0] rround_count;
    logic [3:0] round_count_in;
    
    // clock gating
    logic clk_g;
    assign clk_g = clk_i & en_i;
    
    // enable for the modules
    logic enable_round;
    logic enable_keyschedule;
    
    // reset signals 
    logic reset_round;
    logic reset_keyschedule;
    logic reset_roundin;
    logic reset_keyschedulein;
    assign reset_roundin = rst_n & reset_round;
    assign reset_keyschedulein = rst_n & reset_keyschedule;
    
    // hold signals for synchronization
    logic hold_round;
    logic hold_keyschedule;
    
    // ready/done signals
    logic done_round;
    logic done_keyschedule;
    
    // busy signal
    logic busy_keyschedule;
    
    // signals for the round module
    logic last_round;
    logic zero_round;
    
    AESStages round
                (.round_state_i(AESround_in),
                 .round_key_i(rkeySchedule_in),
                 .en_i(enable_round),
                 .clk_i(clk_g),
                 .rst_n(reset_roundin),
                 .hold_i(hold_round),
                 .zero_round_i(zero_round),
                 .final_round_i(last_round),
                 .done_o(done_round),
                 .round_state_o(AESround_out));
                 
    KeySchedule scheduler
                (.key_i(keySchedule_in),
                 .clk_i(clk_g),
                 .en_i(enable_keyschedule),
                 .hold_i(hold_keyschedule),
                 .round_count_i(round_count_in),
                 .rst_n(reset_keyschedulein),
                 .done_o(done_keyschedule),
                 .busy_o(busy_keyschedule),
                 .key_o(keySchedule_out));
                 
    // fsm for key schedule
    enum logic [1:0] {IDLE_K,WAIT_K,KEYGENERATE,LOAD_K} key_cs,key_ns;
    
    // fsm for round 
    enum logic [1:0] {IDLE_R,WAIT_R,ROUND,LOAD_R} round_cs,round_ns;
    
    // handshake signals
    logic hsdone_keyschedule;
    logic hsdone_round;
    
    // key schedule FSM
    assign keySchedule_in = key_i;
    assign round_count_in = kround_count;
    
    always_comb
    begin
        key_ns = key_cs;
        hsdone_keyschedule = 1'b0;
        reset_keyschedule = 1'b1;
        // kround_count = kround_count;
        enable_keyschedule = 1'b1;
        hold_keyschedule = 1'b0;
        
        unique case(key_cs)
        
        IDLE_K:
        begin
            key_ns = KEYGENERATE;
            reset_keyschedule = 1'b0;
            // kround_count = 4'b0000;
        end
        
        WAIT_K:
        begin
            if (~hsdone_round) 
            begin
                hsdone_keyschedule = 1'b1; 
            end
            if (hsdone_round)
            begin
                // kround_count = kround_count+1;
                hsdone_keyschedule = 1'b1;
                key_ns = KEYGENERATE;
            end
        end
        
        KEYGENERATE:
        begin
            hold_keyschedule = 1'b1;
            if (done_keyschedule) 
            begin
                key_ns = LOAD_K;
            end
        end
        
        LOAD_K:
        begin
            key_ns = WAIT_K;
        end
        
        default:;
        
        endcase
    end
    
    always_latch
    begin
        rkeySchedule_in = (hsdone_round & hsdone_keyschedule) ? keySchedule_out : rkeySchedule_in; 
    end
    
    // round FSM
    assign last_round = ((rround_count == 4'b1110)& hold_round) ? 1'b1:1'b0;
    assign zero_round = ((rround_count == 4'b0000)& hold_round) ? 1'b1:1'b0;
    assign plaintext = plaintext_i;
    assign AESround_in = ( zero_round ) ? plaintext : AESroundn_out; 
        
    always_comb
    begin
        round_ns = round_cs;
        reset_round = 1'b1;
        hold_round = 1'b0;
        hsdone_round = 1'b0;
        enable_round = 1'b1;
        
        unique case(round_cs)
        
        IDLE_R:
        begin
            reset_round = 1'b0;
            if (kround_count != 4'b0000)
            begin
                round_ns = ROUND;
            end
            else
            begin
                hsdone_round = 1'b1;
                if (hsdone_keyschedule) round_ns = ROUND;
            end
        end
        
        WAIT_R:
        begin
            if (~hsdone_keyschedule) 
            begin
                hsdone_round = 1'b1; 
            end
            if (hsdone_keyschedule)
            begin
                // kround_count = kround_count+1;
                hsdone_round = 1'b1;
                round_ns = ROUND;
            end
        end
        
        ROUND:
        begin
            hold_round = 1'b1;
            if (done_round)
            begin
                round_ns = LOAD_R;
            end
        end
        
        LOAD_R:
        begin
            round_ns = WAIT_R;
        end
        
        default:;
        
        endcase
    end 
    
    always_latch 
    begin
        AESroundn_out = (hsdone_round & hsdone_keyschedule) ? AESround_out : AESroundn_out;
    end 
               
    // controller for two FSMs      
    always_ff @(posedge clk_g ,negedge rst_n)
    begin
        if (~rst_n)
        begin
            key_cs <= IDLE_K;
            round_cs <= IDLE_R;
            kround_count <= 4'b0000;
            rround_count <= 4'b0000;     
        end
        
        else if(~en_i)
        begin
            key_cs <= key_cs;
            round_cs <= round_cs;
            kround_count <= kround_count;
            rround_count <= rround_count;
        end
        
        else
        begin
            key_cs <= key_ns;
            round_cs <= round_ns;
            if ( hsdone_keyschedule & hsdone_round)
            begin
                kround_count <= kround_count + 1'b1;
                if (kround_count == 4'b0000) rround_count <= 4'b0000;
                else rround_count <= rround_count + 1'b1; 
            end
            else 
            begin
                kround_count <= kround_count;
                rround_count <= rround_count;
            end
        end
    end
    
    always_ff @(posedge clk_g)
    begin
        if (rst_n) ciphertext <= (done_o & en_i) ? AESround_out : ciphertext;
        else ciphertext <= '0;
    end  
    
    assign ciphertext_o = ciphertext;
    assign done_o = (rround_count == 4'hf) & done_round;          
    
endmodule
