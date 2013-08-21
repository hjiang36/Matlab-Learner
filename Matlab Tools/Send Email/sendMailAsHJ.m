function status = sendMailAsHJ(recipient,subject,message,attach)
%% function sendMailAsHJ(recipient, subject, [message],[attach])
%   Send mail as HJ gmail account
%   This function should be lab use only and never be public, if by any 
%   chance you see the content of this script, please send a note to 
%   HJ (hjiang36@gmail.com) 
%  
%  Inputs:
%    recipient - string / cell array, containing recipients' email address
%    subject   - subject of the email
%    message   - email content
%    attach    - string / cell array of fullpath of attachments
%  
%  Outputs:
%    status    - bool, indicating success / failure
%
%  Example:
%    sendMailAsHJ('hjiang36@stanford.edu','Hello World');
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, error('Recipient address needed'); end
if nargin < 2, error('Subject of the email needed'); end
if nargin < 3, message = ''; end
if nargin < 4, attach  = []; end

% Check existance of attach
if iscell(attach)
    for i = 1 : length(attach)
        if ~exist(attach{i},'file')
            disp(['Cannot find attachment:' attach{i}]);
            status = false;
            return;
        end
    end
else
    if ~exist(attach,'file') && ~isempty(attach)
        disp('Cannot find attachment file')
        status = false;
        return;
    end
end

%% Init my account & send
status = true;
try
    myaddress = 'psychExpResult@gmail.com';
    mypassword = '';
    
    if isempty(mypassword)
        warning('Password not set');
        status = false;
        return;
    end
    
    setpref('Internet','E_mail',myaddress);
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username',myaddress);
    setpref('Internet','SMTP_Password',mypassword);
    
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', ...
        'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    
    sendmail(recipient, subject, message, attach);
catch e
    disp(e);
    status = false;
end

end

