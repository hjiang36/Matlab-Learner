function spd = pr650spectrum(port)
% Dump RS232 buffer
bytes = port.BytesAvailable;
while (bytes ~= 0)
   flushinput(port);
   %pause(0.1);
   bytes = get(port,'BytesAvailable');
end
%timeout = get(port,'Timeout');
set(port,'Timeout',60);
fprintf(port,'PR650\n');
fprintf(port,'M5 \n');
WaitSecs(1);

wave = 380:4:780;
spd  = zeros(length(wave),1);

bytes = port.BytesAvailable;
while bytes == 0
    WaitSecs(0.2);
    bytes = port.BytesAvailable;
end

tmp = fgetl(port); % Ignore the first line 00,0
tmp = fgetl(port); 
for i = 1:length(wave)
    str = fgetl(port);
    tmp = strsplit(str,',');
    if length(tmp) < 2
        continue;
    end
    spd(i) = str2double(tmp{2});
end

% Get out all remained data
% Dump RS232 buffer
bytes = port.BytesAvailable;
while (bytes ~= 0)
   flushinput(port);
   pause(0.1);
   bytes = get(port,'BytesAvailable');
end