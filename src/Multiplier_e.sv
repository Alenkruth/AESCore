////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   Multiply with {e} in GF(2^4)                                    //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the multiplier unit used to perform      //
//                multiplication with {e} in the GF(2^4) field.                   //
//                https://link.springer.com/chapter/10.1007/3-540-45760-7_6       //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module Multiplier_e 
	(
	// input operand
  input logic [3:0] operand_i,
    
  // output product
  output logic [3:0] product_o
	);

  //wires
  logic bit_A;
  logic bit_B;
  
  //redundant computations
	assign bit_A = operand_i[0] ^ operand_i[1];
	assign bit_B = operand_i[2] ^ operand_i[3];

	//product computations
	assign product_o[3] = bit_A ^ bit_B;
	assign product_o[2] = bit_A ^ operand_i[2];
	assign product_o[1] = bit_A;
	assign product_o[0] = operand_i[1] ^ bit_B; 

endmodule