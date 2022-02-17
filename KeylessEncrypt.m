function EncryptedPasswordSessionKey = KeylessEncrypt(password)
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
Q_I = double(password);%Plain Text in blocks
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
for i = 1:blocks
    for j = 1:N
        if mod(j,3)==1
            errorBits_raw(i,j) = 1;
        end
    end
end
%%Uncomment for Burst Errors
% for i = 1:blocks
%     for j = 1:N
%         if ismember(j, [1,2])
%             errorBits_raw(i,j) = 1;
%         end
%     end
% end
errorBits = [1 reshape(errorBits_raw',1,N*blocks)];
for block= 1:blocks
    Q_I_encoded(block,:) = rsEncoder((Q_I(block,:))');
    Q_I_encoded_gray(block,:) = rsEncoder((Q_I_gray(block,:))');
end
Q_I_encoded_reshaped = reshape(Q_I_encoded',1,45);% Cascading different blocks serially to apply the keyless protocol
Q_I_encoded_gray_reshaped = reshape(Q_I_encoded_gray',1,45);
K = 0;
%7*address+7*order+3*currents
address = [];
current = [];
order = [];
for i = 0:1:length(Q_I_encoded_reshaped)
    address = [address bin2dec(num2str(LMD(7*i+1+K: 7*i+7+K)))];
    current = [current bin2dec(num2str(LMD(7*i+8+K: 7*i+10+K)))];
    order = [order bin2dec(num2str(LMD(7*i+11+K: 7*i+17+K)))];
    K = (i+1)*10;      
end
MRAMarray = readmatrix('1024.csv');
Resistance = [];
for i = 1: length(Q_I_encoded_reshaped)+1
    Resistance = [Resistance MRAMarray((address(i)*8)+current(i))];
end
Cipher_unordered = [Resistance(1)*(1+7.5*0.2)];
Cipher_unordered_gray  = [Resistance(1)*(1+7.5*0.2)];
for i =1:length(Q_I_encoded_reshaped)
    Cipher_unordered = [Cipher_unordered Resistance(i+1)*(1+0.2*Q_I_encoded_reshaped(i))];
    Cipher_unordered_gray = [Cipher_unordered_gray Resistance(i+1)*(1+0.2*Q_I_encoded_gray_reshaped(i))];
end

[order_sorted,sortIdx] = sort(order,'ascend');


%unsort your data:
 [~, idx_rev] = sort(sortIdx);


Cipher = Cipher_unordered(sortIdx);
EncryptedPasswordSessionKey = Cipher_unordered_gray(sortIdx);

return