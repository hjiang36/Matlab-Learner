%% function port = spectrometerInit(portName, varargin)
%    Creates a serial port object and sets default parameters for
%  spectrometers. Currently, this script has only be tested with PR650 and
%  PR715.
%  
%  Inputs:
%    portName  - serial port name, e.g. 'COM1' for windows and 
%                '/dev/tty.PL2303-00001014' for unix / mac
%    varargin  - parameter pairs, can be used to overwrite default serial
%                port settings
%
%  Output:
%    port      - serial port object
%
%  (HJ) Feb, 2014

function port = spectrometerInit(portName, varargin)
%% Check input
if isempty('portName'), error('Connection Port Name Required'); end
if mod(length(varargin),2)~=0, error('Parameter should be in pairs'); end

%% Connect and Init
port = serial(portName);

% Open the serial port.
if (strcmpi(port.Status,'closed') == 1)
   fopen( port );
end

%% Set port parameters
set(port,'BaudRate',9600);
set(port,'DataBits',8);
set(port,'Parity','none');
set(port,'StopBits',1);
set(port,'Timeout', 60);
set(port,'Terminator','LF');    % Changed from CR/LF 
set(port,'FlowControl','none'); % Manual wants this set to HARDWARE
set(port,'RequestToSend','on');  pause(0.5);
set(port,'RequestToSend','off'); pause(0.5);
set(port,'RequestToSend','on');  pause(0.5);

%% Parse varargin parameters
for ii = 1 : 2 : length(varargin)
    set(port, varargin{ii}, varargin{ii+1});
end

fprintf(port,'S,,,,,0,1,0\n');
