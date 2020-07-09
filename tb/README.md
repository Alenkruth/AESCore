# AESCore <br/>
## Testbench <br/>
AESTopTest is a simple test bench which simulates encryption of a 128bit plaintext in CTR Mode. <br/>
The module does not use a nonce but can be modified to use one. As of now a slice of the Key in used as an IV.
ModelSim-Intel FPGA Starter Edition was used for simulation. <br/>
## VCD Files <br/>
[TestVector.vcd](https://github.com/Alenkruth/AESCore/tree/master/tb) contains the wave dump for the plaintext and key combination example provided in the [AES Documentation](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf). <br/>
[CustomTestVector.vcd](https://github.com/Alenkruth/AESCore/tree/master/tb) contains the wave dump for a random plaintext and key combination.<br/>

