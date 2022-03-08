function singleBitDEC = gray2dec(input)
for dec = 1:length(input)
    binary = (int2bit(input(dec),4))';
    for i = 1: length(binary)
        if i == 1
            singleBit(i) = binary(i);
        else 
            singleBit(i) = xor(binary(i), binary(i-1));
        end
    end
    singleBitDEC(dec) = bit2int(singleBit', 4);
end
        
return
        