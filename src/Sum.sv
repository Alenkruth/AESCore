////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   Sum in GF(16)                                                   //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the adder circuit to perform             //
//                addition of two nibbles in GF(16)                               //
//                https://link.springer.com/chapter/10.1007/3-540-45760-7_6       //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module Sum
	(
	//input data
	input logic [3:0] operand_a_i,
	input logic [3:0] operand_b_i,

	//output data
	output logic [3:0] sum_o
	);

	assign sum_o[3] = operand_a_i[3] ^ operand_b_i[3];
	assign sum_o[2] = operand_a_i[2] ^ operand_b_i[2];
	assign sum_o[1] = operand_a_i[1] ^ operand_b_i[1];
	assign sum_o[0] = operand_a_i[0] ^ operand_b_i[0];
	//assign sum_o = operand_a_i + operand_b_i;

endmodule 