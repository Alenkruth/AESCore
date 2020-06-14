////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   Inverter in GF(2^4)                                             //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the inversion unit used to perform       //
//                inversion of a nibble in the GF(2^4) field.                     //
//                https://link.springer.com/chapter/10.1007/3-540-45760-7_6       //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module Inverse
	(
	//input data
	input logic [3:0] data_i,

	//inverted output data
	output logic [3:0] invdata_o
	);

	//wires
	logic bit_A; 

	//redundant computation
	assign bit_A = data_i[1] ^ data_i[2] ^ data_i[3] ^ 
								(data_i[1] & data_i[2] & data_i[3]);

	//inversion in GF(16)
	assign invdata_o[3] = bit_A ^ (data_i[0] & data_i[3]) ^
												(data_i[1] & data_i[3]) ^
												(data_i[2] & data_i[3]);
	assign invdata_o[2] = (data_i[0] & data_i[1]) ^ data_i[2] ^
												(data_i[0] & data_i[2]) ^ data_i[3] ^
												(data_i[0] & data_i[3]) ^ 
												(data_i[0] & data_i[2] & data_i[3]);
	assign invdata_o[1] = (data_i[0] & data_i[1]) ^
												(data_i[0] & data_i[2]) ^
												(data_i[1] & data_i[2]) ^ data_i[3] ^
												(data_i[1] & data_i[3]) ^ 
												(data_i[0] & data_i[1] & data_i[3]);
	assign invdata_o[0] = bit_A ^ data_i[0] ^ (data_i[0] & data_i[2]) ^
												(data_i[1] & data_i[2]) ^
												(data_i[0] & data_i[1] & data_i[2]);
endmodule 