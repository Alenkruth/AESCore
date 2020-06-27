`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   X ORs post the F/G function to generate the key                 //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of 4 Xors performed on 32b words            //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////


module XORkey(
    // input word
    input logic [ 31:0] op_xor_i,
    // input clock
    input logic clk_i,
    // input key from n-2th round of expansion
    input logic [127:0] key_xor_i,
    // input enable
    input logic en_i,
    // input reset
    input logic rst_n,
    // output ready
    output logic ready_o,
    // output round key for the cureent round 
    output logic [127:0] key_round_o
    );

    logic [31:0] xorkey_in0;
    logic [31:0] xorkey_in2;
    logic [31:0] xorkey_in1;
    logic [31:0] xorkey_in3;
    logic [31:0] xor_out0;
    logic [31:0] xor_out1;
    logic [31:0] xor_out2;
    logic [31:0] xor_out3;
   
    enum logic {IDLE,OUT} sel_cs,sel_ns;   
    assign xorkey_in0 = key_xor_i[127:96];
    assign xorkey_in1 = key_xor_i[ 95:64];
    assign xorkey_in2 = key_xor_i[ 63:32];
    assign xorkey_in3 = key_xor_i[ 31: 0];
    
    xors instance1
                (.data_in (op_xor_i),
                 .key_in  (xorkey_in0),
                 .data_out(xor_out0));
  
    xors instance2
                (.data_in (xor_out0),
                 .key_in  (xorkey_in1),
                 .data_out(xor_out1));
   
    xors instance3
                (.data_in (xor_out1),
                 .key_in  (xorkey_in2),
                 .data_out(xor_out2));
                 
    xors instance4
                (.data_in (xor_out2),
                 .key_in  (xorkey_in3),
                 .data_out(xor_out3));
    
    always_comb
    begin
        ready_o = 1'b0;
        sel_ns = sel_cs;
        unique case(sel_cs)
            IDLE:
            begin
                ready_o = 1'b0;
                if (en_i)
                    sel_ns = OUT;
            end
            
            OUT:
            begin
                ready_o = 1'b1;
                sel_ns = IDLE;
            end
            
            default:;
        endcase
    end
    
    always_ff @(posedge clk_i, negedge rst_n)
    begin
        if (~rst_n)
        begin
            sel_cs <= IDLE;
        end
        else if (en_i)
            sel_cs <= sel_ns;
        else if (~en_i)
            sel_cs <= sel_cs;
                        
    end 
    
    assign key_round_o = ready_o ? ({xor_out0,xor_out1,xor_out2,xor_out3}) :'0;    

endmodule

module xors(
            input logic  [ 31:0] data_in,
            input logic  [ 31:0] key_in,
            output logic [ 31:0] data_out
            );
            
    always_comb
    begin
        data_out = data_in ^ key_in;
    end
endmodule