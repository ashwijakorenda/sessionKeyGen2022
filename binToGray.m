function singleBit = binToGray(input)
    binary = de2bi(input, 4,  'left-msb');
    for i = 1: length(binary)
        if i == 1
            singlBit(i) = binary(i);
        else 
            singlBit(i) = xor(binary(i), binary(i-1));
        end
    end
    singleBit = bi2de(singlBit, 'left-msb');
        
return
        
  