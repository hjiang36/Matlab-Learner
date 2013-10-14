%% testCluster
%  This is a simple test program to be runned on a cluster
%
%  We will test the following items with this program
%     - Matrix initialization and arithmetic computation
%     - Screen outputs, disp and printf
%     - Saveas function
%     - background plotting
%     - Parpool initialization
%     - basic parellel computing


%% Matrix initialization and computation
n  = 10;
mA = eye(n); mB = randn(n);

mC = mB \ mA' * mB;

%% Screen outputs
fprintf('Matrix computation testing results:\n');
disp(mC);

%% Save as function
save deleteMe.mat

%% Background plotting
hf = figure('visible', 'off');
plot(1:n, 1:n);
saveas(hf, 'deleteMe.fig');
close(hf);

%% Test parpool
%  Matlab pool doesn't work well on proclus and maybe most of not special
%  defined clusters. For proclus, we might need to re-construct things to
%  use sgerun or something to complete all the computation

matlabpool open 12

parfor i = 1:10e6
    simResult(i) = rand;
end

matlabpool close

save deleteMe.mat
