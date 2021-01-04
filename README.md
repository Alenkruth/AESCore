# AESCore
AES core capable of performing 256bit Encryption in CTR/GCM modes.

The design is complete, You can clone and test the design. (Small changes may be made in the future) <br/>

Branch Master -> Plain old AES (ECB Mode) <br/>
Branch CTR    -> AES in CTR mode (A slice of the key is taken as IV) <br/>

## Organization of the Repository
**Source Files** <br/>
The [src](https://github.com/Alenkruth/AESCore/tree/master/src) contains all the modules.
[AESTop](https://github.com/Alenkruth/AESCore/blob/master/src/AESTop.sv) is the top-level module.

**Test Bench** <br/>
The [tb](https://github.com/Alenkruth/AESCore/blob/master/tb) consists of a simple testbench.
The VCD files in the [tb](https://github.com/Alenkruth/AESCore/blob/master/tb) directory are obtained using Modelsim PE.
