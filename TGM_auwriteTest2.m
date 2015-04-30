% Script to test the function [outParam]=TGM_auwrite(inParam).m 
% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create (empty) 29-Apr-2015 			 Initials (eg. JB)

clear;
close all;
clc;
fclose('all');

%------------Your script starts here-------- 

%% generate test signal
fs      = 44100;
f0      = 1/5;
dur_sec = 5;

vTime   = linspace(0,dur_sec,dur_sec*fs);
vSig    = 0.9*sin(2*pi*f0*vTime);
vSig    = vSig(:);
% plot(vTime,vSig)
szPath_tmp = fullfile(fileparts(which(mfilename('fullpath'))),'temp');
if ~exist(szPath_tmp,'dir')
    mkdir(szPath_tmp);
end


%% standard writing test

nChans  = 1;
szPath_1= fullfile(szPath_tmp,'test_01.au');
TGM_auwrite(szPath_1,repmat(vSig,1,nChans),fs)
stInfo = audioinfo(szPath_1);


%% standard writing test - two channels

nChans  = 2;
szPath_2= fullfile(szPath_tmp,'test_02.au');
TGM_auwrite(szPath_2,repmat(vSig,1,nChans),fs)
stInfo2 = audioinfo(szPath_2);

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