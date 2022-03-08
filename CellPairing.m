clear all
T = randi([0 1],10,1);
PW = randi([0 1],10,1);
sizeOfkey = 256;
currentLevels = [93, 159,	225, 291, 357, 436,	503, 582, 661, 741,	846, 926, 1032,	1336, 1442,	2671];
shaInput = xor(T, PW);
A = Shake256(shaInput, 256);
pairs = Shake256(A, 2048);
alphaPosition = 35;
betaPosition = 45;
x_dimension = 64;
y_dimension = 64;
alpha = hex2dec(A(alphaPosition));
beta = hex2dec(A(betaPosition:betaPosition+1));
k = 1 ;
for i = 1: 4: 2048
    X(k) = mod(hex2dec(pairs(i:i+1)), x_dimension);
    Y(k) = mod(hex2dec(pairs(i+2:i+3)),y_dimension);
    X_dash(k) = mod(alpha*X(k)*Y(k) + beta, x_dimension);
    Y_dash(k) = mod(alpha*X(k) + beta*Y(k),y_dimension); 
    k = k + 1;
end
currentPosition = 55;
current = currentLevels(mod(hex2dec(A(currentPosition)),16) + 1) ;
path = "C:\Users\ak848\Google Drive\2022\Spring2022\KeylessShield\KeylessChip73.xlsx";
serverResponse = readResponse(path);
enrollmentMatrix = PUFenrollment(serverResponse);
ResistanceDifference = [];
for i = 1:1:length(X)
    k1 = x_dimension*X(i)+ Y(i)+1;
    k2 = x_dimension*X_dash(i)+ Y_dash(i)+1;%the +1 refers to addressing the 0th index in matlab
    if k <= 0
        print('Stop!!!')
    end
    PUF(i) = serverResponse(k1);
    PUFcompanion(i) = serverResponse(k2);
end
ResistanceDifference = (PUF - PUFcompanion)/(current*10^(-9));
[sortedResistance, index] = sort(ResistanceDifference,'descend');
Mask = zeros(1,length(PUF));
Mask(index(1:sizeOfkey))= 1;


sum(Mask)








