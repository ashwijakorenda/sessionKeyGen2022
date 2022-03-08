function enrollment = PUFenrollment(path)
enrollment = zeros(4096,16); %Mark ternary states as 1 

PUF = readmatrix(path, "FileType","spreadsheet", "Range", "D2:S4097", "Sheet", "STD");
for i = 1:1:4096
    for j = 1:1:16
        if PUF(i,j)>20
            enrollment(i,j) = 1;
        end
    end
end
save('enrolledPUF.mat', "enrollment");
end