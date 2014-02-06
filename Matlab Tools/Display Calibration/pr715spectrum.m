function [data, wavelengths, peak] = pr715spectrum(port)

%% PR715 reads data in (380,1068) at every 4 nm for a total of 173 samples

% Dump RS232 buffer
bytes = port.BytesAvailable;
while (bytes ~= 0)
   flushinput(port);
   pause(0.1);
   bytes = get(port,'BytesAvailable');
end

%timeout = get(port,'Timeout');
set(port,'Timeout',60);
% 
% Send the measure command to the device.
fprintf(port,'PR715 \n'); % Seems to need this before each command 
fprintf(port,'M5 \n');    % M5 measures spectral data 
  
% Retrieve the response.
% Method is slower than PR650_Data.
   
Nsamples = 173;
stepSize = 4; % nm
%first_last   = ['0380,';'1068,'];

startWave = 380;
stopWave  = 1068;
%startSample=' 380';
%stopSample='1068';
   
wavelengths   = zeros(Nsamples,1);
data=  zeros(Nsamples,1);
sampleIndex = 1;
start  = 0;

while true
   %bytes = get(port,'BytesAvailable');
   %if bytes > 0
   portOut= fgetl(port);
   %disp(portOut);
   %else
   %    warning('no bytes available');
   %    pause(0.5);
   %    continue;
   %end
   if ( start == 0 && ~isempty(strfind(portOut,'0000')) )
        delim=strfind(portOut,',');
        if length(delim) < 3
            continue;
        end
        peak = str2double(portOut(delim(2)+1:delim(3)-1));
   end
   if start == 0
       portStr = strsplit(portOut, ',');
       if str2double(portStr{1}) == startWave
           start = 1;
       end
   end
   if start == 1
        portStr=strsplit(portOut, ',');
        wavelengths(sampleIndex) = str2double(portStr{1});
        if wavelengths(sampleIndex) ~= startWave+stepSize*(sampleIndex -1)
            start = 0;
            sampleIndex = 1;
            continue;
        end
        data(sampleIndex) = str2double(portStr{end});
        if wavelengths(sampleIndex) == stopWave
            return;
        end
        if isnan(data(sampleIndex))
            start = 0;
            sampleIndex = 0;
        end
        assert(sampleIndex < Nsamples);
        sampleIndex = sampleIndex + 1;
        pause(0.01);
   end
end