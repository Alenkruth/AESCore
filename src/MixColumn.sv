`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   MixColumns Module (top)                                         //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the MixColumns operation of Rijndael     //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

//`include "MultiplyByTwo.sv"
module MixColumn(
    //input data 
    input logic [127:0] data_i,
    //control signals
    //input logic rst_ni,
    //output data
    output logic [127:0] data_o
    );
    
    //wire to store shifted byte
    logic [7:0] shifted;
    
    // function to implement multiplication by two
    function [7:0] MultiplyTwo;
    input logic [7:0] byte_i;
    begin
        shifted[7] = byte_i[6];
        shifted[6] = byte_i[5];
        shifted[5] = byte_i[4];
        shifted[4] = byte_i[3];
        shifted[3] = byte_i[2];
        shifted[2] = byte_i[1];
        shifted[1] = byte_i[0];
        shifted[0] = 1'b0;
        if (byte_i[7] == 1)
            MultiplyTwo = shifted ^ 8'h1B;
        else MultiplyTwo = shifted;
    end  
    endfunction
    
    //function to multiply by three
    // we multiply by two and then x-or the value
    function [7:0] MultiplyThree;
    input logic [7:0] byte_i;
    begin
        MultiplyThree = MultiplyTwo(byte_i) ^ byte_i;
    end
    endfunction
    
    // the bytes in data_i are vertically arranged in a matrix to form the state matrix
    //  _                                                         _
    // | data_i[ 7: 0] data_i[39:32] data_i[71:64] data_i[103: 96] |
    // | data_i[15: 8] data_i[47:40] data_i[79:72] data_i[111:104] |
    // | data_i[23:16] data_i[55:48] data_i[87:80] data_i[119:112] |
    // |_data_i[31:24] data_i[63:56] data_i[95:88] data_i[127:120]_|
    //
    ////////////////////////////////////////////////////////////////////////////////////
    
    integer i;
    always_comb
    begin
        for(i = 0; i <= 3; i = i+1) begin
            /*data_o[(32*i)+:8]      = MultiplyTwo(data_i[(32*i)+:8]) ^
                                     MultiplyThree(data_i[((32*i)+8)+:8]) ^
                                     data_i[((32*i)+16)+:8] ^
                                     data_i[((32*i)+24)+:8];
            data_o[((32*i)+8)+:8]  = data_i[(32*i)+:8] ^
                                     MultiplyTwo(data_i[((32*i)+8)+:8]) ^
                                     MultiplyThree(data_i[((32*i)+16)+:8]) ^
                                     data_i[((32*i)+24)+:8];
            data_o[((32*i)+16)+:8] = data_i[(32*i)+:8] ^
                                     data_i[((32*i)+8)+:8] ^
                                     MultiplyTwo(data_i[((32*i)+16)+:8]) ^
                                     MultiplyThree(data_i[((32*i)+24)+:8]);
            data_o[((32*i)+24)+:8] = MultiplyThree(data_i[(32*i)+:8]) ^
                                     data_i[((32*i)+8)+:8] ^
                                     data_i[((32*i)+16)+:8] ^
                                     MultiplyTwo(data_i[((32*i)+24)+:8]);*/
                                     
            data_o[i*32+:8]  = MultiplyTwo(data_i[(i*32)+:8])^(data_i[(i*32 + 8)+:8])^(data_i[(i*32 + 16)+:8])^MultiplyThree(data_i[(i*32 + 24)+:8]);
            data_o[(i*32 + 8)+:8] = MultiplyThree(data_i[(i*32)+:8])^MultiplyTwo(data_i[(i*32 + 8)+:8])^(data_i[(i*32 + 16)+:8])^(data_i[(i*32 + 24)+:8]);
            data_o[(i*32 + 16)+:8] = (data_i[(i*32)+:8])^MultiplyThree(data_i[(i*32 + 8)+:8])^MultiplyTwo(data_i[(i*32 + 16)+:8])^(data_i[(i*32 + 24)+:8]);
            data_o[(i*32 + 24)+:8]  = (data_i[(i*32)+:8])^(data_i[(i*32 + 8)+:8])^MultiplyThree(data_i[(i*32 + 16)+:8])^MultiplyTwo(data_i[(i*32 + 24)+:8]);
        end
    end
    
    
endmodule