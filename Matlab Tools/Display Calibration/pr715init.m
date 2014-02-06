% Creates a serial port object and sets default parameters for the PR715
%
% --Usage-- 
%
% port = pr715init(id)
%
% ---------
%
% If initialization is succesful, this function will set the following 
% PR715 parameters:
% 
% Primary lens      - MS55 (standard objective lens)
% Add on 1          - no change; used for optical accesories
% Add on 2          - no change; ditto
% Aperture          - no change; for multiple aperture systems only
% Photometric units - metric [0 - metric, 1 - english]
% Detector Exposure - adaptive [0 - adaptive, 
% time                         integer values in (25,60000) secs.]
% Capture mode      - single [0 - single, 1 - continuous]
% # meas. average   - 3 [integer in (1,99)]
% Power/energy      - power (divided by exposure time) [0 - pwr, 1 - enrgy]
% Trigger mode      - internal (wait for valid M command)[0 - int, 1 - ext]
% View Shutter      - closed [0 - open, 1 - closed]
% CIE observer      - 2 deg [0 - CIE 1931 2 deg, 1 - CIE 1931 10 deg]

% See pr715set for setting pr715 parameters. 

function port = pr715init(portName)

% Check input
if notDefined('portName'), error('Connection Port Name Required'); end

% Connect
port = serial(portName);

% Open and initialize the serial port.
if (strcmpi(port.Status,'closed') == 1)
   fopen( port );
end

% Set port parameters
set(port,'BaudRate',9600);
set(port,'DataBits',8);
set(port,'Parity','none');
set(port,'StopBits',1);
set(port,'Timeout', 2);
set(port,'Terminator','LF'); %% Changed from CR/LF 
set(port,'FlowControl','none'); %Manual wants this set to HARDWARE. We'll see
set(port,'RequestToSend','on');
pause(0.5);
set(port,'RequestToSend','off');
pause(0.5);
set(port,'RequestToSend','on');
pause(0.5);

% Send a quick command to keep it in command mode.
% fprintf(port,'S,,,,,0,1,0\n');

