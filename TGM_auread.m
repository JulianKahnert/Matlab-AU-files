function [y, fs] = TGM_auread(szFilename,vInterval_smp)
% TGM_auread Read the audio data of an au-file.
%
%--------------------------------------------------------------------------
%
% [y, fs] = TGM_auwrite(szFilename,vInterval_smp)
%
%
% szFilename:   String which contains the name of the au-file, that should
%               be read. If a path is specified, it can be absolute,
%               relative, or partial.
%
% vInterval_smp:Two element vector [start end] which specifies the reading
%               interval. Start represents the first and end the last
%               sample in this interval.
%
% y:            Vector or matrix which contains the audio data, specified
%               as an m-by-n matrix, where m is the number of audio samples
%               and n is the number of audio channels.
%
% fs:           Samplerate of you audio data.
%
%--------------------------------------------------------------------------
%
% Example:      [y,fs] = TGM_auwrite('test.au');
%               [y,fs] = TGM_auwrite('test.au',[20 100]);
%               [y,fs] = TGM_auwrite('test.au',[20 Inf]);
%
%--------------------------------------------------------------------------
% This projected is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% See also: TGM_auinfo, TGM_auwrite.

% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create                                   05-May-2015 JK
% Ver. 0.02 help update                                      06-May-2015 JK

% To-Do:
%   *

%--------------------------------------------------------------------------
% Definition of the variables (class)(Name)_(Unit):
%   * smp   = samples
%   * B     = bytes
%   * b     = bits
% For example: iDataSize_B  => (i)(DataSize)_(B)



%% read header from file

stInfo  = TGM_auinfo(szFilename);
fs      = stInfo.SampleRate;
FID     = fopen(szFilename,'r');
if FID == -1
    error('Can not read file. Is the path correct?')
end

szPath          = fopen(FID);
stFile          = dir(szPath);
iDataSize_B     = stFile.bytes - stInfo.DataOffset;

if stInfo.Encoding == 3
    iBitsPerSample  = 16;
    szFormat        = 'int16';
else
	error('This encoding typ is currently not supported.')
end


%% read audio data

iTotal_smp = iDataSize_B*8/iBitsPerSample;
if nargin == 1
    vInterval_smp = [1 iTotal_smp];
elseif vInterval_smp(2) > iTotal_smp/stInfo.NumChannels && vInterval_smp(2) ~= Inf
    error('The choosen interval is out of range!')
elseif vInterval_smp(2) == Inf
    vInterval_smp(2) = iTotal_smp;
end

% define frist byte in the desired interval and jump to it
iOffset_B = stInfo.DataOffset + (vInterval_smp(1)-1)*iBitsPerSample/8*stInfo.NumChannels;
fseek(FID,iOffset_B,'bof');

% define length of the desired interval and read the samples
iNum_smp= ( vInterval_smp(2)-vInterval_smp(1)+1 ) *stInfo.NumChannels;
vSig    = fread(FID,iNum_smp,szFormat,0,'b');

% normalization
max_amp = 2^(iBitsPerSample-1);
vSig    = vSig/max_amp;
y       = reshape(vSig,stInfo.NumChannels,[]).';

fclose(FID);
