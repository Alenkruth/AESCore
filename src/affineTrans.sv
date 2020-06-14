////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   Affine Transformation                                           //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the affine transformation                //
//                (q=aff_trans(a))                                                //
//                https://link.springer.com/chapter/10.1007/3-540-45760-7_6       //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module affineTrans
	(
	//input data
	input logic [7:0] data_i,

	//output data
	output logic [7:0] data_o
	);

	//wires
	logic bit_A;
	logic bit_B;
	logic bit_C;
	logic bit_D;

	//redundant computations
	assign bit_A = data_i[0] ^ data_i[1];
	assign bit_B = data_i[2] ^ data_i[3];
	assign bit_C = data_i[4] ^ data_i[5];
	assign bit_D = data_i[6] ^ data_i[7];

	//affine transfromation
	assign data_o[7] = data_i[3] ^ bit_C ^ bit_D;
	assign data_o[6] = (~data_i[6]) ^ bit_B ^ bit_C;
	assign data_o[5] = (~data_i[1]) ^ bit_B ^ bit_C;
	assign data_o[4] = data_i[4] ^ bit_A ^ bit_B;
	assign data_o[3] = data_i[7] ^ bit_A ^ bit_B;
	assign data_o[2] = data_i[2] ^ bit_A ^ bit_D;
	assign data_o[1] = (~data_i[5]) ^ bit_A ^ bit_D;
	assign data_o[0] = (~data_i[0]) ^ bit_C ^ bit_D;

endmodule 