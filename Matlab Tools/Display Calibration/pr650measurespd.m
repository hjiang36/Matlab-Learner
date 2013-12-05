%cd ~/Matlab-Learner/Matlab' Tools'/Display' Calibration'/
%port = pr650init();

bytes = port.BytesAvailable;
while bytes > 0
    flushinput(port);
    bytes = port.BytesAvailable;
end

fprintf(port,'M5 \n');
WaitSecs(0.5);

wave = 380:4:780;
spd  = zeros(length(wave),1);

bytes = port.BytesAvailable;
while bytes == 0
    WaitSecs(0.2);
    bytes = port.BytesAvailable;
end

fgetl(port); % Ignore the first line 00,0
fgetl(port); 
for i = 1:length(wave)
    str = fgetl(port);
    tmp = strsplit(str,',');
    if length(tmp) < 2
        continue;
    end
    spd(i) = str2double(tmp{2});
end