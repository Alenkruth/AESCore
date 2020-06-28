          /*data_o[(32*i)+:8]      = MultiplyTwo(data_i[(32*i)+:8]) ^
                                     MultiplyThree(data_i[((32*i)+8)+:8]) ^
                                     data_i[((32*i)+16)+:8] ^
                                     data_i[((32*i)+24)+:8];
            data_o[((32*i)+8)+:8]  = data_i[(32*i)+:8] ^
                                     MultiplyTwo(data_i[((32*i)+8)+:8]) ^
                                     MultiplyThree(data_i[((32*i)+16)+:8]) ^
                                     data_i[((32*i)+24)+:8];
            data_o[((32*i)+16)+:8] = data_i[(32*i)+:8] ^
                                     data_i[((32*i)+8)+:8] ^
                                     MultiplyTwo(data_i[((32*i)+16)+:8]) ^
                                     MultiplyThree(data_i[((32*i)+24)+:8]);
            data_o[((32*i)+24)+:8] = MultiplyThree(data_i[(32*i)+:8]) ^
                                     data_i[((32*i)+8)+:8] ^
                                     data_i[((32*i)+16)+:8] ^
                                     MultiplyTwo(data_i[((32*i)+24)+:8]);*/
