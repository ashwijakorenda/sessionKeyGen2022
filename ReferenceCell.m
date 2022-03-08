
password = KeylessEncyrpt();
randomNumber = randi(10000000);
hashInput = xor(password,randomNumber);
Opt.Method = 'SHA-512';
Opt.Format ='hex';
xorValue = bitxor(randomNumber, password);
hashDigest_1 = (DataHash(xorValue, Opt));
HashOutput= hashDigest_1;
for i= 1:7
    hashDigest_2 = (DataHash(circshift(hashDigest_1,i),Opt));
    HashOutput = [HashOutput, hashDigest_2];
    
end
Address = HashOutput(1:1000); % Used for X and Y axis 
% in the array. Using each hex char we can address a 16x16 array.
 
load('ReRAM_50.mat')
ReferenceMedian = median(reramData(2,:));
disp('The reference median is ');
disp(ReferenceMedian);
ResistanceArray = [];
for i = 1:2:1000
    position = 16*hex2dec(Address(i))+hex2dec(Address(i+1));
    resistanceValue = reramData(2,position+1);
    ResistanceArray = [ResistanceArray, resistanceValue];
end

%Finding stable 0's: 128 stable bits
[AscendSort,minPos]= sort(DistanceMatrix, 'ascend');
%Finding stable 1's: 128 stable bits
[DescendSort,maxPos]= sort(DistanceMatrix, 'descend'); 
stablePositions = [minPos(1:128), maxPos(1:128)];
Step 6: Once we have stable positions, we assign zero for -ve values and 1 for +ve values if there in stable positions otherwise an X is assignned .
ternaryPUF = zeros(1,length(ResistanceArray))
for i = 1:length(ResistanceArray)
    if DistanceMatrix(i) < 0 && ismember(i,stablePositions)
    ternaryPUF(i) =  0;
    elseif DistanceMatrix(i) > 0 && ismember(i,stablePositions)
        ternaryPUF(i) =  1;
    else
        ternaryPUF(i) = 2;
    end        
end
binaryKey = ternaryPUF;
binaryKey(binaryKey==2)=[];
Step 7: Mask Generation: Mask is as long as the hash output. The first 500 characters of the mask come from the state of ternary PUF. If the bit of ternary PUF is o/1 it is a 0. If a bit is an X or 2 it is a 1. The last 24 characters of the mask refer to the address of the reference cell. Here, as we take the median of cells to be the  reference. We find the cell closest to the median value as the reference cell address. 
mask = zeros(1,4000);
for i = 1: length(ternaryPUF)
    if ternaryPUF(i) == 2
        mask(i) = 1;
    else 
        mask(i) = 0;
    end
end
[val,AddressReference]=min(abs(ReferenceMedian-reramData(1,:))); % Extract same output

mask_binString = strcat(join((dec2bin(mask))'),dec2bin(AddressReference,96));
mask_hexString = bin2hex(mask_binString);

S_vector = bitxor(hex2bin(HashOutput), hex2bin(mask_hexString));
 

Regenerated_mask = bitxor(hex2bin(HashOutput), S_vector);
sum(Regenerated_mask ~= hex2bin(mask_hexString)) %Check mask value
RegeneratedStablePositionsMask = Regenerated_mask(1:length(ternaryPUF));
RegeneratedReference_Address = bin2dec(join((dec2bin(Regenerated_mask(end-95: end)))'));
if AddressReference ~= RegeneratedReference_Address
    disp('Reference Address not same')
end
ReferenceResistance = reramData(5, RegeneratedReference_Address); % using a different PUF reading at the same current

k=0;
l=1;
RegeneratedStablePositions=[];
for i = 1:2:2*length(ResistanceArray)
   if RegeneratedStablePositionsMask(l) == 0
        positionRegenerated = 16*hex2dec(Address(i))+hex2dec(Address(i+1));
        RegeneratedStablePositions = [RegeneratedStablePositions positionRegenerated];
        resistanceValue = reramData(2,positionRegenerated+1);
        k=k+1;
        if ReferenceMedian - resistanceValue < 0 
            RegeneratedPUF(k) =  0;
        else
            RegeneratedPUF(k) =  1;
        end
      
   end
   l = l+1;
end
if sum(binaryKey~=RegeneratedPUF) == 0
    disp('PUF was generated correctly  on client end')
else
    disp('PUF was not generated correctly')
end


