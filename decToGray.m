function [GrayOutput] = decToGray(Q_I)
GrayOutput = zeros(size(Q_I))
[row,col] = size(Q_I)
  for j  = 1: row
      for k = 1:col
        GrayOutput(j,k) = binToGray(Q_I(j,k));
      end   
  end
return