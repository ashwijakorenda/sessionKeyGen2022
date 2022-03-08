function Resistance_Cipher = KeylessEncrypt(plainText)
password = 124321;
randomNumber = 8989;
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
    LMD =strcat(LMD,hashedRotatedMD)  ;  
end

%%Divide LMD into blocks: address 7 bits, order 7 bits, current 3bits
for i = 1:1: length(plainText)
    Q_I(i) = hex2dec(plainText(i));%Plain Text in blocks
end
%Q_I = [4 8; 6 4; 8 5];
Q_I_current = gray2dec(Q_I);

%greyCurrent = decToGray(Q_I);
currentLevels = setGlobalCurrent();
%currentLevels = getGlobalCurrent();
serverResponse = getGlobalServer();
Resistance_Cipher = [];
x_dimension = 64;
y_dimension = 64;
k=1;
for i = 1: length(Q_I)
    X = mod(hex2dec(LMD(k:k+1)), x_dimension);
    Y = mod(hex2dec(LMD(k+2:k+3)),y_dimension);
    address = X*x_dimension+Y+1;
    Resistance_Cipher = [Resistance_Cipher serverResponse(address, currentLevels(Q_I_current(i)))];
    k = k+4;
end



return