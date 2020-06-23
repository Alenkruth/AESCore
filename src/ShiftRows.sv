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
    input logic [127:0] state_i,
    input logic en_i,
    input logic clk_i,
    input logic rst_n,
    output logic done_o,
    output logic [127:0] state_o
    );
    
    logic [127:0] data;
    logic [127:0] state;
    logic done;
    
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
    assign data [127:120] = state_i[127:120];
    assign data [ 95: 88] = state_i[ 95: 88]; 
    assign data [ 63: 56] = state_i[ 63: 56];
    assign data [ 31: 24] = state_i[ 31: 24];
    
    // row1 (cyclic left shift in positions)
    assign data [119:112] = state_i[ 87: 80];
    assign data [ 87: 80] = state_i[ 55: 48];
    assign data [ 55: 48] = state_i[ 23: 16];
    assign data [ 23: 16] = state_i[119:112];
    
    // row2 (cyclic 2xleft shift in positions)
    assign data [111:104] = state_i[ 47: 40];
    assign data [ 79: 72] = state_i[ 15:  8];
    assign data [ 47: 40] = state_i[111:104];
    assign data [ 15:  8] = state_i[ 79: 72];
    
    // row3 (cyclic 3xleft shift in positions)
    assign data [103: 96] = state_i[  7:  0];
    assign data [ 71: 64] = state_i[103: 96];
    assign data [ 39: 32] = state_i[ 71: 64];
    assign data [  7:  0] = state_i[ 39: 32]; 
    
    always_ff @(posedge clk_i, negedge rst_n)
    begin
        if (~rst_n)
        begin
            state <= '0;
            done <= 1'b0;
        end

        else if (en_i)
        begin
            state <= data;
            done <= 1'b1;
        end

        else
        begin
            state <= state;
            done <= 1'b0;
        end
    end
      
    // assign state = (en_i & ~rst_n) ? data : state;
    assign state_o = state;
    assign done_o = done;
       
endmodule
