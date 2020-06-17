`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   16 Instances of SubBytes Module                                 //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the SubBytes operation                   //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////


module SubByte16(
    input en_i,
    input rst_n,
    input clk_i,
    input logic  [127:0] state_i,
    output logic done_o,
    output logic [127:0] state_o
    
    );
    
    logic [127:0] data;
    logic [127:0] state;
    logic done;
    
    SubByte sub0 
                (.data_i(state_i[127:120]),
                 .data_o(data   [127:120]));
                 
    SubByte sub1 
                (.data_i(state_i[119:112]),
                 .data_o(data   [119:112]));
                 
    SubByte sub2 
                (.data_i(state_i[111:104]),
                 .data_o(data   [111:104]));
                 
    SubByte sub3 
                (.data_i(state_i[103: 96]),
                 .data_o(data   [103: 96]));
                 
    SubByte sub4 
                (.data_i(state_i[ 95: 88]),
                 .data_o(data   [ 95: 88]));
                 
    SubByte sub5 
                (.data_i(state_i[ 87: 80]),
                 .data_o(data   [ 87: 80]));
                 
    SubByte sub6 
                (.data_i(state_i[ 79: 72]),
                 .data_o(data   [ 79: 72]));
                 
    SubByte sub7 
                (.data_i(state_i[ 71: 64]),
                 .data_o(data   [ 71: 64]));
                 
    SubByte sub8 
                (.data_i(state_i[ 63: 56]),
                 .data_o(data   [ 63: 56]));
                 
    SubByte sub9 
                (.data_i(state_i[ 55: 48]),
                 .data_o(data   [ 55: 48]));
                 
    SubByte sub10 
                (.data_i(state_i[ 47: 40]),
                 .data_o(data   [ 47: 40]));
                 
    SubByte sub11 
                (.data_i(state_i[ 39: 32]),
                 .data_o(data   [ 39: 32]));
    
    SubByte sub12
                (.data_i(state_i[ 31: 24]),
                 .data_o(data   [ 31: 24]));
    
    SubByte sub13 
                (.data_i(state_i[ 23: 16]),
                 .data_o(data   [ 23: 16]));
                 
    SubByte sub14 
                (.data_i(state_i[ 15:  8]),
                 .data_o(data   [ 15:  8]));

    SubByte sub15
                (.data_i(state_i[  7:  0]),
                 .data_o(data   [  7:  0]));
                 
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
            done  <= 1'b1;
        end
            
        else 
        begin
            state <= state;
            done  <= 1'b0;
        end
    end
    
    assign state_o = state;
    assign done_o  = done;

endmodule