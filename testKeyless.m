msg = '123456789abcdef';
path = 'KeylessChip73.xlsx';
enroll = 0;
currentLevels = 

if enroll == 1
    PUFenrollment(path);
else
    load("enrolledPUF.mat");
    setGlobalServer(enrollment);
    setGlobalCurrent(currentLevels);
end
encodedmsg = KeylessEncrypt(msg);
disp('Password Encoded with Keyless Encryption is: ');
disp(encodedmsg);
