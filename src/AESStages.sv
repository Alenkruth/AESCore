`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   Wrapper module for all the AES encryption stages                //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of all the stages to perform one round      //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

module AESStages(
    input logic  [127:0] round_state_i,
    input logic  [127:0] round_key_i,
    input logic en_i,
    input logic rst_n,
    input logic clk_i,
    input logic hold_i,
    input logic zero_round_i,
    input logic final_round_i,
    output logic done_o,
    output logic [127:0] round_state_o
    );
    
    //gated clock for the system
    logic clk_g;
    assign clk_g = clk_i & hold_i;
    
    // enable signals for the modules
    logic enable_addroundkey;
    logic enable_shiftrow;
    logic enable_mixcolumn;
    logic enable_subbyte;
    
    // done signals from the modules
    logic done_addroundkey;
    logic done_mixcolumn;
    logic done_shiftrow;
    logic done_subbyte;
    
    // reset signals for the modules
    logic reset_subbyte_in;
    logic reset_mixcolumn_in;
    logic reset_shiftrow_in;
    logic reset_addroundkey_in;
    
    logic reset_subbyte;
    logic reset_mixcolumn;
    logic reset_shiftrow;
    logic reset_addroundkey;
    
    assign reset_subbyte_in = reset_subbyte & rst_n & hold_i;
    assign reset_mixcolumn_in = reset_mixcolumn & rst_n & hold_i;
    assign reset_shiftrow_in = reset_shiftrow & rst_n & hold_i;
    assign reset_addroundkey_in = reset_addroundkey &rst_n & hold_i;
    
    // state inputs to stages
    logic [127:0] state_in_addroundkey;
    logic [127:0] state_in_subbyte;
    // no separate input wires are needed for the shiftrows & mixcolumns
    
    // state outputs from stages
    logic [127:0] state_out_addroundkey;
    logic [127:0] state_out_subbyte;
    logic [127:0] state_out_mixcolumn;
    logic [127:0] state_out_shiftrow;
    
    // output register
    logic [127:0] state_out_reg;
    
    // states of FSM
    enum logic [2:0] {IDLE,SUBBYTE,SHIFTROW,MIXCOLUMN,ADDROUNDKEY,LOAD} fsm_cs,fsm_ns;
    
    //assign input data for the addroundkey module
    assign state_in_addroundkey = (zero_round_i) ? round_state_i : state_out_mixcolumn;
    
    // assign input data for the subbyte module
    assign state_in_subbyte = round_state_i ;
      
    SubByte16 subbyte
                    (.state_i(state_in_subbyte  ),
                     .en_i   (enable_subbyte    ),
                     .clk_i  (clk_g             ),
                     .rst_n  (reset_subbyte_in  ),
                     .done_o (done_subbyte      ),
                     .state_o(state_out_subbyte ));
                     
    ShiftRow shiftrow
                    (.state_i(state_out_subbyte ),
                     .en_i   (enable_shiftrow   ),
                     .clk_i  (clk_g             ),
                     .rst_n  (reset_shiftrow_in ),
                     .done_o (done_shiftrow     ),
                     .state_o(state_out_shiftrow));
    
    MixColumn mixcolumn
                    (.state_i       (state_out_shiftrow ),
                     .en_i          (enable_mixcolumn   ),
                     .clk_i         (clk_g              ),
                     .rst_n         (reset_mixcolumn_in ),
                     .last_round_i  (final_round_i      ),
                     .done_o        (done_mixcolumn     ),
                     .state_o       (state_out_mixcolumn));
                     
    AddRoundKey arkey
                    (.state_i(state_in_addroundkey  ),
                     .key_i  (round_key_i           ),
                     .en_i   (enable_addroundkey    ),
                     .clk_i  (clk_g                 ),
                     .rst_n  (rst_n                 ),
                     .done_o (done_addroundkey      ),
                     .state_o(state_out_addroundkey ));
                     
    always_comb
    begin
        done_o             = 1'b0;
        enable_addroundkey = 1'b0;
        enable_subbyte     = 1'b0;
        enable_mixcolumn   = 1'b0;
        enable_shiftrow    = 1'b0;
        reset_subbyte      = 1'b1;
        reset_mixcolumn    = 1'b1;
        reset_shiftrow     = 1'b1;
        fsm_ns = fsm_cs;
        
        unique case(fsm_cs)
        
            IDLE:
            begin
                done_o = 1'b0;
                reset_subbyte = 1'b0;
                reset_mixcolumn = 1'b0;
                reset_shiftrow = 1'b0;
                if (zero_round_i) fsm_ns = ADDROUNDKEY;
                else fsm_ns = SUBBYTE;
            end
            
            SUBBYTE:
            begin
                done_o = 1'b0;
                enable_subbyte = 1'b1;
                //reset_mixcolumn = 1'b0;
                if (done_subbyte) fsm_ns = SHIFTROW; 
            end
            
            SHIFTROW:
            begin
                done_o = 1'b0;
                enable_shiftrow = 1'b1;
                if (done_shiftrow) fsm_ns = MIXCOLUMN;
            end
            
            MIXCOLUMN:
            begin
                done_o = 1'b0;
                if (final_round_i) enable_mixcolumn = 1'b0;
                else enable_mixcolumn = 1'b1;
                //reset_subbyte = 1'b0;
                if (done_mixcolumn) fsm_ns = ADDROUNDKEY;
            end
            
            ADDROUNDKEY:
            begin
                done_o = 1'b0;
                enable_addroundkey = 1'b1;
                //reset_subbyte = 1'b0;
                //reset_mixcolumn = 1'b0;
                if (done_addroundkey) fsm_ns = LOAD;
            end
            
            LOAD:
            begin
                done_o = 1'b1;
                fsm_ns = IDLE;
            end
            
            default:;
                    
        endcase
    end
    
    always_ff @(posedge clk_i, negedge rst_n)
    begin
        if (~rst_n)
        begin
            fsm_cs = IDLE;
        end
        
        else if (en_i)
        begin
            fsm_cs = fsm_ns;
        end
        
        else if (~en_i)
        begin
            fsm_cs = fsm_cs;
        end
    end
    
    always_ff @(posedge clk_i)
    begin
        if (rst_n) 
        begin
            state_out_reg <= (done_o & hold_i) ? state_out_addroundkey : state_out_reg;
        end
        
        else state_out_reg <= '0;
    end
    
    assign round_state_o = state_out_reg;
                      
endmodule
