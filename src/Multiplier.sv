////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   Multiplier in GF(2^4)                                           //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the multiplier unit used to perform      //
//                multiplication in the GF(2^4) field.                            //
//                https://link.springer.com/chapter/10.1007/3-540-45760-7_6       //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module Multiplier
	(
  // input data
  input logic [3:0] operand_a_i,
  input logic [3:0] operand_b_i,

  //output product
  output logic [3:0] product_o
	);

	//wires 
	logic bit_A;
	logic bit_B;

	//multiplication operation
	//redundant operations
	assign bit_A = operand_a_i[0] ^ operand_a_i[3];
	assign bit_B = operand_a_i[2] ^ operand_a_i[3];

	//product computation
	assign product_o[3] = (operand_a_i[3] & operand_b_i[0]) ^ 
												(operand_a_i[2] & operand_b_i[1]) ^
												(operand_a_i[1] & operand_b_i[2]) ^ 
												(bit_A & operand_b_i[3]);
	assign product_o[2] = (operand_a_i[2] & operand_b_i[0]) ^
												(operand_a_i[1] & operand_b_i[1]) ^
												(bit_A & operand_b_i[2]) ^
												(bit_B & operand_b_i[3]);
	assign product_o[1] = (operand_a_i[1] & operand_b_i[0]) ^ 
												(bit_A & operand_b_i[1]) ^
												(bit_B & operand_b_i[2]) ^
												((operand_a_i[1] ^ operand_a_i[2]) & operand_b_i[3]);
	assign product_o[0] = (operand_a_i[0] & operand_b_i[0]) ^ 
												(operand_a_i[3] & operand_b_i[1]) ^
												(operand_a_i[2] & operand_b_i[2]) ^ 
												(operand_a_i[1] & operand_b_i[3]);
endmodule