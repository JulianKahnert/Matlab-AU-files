% Script to test the function [outParam]=TGM_auwrite(inParam).m 
% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 									 29-Apr-2015 JK

clear;
close all;
clc;


%% generate paths

szName_wav      = 'KriegDerWeltenShort.wav';
szPath          = fileparts(which(mfilename('fullpath')));
szPath_tmp      = fullfile(szPath,'temp');
if ~exist(szPath_tmp,'dir')
    mkdir(szPath_tmp);
end
cd(szPath)
szPath_wav      = fullfile(szPath,szName_wav);
szPath_au_ref   = fullfile(szPath_tmp,[szName_wav(1:end-4) '_ref.au']);
szPath_au_new   = fullfile(szPath_tmp,[szName_wav(1:end-4) '_TGM.au']);


%% generate reference-data

% Include usr/local binaries (necessary on OSX for brew versions)
PATH = getenv('PATH');
setenv('PATH', [PATH ':/usr/local/bin']);

szCmd = sprintf('"ffmpeg" -y -i "%s" "%s"',szPath_wav,szPath_au_ref);
[bError, msg] = system(szCmd);


%% generate testing-data

[vSig,fs] = audioread(szPath_wav);
TGM_auwrite(szPath_au_new,vSig,fs)


%% testing

[vSig_ref,fs_ref] = audioread(szPath_au_ref);
[vSig_new,fs_new] = audioread(szPath_au_new);

if any(vSig_ref ~= vSig_new)
    plot(vSig_ref - vSig_new)
    error('ATTENTION: Saved vectors are not identical!!')
else
    fprintf('Reference and new signal are identical!\n')
end


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