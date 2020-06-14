////////////////////////////////////////////////////////////////////////////////////
// Author:        Alenkruth                                                       //
// Design Name:   SubBytes Module (top)                                           //
// Project Name:  RISC-V Crypto Extension                                         //
// Language:      System Verilog                                                  //
// Description:   The module consists of the SubBytes operation of Rijndael       //
//                implemented as a circuit rather than a lookup table.            //
//                https://link.springer.com/chapter/10.1007/3-540-45760-7_6       //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps 
module SubByte
	(
	//clock and reset
	//input logic clk_i,
	//input logic rst_ni,

	//Control and status signals
	//input logic en_i,
	//output logic busy_o,
  //output logic inv_o,
  //output logic aff_o,

	//Data Signals 
	input logic [7:0] data_i,
	output logic [7:0] data_inv,
	output logic [7:0] data_o
	);

	logic [7:0] data;   //input data byte
	logic [3:0] nib_high, nib_low;  //data mapped to a nibble using map()
  logic [3:0] nib_highsquared, nib_lowsquared; //nibble high and low squared
  logic [3:0] nib_highxe;  //squared high nibble multiplied with {e}
  logic [3:0] nib_hladda;  //highxe and lowsquared nibble added
  logic [3:0] nib_hlmul;   //high and low nibble multiplied
  logic [3:0] nib_hladded; //high and low nibble added
  logic [3:0] nib_added;   //hladda added with hlmul
  logic [3:0] nib_inverse; //inverse of nib_added in GF(16)
  logic [3:0] nib_hinv;    //inverse multiplied with nib_high
  logic [3:0] nib_linv;    //inverse multiplied with nib_hlmulb
  //logic [7:0] data_inv;    //inverted byte data in GF(256)

  //assign value from data_i to data
  assign data = data_i;

  //map to nibble
  logic bit_A;  //data[1] exor data[7]
  logic bit_B;  //data[5] exor data[7]
  logic bit_C;  //data[4] exor data[6]

  //map from nibble (inverse map)
  logic bit_AI;
  logic bit_BI;

  //redundant computations
  assign bit_A = data[1] ^ data[7];
  assign bit_B = data[5] ^ data[7];
  assign bit_C = data[4] ^ data[6];
  
  //higher nibble
  assign nib_high[3] = bit_B;
  assign nib_high[2] = bit_B ^ data[2] ^ data[3];
  assign nib_high[1] = bit_A ^ bit_C;
  assign nib_high[0] = bit_C ^ data[5];  
  //lower nibble
  assign nib_low[3] = data[2] ^ data[4];
  assign nib_low[2] = bit_A;
  assign nib_low[1] = data[1] ^ data[2];
  assign nib_low[0] = bit_C ^ data[0] ^ data[5];

  Squarer squarer1 
  				(
  				.operand_i(nib_high),
  				.squared_o(nib_highsquared)
  				);
  Squarer squarer2 
  				(
  				.operand_i(nib_low),
  				.squared_o(nib_lowsquared)
  				);
  Multiplier multiply1 
  				(
  				.operand_a_i(nib_high),
  				.operand_b_i(nib_low),
  				.product_o  (nib_hlmul)
  				);
  Sum sum1
  				(
  				.operand_a_i(nib_high),
  				.operand_b_i(nib_low),
  				.sum_o      (nib_hladded)
  				);
  Multiplier_e multiplye
  				(
  				.operand_i(nib_highsquared),
  				.product_o(nib_highxe)
  				);
  Sum sum2
  				(
  				.operand_a_i(nib_highxe),
  				.operand_b_i(nib_lowsquared),
  				.sum_o			(nib_hladda)
  				);
  Sum sum3
  				(
  				.operand_a_i(nib_hladda),
  				.operand_b_i(nib_hlmul),
  				.sum_o			(nib_added)
  				);
  Inverse inverse
  				(
  				.data_i   (nib_added),
  				.invdata_o(nib_inverse)
  				);
  Multiplier multiply2
  				(
  				.operand_a_i(nib_high),
  				.operand_b_i(nib_inverse),
  				.product_o  (nib_hinv)
  				);
  Multiplier multiply3
  				(
  				.operand_a_i(nib_inverse),
  				.operand_b_i(nib_hladded),
  				.product_o  (nib_linv)
  				);

  //inverse map function
  
  //redundant computations
  assign bit_AI = nib_linv[1] ^ nib_hinv[3];
  assign bit_BI = nib_hinv[0] ^ nib_hinv[1];

  //output byte
  assign data_inv[7] = bit_BI ^ nib_linv[2] ^ nib_hinv[3];
  assign data_inv[6] = bit_AI ^ nib_linv[2] ^
  									 nib_linv[3] ^ nib_hinv[0];
  assign data_inv[5] = bit_BI ^ nib_linv[2];
  assign data_inv[4] = bit_AI ^ bit_BI ^ nib_linv[3];
  assign data_inv[3] = bit_BI ^ nib_linv[1] ^ nib_hinv[2];
  assign data_inv[2] = bit_AI ^ bit_BI;
  assign data_inv[1] = bit_BI ^ nib_hinv[3];
  assign data_inv[0] = nib_linv[0] ^ nib_hinv[0];

  affineTrans affine1
  				(
  				.data_i(data_inv),
  				.data_o(data_o)
  				);

endmodule 