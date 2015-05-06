% Script to test the function [outParam]=TGM_auinfo(inParam).m 
% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create                                   05-May-2015 JK

clear;
close all;
clc;

%------------Your script starts here-------- 

%Define your parameters and adjust your function call
inParam = 'temp/KriegDerWeltenShort_TGM.au';

stInfo      = TGM_auinfo(inParam);
stInfo_ref  = audioinfo(inParam);


%% check field: Filename

if ~strcmp(stInfo.Filename,stInfo_ref.Filename)
    error('Filename not consistent!')
end


%% check field: CompressionMethod

if ~strcmp(stInfo.CompressionMethod,stInfo_ref.CompressionMethod)
    error('CompressionMethod not consistent!')
end


%% check field: NumChannels

if stInfo.NumChannels ~= stInfo_ref.NumChannels
    error('NumChannels not consistent!')
end


%% check field: SampleRate

if stInfo.SampleRate ~= stInfo_ref.SampleRate
    error('SampleRate not consistent!')
end


%% check field: TotalSamples

if stInfo.TotalSamples ~= stInfo_ref.TotalSamples
    error('TotalSamples not consistent!')
end


%% check field: Duration

if stInfo.Duration ~= stInfo_ref.Duration
    error('Duration not consistent!')
end


%% check field: BitsPerSample

if stInfo.BitsPerSample ~= stInfo_ref.BitsPerSample
    error('NumChannels not consistent!')
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