function enrollment = PUFenrollment(path)
enrollment = zeros(1,4096);

for i=1:20
    PUF(:,:, i) = readmatrix(path, "FileType","spreadsheet", "Range", "C2:R4097", "Sheet", i);
end



end