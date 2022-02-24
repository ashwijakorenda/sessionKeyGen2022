clear all
disp('Starting server protocol:  ')
T = randi([0 1],10,1);
PW = randi([0 1],10,1);
sizeOfKey = 256;
currentLevels = [93, 159,	225, 291, 357, 436,	503, 582, 661, 741,	846, 926, 1032,	1336, 1442,	2671];
shaInput = xor(T, PW);
A = Shake256(shaInput, 128);
A_bin = hexToBinaryVector(A,512);
pairs = Shake256(A, 2048);
alphaPosition = 35;
betaPosition = 45;
x_dimension = 64;
y_dimension = 64;
alpha = hex2dec(A(alphaPosition:alphaPosition+1 ));
beta = hex2dec(A(betaPosition:betaPosition+3));
k = 1 ;
for i = 1: 4: 2048
    X(k) = mod(hex2dec(pairs(i:i+1)), x_dimension);
    Y(k) = mod(hex2dec(pairs(i+2:i+3)),y_dimension);
    X_dash(k) = mod(alpha*X(k)*Y(k) + beta, x_dimension);
    Y_dash(k) = mod(alpha*Y(k) + beta*X(k),y_dimension); 
    k = k + 1;
end
currentPosition = 55;
current = currentLevels(mod(hex2dec(A(currentPosition)),16) + 1) ;
path = "D:\2022\KeylessChip73.xlsx";
serverResponse = readResponse(path);
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
modResistanceDifference = abs((PUF - PUFcompanion)/(current*10^(-9)));
[sortedResistance, index] = sort(modResistanceDifference,'descend');
ResistanceDifference = (PUF - PUFcompanion)/(current*10^(-9));
Mask = zeros(1,length(PUF));
Mask(index(1:sizeOfKey))= 1;
lenOfPUF = length(PUF);
rawPUFkey = zeros(1,lenOfPUF);
histogram(ResistanceDifference);
meanResistance = mean(ResistanceDifference);
xline(meanResistance);
for i = 1:1:lenOfPUF
    if ResistanceDifference(i) > meanResistance
        rawPUFkey(i) = 1;
    elseif ResistanceDifference(i) < meanResistance
        rawPUFkey(i) = 0;
    else 
        rawPUFkey(i) = 2;
    end
end
sum(Mask) % check to see if mak is same length as key.


ServerKey = rawPUFkey(Mask== 1);

disp('Server Key is :');
disp(ServerKey)
S = bitxor(Mask, A_bin);
TX = [T S PW];

RegeneratedKey = Client(TX);
HammingDist = pdist(ServerKey, RegeneratedKey,'hamming');


function PUF = readResponse(path)
  %Read Response from a file to derieve a fingerprint from the PUF
  PUF = readmatrix(path, "FileType","spreadsheet", "Range","C2:C4097");
end

function regeneratedKey = Client(TX)
    sizeOfKey = 64;
    regeneratedKey = zeros(1, sizeOfKey);
    T = TX(1:10);
    S_client = TX(11:523);
    PW = TX(524:end);
    shaInput = xor(T, PW);
    A = Shake256(shaInput, 128); 
    A_bin = hexToBinaryVector(A,512);
    Mask = xor(A_bin, S_client);
    alphaPosition = 35;
    betaPosition = 45;
    x_dimension = 64;
    y_dimension = 64;
    alpha = hex2dec(A(alphaPosition:alphaPosition+1 ));
    beta = hex2dec(A(betaPosition:betaPosition+3));
    j=1;
    for i = 1:1:length(X)
        if Mask(i) == 1
            k1 = x_dimension*X(i)+ Y(i)+1;
            k2 = x_dimension*X_dash(i)+ Y_dash(i)+1;%the +1 refers to addressing the 0th index in matlab
            if k <= 0
                print('Stop!!!')
            end
            PUF(j) = serverResponse(k1);
            PUFcompanion(j) = serverResponse(k2);
            j=j+1;
        end
    end
    ResistanceDifference = (PUF - PUFcompanion)/(current*10^(-9));
    j = 1;
    for i = 1:1:lenOfPUF
        if Mask(i) == 1
            if ResistanceDifference(i) > meanResistance
                regeneratedKey(j) = 1;
            else
                regeneratedKey(j) = 0;
            end
            j=j+1;
        end
        
       
    end
    
end
