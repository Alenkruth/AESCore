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
    input logic [127:0] state_i,
    input logic [127:0] key_i,
    // handshake signals
    input logic en_i,
    input logic rst_n,
    // clock signal
    input logic clk_i,
    //output data
    output logic done_o,
    output logic [127:0] state_o
    );
    
    logic [127:0] data;
    logic [127:0] state;
    logic done;
    
    //Add roinf key is a simple bitwise XOR operation
    assign data = state_i ^ key_i;
    
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
    assign done_o = done;

endmodule
