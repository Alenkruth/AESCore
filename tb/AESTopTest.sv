`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Author      : Alenkruth
// Language    : SystemVerilog
// Description : A simple testbench to test the functioning of the core in ECB
//               mode
///////////////////////////////////////////////////////////////////////////////               
module AESTopTest(

    );
    
    logic [127:0] plaintext_test;
    logic [255:0] key_test;
    logic [127:0] ciphertext_test;
    logic enable;
    logic reset;
    logic done;
    logic clock;
    logic clock_gated;
    logic [9:0] counter;

    
    AESTop DUT
            (.clk_i(clock_gated),
             .rst_n(reset),
             .en_i(enable),
             .plaintext_i(plaintext_test),
             .ciphertext_o(ciphertext_test),
             .done_o(done),
             .key_i(key_test));

    assign clock_gated = clock & enable;
    
    initial
    begin
        reset = 1'b0;
        clock = 1'b0;
        enable = 1'b0;
        forever
        begin
            clock = #10 ~clock;
        end
    end
    
    initial 
    begin
        #10;
        reset = 1'b1;
        enable = 1'b1;
        ///////////////////////////////////////////////////////
        // test vectors from the AES specfication NIST.FIPS 197
        // plaintext_test = 128'h00112233445566778899aabbccddeeff;
        // key_test = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
        // the cipher text is 8ea2b7ca516745bfeafc49904b496089
        //////////////////////////////////////////////////////

        ///////////////////////////////////////////////////////
        // custom test vectors
        plaintext_test = 128'h616c656e6b72757468616c656e6b7275; // alenkruthalenkru in ASCII
        key_test = 256'h7465737474657374746573747465737474657374746573747465737474657374; // testtesttesttesttesttesttesttest in ASCII
        // the cipher text is 4419ce8172f99fa38dc6119260edb3f8
        ///////////////////////////////////////////////////////
        #4000;
        $stop;
    end

    initial
    begin
        counter = '0;
        forever
        begin 
            @(posedge clock_gated);
            counter <= counter + 1'b1;
       end
    end
endmodule
