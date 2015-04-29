% Script to test the function [outParam]=TGM_auwrite(inParam).m 
% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create (empty) 29-Apr-2015 			 Initials (eg. JB)

clear;
close all;
clc;
fclose('all');

%------------Your script starts here-------- 

szPath      = fileparts(which(mfilename('fullpath')));
cd(szPath)
szPath_au   = fullfile(szPath,'KriegDerWeltenShort.au');

% if ~exist(szPath_au,'file')
% szPath_wav  = fullfile(szPath,'KriegDerWeltenShort.wav');
% [vSig,fs]   = audioread(szPath_wav);
% 
%     auwrite(vSig,fs,16,'linear',szPath_au);
% end



%% generate data

wdata   = [-.5:0.1:.5].';
fs      = 44100;
auwrite(wdata,fs,16,'linear',szPath_au);



szPath_au2  = [szPath_au(1:end-3) '2.au'];

TGM_auwrite(wdata,fs,szPath_au2)



%% testing

[vSig_ref,fs_ref] = auread(szPath_au);

[vSig_new,fs_new] = auread(szPath_au2);


size(vSig_ref)
size(vSig_new)
% 
% disp([vSig_ref vSig_new])





if any(vSig_ref ~= vSig_new)
    error('ATTENTION: Saved vectors are not identical!!')
end







% inParam = 
% [outParam]=TGM_auwrite(inParam);


%--------------------Licence ---------------------------------------------
% Copyright (c) <2015> Julian Kahnert
% Jade University of Applied Sciences 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files 
% (the "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject
% to the following conditions:
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.