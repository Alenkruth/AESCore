`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   Rotate Word in Key Expansion                                    //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the Rotate word operation in the Key     //
//                expansion.                                                      //
//----------------NOT USED--------------------------------------------------------//
////////////////////////////////////////////////////////////////////////////////////


module RotateState(
    //input state
    input logic [31:0] word_i,
    //output state
    output logic [31:0] word_o
    );
    
    //////////////////////////////////////////////////////////////////////////////////
    // input word  => [ B0 B1 B2 B3 ]
    // output word => [ B1 B2 B3 B0 ] 
    //////////////////////////////////////////////////////////////////////////////////
    
    assign word_o[31:24] = word_i[23:16];
    assign word_o[23:16] = word_i[15: 8];
    assign word_o[15: 8] = word_i[ 7: 0];
    assign word_o[ 7: 0] = word_i[31:24]; 
    
endmodule
