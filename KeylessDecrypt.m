function passwordSessionKey = KeylessDecrypt()
    clear all;
    randomNumber = 8989;
     password = 80998;
    xoredPassRN= bitxor(randomNumber, password);
    Opt.input = 'array';
    Opt.output = 'hex';
    Opt.Method = 'SHA-512';
    hashOutput = DataHash(xoredPassRN, Opt);
    SMD = hex2bin(hashOutput(1:4)); %Short message digest
    LMD = [];
    for i = 1:16
        rotatedMD = circshift(SMD,i);
        hashedRotatedMD = DataHash(rotatedMD, Opt);
        LMD =[LMD,hex2bin(hashedRotatedMD)]  ;  
    end

    %%Divide LMD into blocks: address 7 bits, order 7 bits, current 3bits
    Q_I = [6 5 9 3 5 2 12;6 6 7 9 5 7 15;9 5 4 15 3 11 13];%Plain Text in blocks
    %Q_I = [4 8; 6 4; 8 5];
    Q_I_gray = decToGray(Q_I);
    [blocks,bitsPerBlock]= size(Q_I);

    %%Adding RS encoder
    N= 15;
    k = bitsPerBlock;
    M = 16;
    bps = 4;
    awgnChannel = comm.AWGNChannel('BitsPerSymbol',bps);
    rsEncoder = comm.RSEncoder('CodewordLength',N,'MessageLength',k);
    rsDecoder = comm.RSDecoder('CodewordLength',N,'MessageLength',k);
    errorRate = comm.ErrorRate('ComputationDelay',3);

    errorBits_raw = zeros(blocks, N );
    MRAMarray_Noisy = awgn(MRAMarray, snr,'measured');% more opitons
            Resistance_Noisy=  [];
            for i = 1: length(Cipher)
                if errorBits(i) == 1
                    Resistance_Noisy= [Resistance_Noisy MRAMarray_Noisy((address(i)*8)+current(i))];
                else
                    Resistance_Noisy= [Resistance_Noisy MRAMarray((address(i)*8)+current(i))];
                end             
            end

            %Resistance_Noisy = Resistance_Noisy_unordered(sortIdx_decrypt)
           %unsorted_vec = order_sorted(idx_rev);
            %Received Cipher
            Cipher_ordered = Cipher(idx_rev);
            Cipher_gray_ordered = Cipher_gray(idx_rev);

            RatioBtweenResistances(j,run) = (Cipher_ordered(1)/(1+(7.5*0.2)))/ Resistance_Noisy(1);

            Q_I_decrypted_encoded  = [];
            Q_I_gray_decrypted_encoded  = [];
            %Decryption according to the formula
            for i =1 :1:length(Cipher)-1
                Q_I_decrypted_encoded = [Q_I_decrypted_encoded  (Cipher_ordered(i+1)-Resistance_Noisy(i+1))/(0.2*Resistance_Noisy(i+1))];
                 Q_I_gray_decrypted_encoded  = [Q_I_gray_decrypted_encoded  (Cipher_gray_ordered(i+1)-Resistance_Noisy(i+1))/(0.2*Resistance_Noisy(i+1))];
            end
            m=1;
            for m = 1:length(Q_I_decrypted_encoded)

                if (Q_I_decrypted_encoded(m)) <= 0  
                   Q_I_decrypted_encoded_corrected(m) = 0;
                elseif (Q_I_decrypted_encoded(m)) >= N  
                   Q_I_decrypted_encoded_corrected(m) = N;
                else 
                    Q_I_decrypted_encoded_corrected(m) = Q_I_decrypted_encoded(m);
                end   
                if (Q_I_gray_decrypted_encoded(m)) <= 0  
                   Q_I_gray_decrypted_encoded_corrected(m) = 0;
                elseif (Q_I_gray_decrypted_encoded(m)) >= N  
                   Q_I_gray_decrypted_encoded_corrected(m) = N;
                else 
                    Q_I_gray_decrypted_encoded_corrected(m) = Q_I_gray_decrypted_encoded(m);
                end   
            end
    %         %Q_I_Mapped =(Q_I_decrypted_encoded-min(Q_I_decrypted_encoded))*(15)/(max(Q_I_decrypted_encoded)-min(Q_I_decrypted_encoded));
    %         Q_I_decrypted_gf = gf(round(Q_I_decrypted_encoded),5);
    %         %Q_I_decrypted_gf = gf(round(Q_I_Mapped),4);
    %        % Q_I_decrypted_gf = gf(mod(round(Q_I_decrypted_encoded_corrected),15),4);
    %         Q_I_decrypted = gf2dec(rsdec(Q_I_decrypted_gf,31,3),5,37);
    Encoded_Q_I_RX= reshape(Q_I_decrypted_encoded_corrected,[ N,blocks]);
    Encoded_Q_I_gray_RX= reshape(Q_I_gray_decrypted_encoded_corrected,[ N,blocks]);
    for block = 1: blocks
          Q_I_decrypted(block,:) = rsDecoder(round(Encoded_Q_I_RX(:,block)));
          passwordSessionKey(block,:) = rsDecoder(round(Encoded_Q_I_gray_RX(:,block)));
    end
return