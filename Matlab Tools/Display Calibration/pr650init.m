function port = pr650init(id)
%% function pr650init(id)
%  Creates a serial port object and sets default parameters for the PR650
%  
%  Usage:
%    port = pr650init(id)
%
%  (HJ) Oct, 2013

%% Check inputs
if nargin<1, id = 1; end

%% Check OS
if isunix()
    % For mac simple driver only - need to be changed to auto detection
    comstr = '/dev/tty.PL2303-00001014';
elseif ispc % Use COM port for Windows
    comstr  = ['COM' num2str(id)];
end

port = serial(comstr);

%% Open and initialize the serial port.
if (strcmpi(port.Status,'closed') == 1)
   fopen(port);
end

%% Set communication parameters
set(port,'BaudRate',9600);
set(port,'DataBits',8);
set(port,'Parity','none');
set(port,'StopBits',1);
set(port,'Timeout',2);
set(port,'Terminator','CR/LF');
set(port,'FlowControl','none');
set(port,'RequestToSend','on');
pause(0.5);

set(port,'RequestToSend','off');
pause(0.5);
set(port,'RequestToSend','on');
pause(0.5);

%% Send a quick command to keep it in command mode.
fprintf(port,'S,,,,,0,1,0\n');


end