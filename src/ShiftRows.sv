`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   AddRoundKey Module                                              //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the ShiftRows operation of Rijndael      //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////


module ShiftRow(
    input [127:0] data_i,
    output [127:0] data_o
    );
    
    // the bytes in data_i are vertically arranged in a matrix to form the state matrix
    //  _                                                               _
    // | data_i[127:120] data_i[ 95:88 ] data_i[ 63:56 ] data_i[ 31:24 ] |
    // | data_i[119:112] data_i[ 87:80 ] data_i[ 55:48 ] data_i[ 23:16 ] |
    // | data_i[111:104] data_i[ 79:72 ] data_i[ 47:40 ] data_i[ 15: 8 ] |
    // |_data_i[103: 96] data_i[ 71:64 ] data_i[ 39:32 ] data_i[ 7:0 ]  _|
    //
    // the positions elements of the state matrix are shifted
    ////////////////////////////////////////////////////////////////////////////////////
    
    // row0 (no shift)
    assign data_o [127:120] = data_i[127:120];
    assign data_o [ 95: 88] = data_i[ 95: 88]; 
    assign data_o [ 63: 56] = data_i[ 63: 56];
    assign data_o [ 31: 24] = data_i[ 31: 24];
    
    // row1 (cyclic left shift in positions)
    assign data_o [119:112] = data_i[ 87: 80];
    assign data_o [ 87: 80] = data_i[ 55: 48];
    assign data_o [ 55: 48] = data_i[ 23: 16];
    assign data_o [ 23: 16] = data_i[119:112];
    
    // row2 (cyclic 2xleft shift in positions)
    assign data_o [111:104] = data_i[ 47: 40];
    assign data_o [ 79: 72] = data_i[ 15:  8];
    assign data_o [ 47: 40] = data_i[111:104];
    assign data_o [ 15:  8] = data_i[ 79: 72];
    
    // row3 (cyclic 3xleft shift in positions)
    assign data_o [103: 96] = data_i[  7:  0];
    assign data_o [ 71: 64] = data_i[103: 96];
    assign data_o [ 39: 32] = data_i[ 71: 64];
    assign data_o [  7:  0] = data_i[ 39: 32]; 
       
endmodule
