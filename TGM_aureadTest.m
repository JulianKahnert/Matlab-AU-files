% Script to test the function [outParam]=TGM_auread(inParam).m 
% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create (empty) 05-May-2015 			 Initials (eg. JB)

clear;
close all;
clc;

%------------Your script starts here-------- 
% szFilename = 'temp/KriegDerWeltenShort_ref.au';
szFilename = 'temp/KriegDerWeltenShort_TGM.au';

% szFilename = 'temp/test.au';
% auwrite(rand(10,2)-0.5,44100,16,'linear',szFilename)


vSamples = [130 500];

[y,fs]=TGM_auread(szFilename,vSamples);


[y_ref,fs_ref] = audioread(szFilename,vSamples);

if fs ~= fs_ref
    warning('Samplerate not correct!')
end

if max(abs(y_ref-y)) ~= 0
    warning('Data corrupt!')
end

size(y_ref)
size(y)


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