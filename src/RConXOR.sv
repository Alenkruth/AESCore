`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   X-Or with round constant                                        //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the XOR of state and RCon in the Key     //
//                expansion.                                                      //
//-----------------NOT USED-------------------------------------------------------//
////////////////////////////////////////////////////////////////////////////////////


module RConXOR(
    //input state
    input logic [31:0] word_i,
    //input Key expansion round value
    //input logic [2:0] round,
    //input rcon
    input logic [7:0] rcon_i,
    //output state
    output logic [31:0] word_o
    //test output
    //output logic [7:0] rcon_o
    );
    
    // rcon value 
    //assign rcon = 8'h01;
    //assign rcon_o = rcon_i;
    assign word_o = word_i ^ {rcon_i,24'h000000};
    //if (rcon_i == 8'h40) rcon_i = 8'h01;
    //else rcon_i = rcon_i << 1;
        
endmodule
