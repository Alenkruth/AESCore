`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   G Function in Key Expansion                                     //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the SubBytes operation in the Key        //
//                expansion. 4 instances of the SubByte module is utilized in     //
//                parallel.                                                       //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

module FunctionG(
    // word in 
    input logic [31:0] word_i,
    // word out
    output logic [31:0] word_o,
    // clk input
    input logic clk_i,
    // enable signal
    input logic en_i,
    // reset in
    input logic rst_n,
    // ready output
    output logic ready_o 
    );
    
    logic [31:0] subword;
    enum logic [1:0] {READY,IDLE,OUT} cs,ns;
    
    SubByte Instance3 
                    (.data_i(word_i[31:24]),
                     .data_o(subword[31:24]));
    SubByte Instance2 
                    (.data_i(word_i[23:16]),
                     .data_o(subword[23:16]));
    SubByte Instance1 
                    (.data_i(word_i[15: 8]),
                     .data_o(subword[15: 8]));
    SubByte Instance0 
                    (.data_i(word_i[ 7: 0]),
                     .data_o(subword[ 7: 0]));   
    assign word_o = subword;
    always_comb
    begin
        ready_o = 1'b0;
        ns = cs;
        unique case(cs)
            READY:
            begin
                ready_o = 1'b1;
                ns = IDLE;
            end
            IDLE:
            begin
                ready_o = 1'b0;
                ns = OUT;
            end
            OUT:
            begin
                ready_o = 1'b1;
                ns = READY;
            end
            default:;
        endcase
    end
    
    always_ff @(posedge clk_i, negedge rst_n)
    begin
        if (~rst_n)
        begin
            cs <= IDLE;
        end
        else if (en_i)
        begin
            cs <= ns;
        end
        else if (~en_i)
            cs <= cs;                        
    end                                   
endmodule
