////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   Square in GF(2^4)                                               //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the circuitry used to perform            //
//                squaring in the GF(2^4) field.                                  //
//                https://link.springer.com/chapter/10.1007/3-540-45760-7_6       //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module Squarer
	(
	//input operand
	input logic [3:0] operand_i,

	//output squared
	output logic [3:0] squared_o
	);

	//squaring operation
	assign squared_o[3] = operand_i[3];
	assign squared_o[2] = operand_i[1] ^ operand_i[3];
	assign squared_o[1] = operand_i[2];
	assign squared_o[0] = operand_i[0] ^ operand_i[2];

endmodule