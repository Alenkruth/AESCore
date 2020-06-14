`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   AddRoundKey Module                                              //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the AddRoundKey operation of Rijndael    //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////


module AddRoundKey(
    //input data and key wires
    input logic [127:0] data_i,
    input logic [127:0] key_i,
    //output data
    output logic [127:0] data_o
    );
    
    //Add roinf key is a simple bitwise XOR operation
    assign data_o = data_i ^ key_i;

endmodule
