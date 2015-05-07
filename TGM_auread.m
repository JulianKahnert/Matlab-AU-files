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

FID = fopen(szFilename,'r');
if FID == -1
    error('Can not read file. Is the path correct?')
end
fseek(FID,4,'bof');                             % 0 magic number
iDataOffset_B   = fread(FID,1,'int32',0,'b');   % 1 data offset
fseek(FID,4,'cof');                             % 2 data size
iEncoding       = fread(FID,1,'int32',0,'b');   % 3 encoding
fs              = fread(FID,1,'int32',0,'b');   % 4 sample rate
iChannels       = fread(FID,1,'int32',0,'b');   % 5 channels

szPath          = fopen(FID);
stFile          = dir(szPath);
iDataSize_B     = stFile.bytes - iDataOffset_B;

if iEncoding == 3
    iBitsPerSample  = 16;
    szFormat        = 'int16';
else
	error('This encoding typ is currently not supported.')
end


%% read audio data

iTotal_smp = iDataSize_B*8/iBitsPerSample;
if nargin == 1
    vInterval_smp = [1 iTotal_smp];
elseif vInterval_smp(2) > iTotal_smp/iChannels && vInterval_smp(2) ~= Inf
    error('The choosen interval is out of range!')
elseif vInterval_smp(2) == Inf
    vInterval_smp(2) = iTotal_smp;
end

% define frist byte in the desired interval and jump to it
iOffset_B = iDataOffset_B + (vInterval_smp(1)-1)*iBitsPerSample/8*iChannels;
fseek(FID,iOffset_B,'bof');

% define length of the desired interval and read the samples
iNum_smp= ( vInterval_smp(2)-vInterval_smp(1)+1 ) *iChannels;
vSig    = fread(FID,iNum_smp,szFormat,0,'b');

% normalization
max_amp = 2^(iBitsPerSample-1);
vSig    = vSig/max_amp;
y       = reshape(vSig,iChannels,[]).';

fclose(FID);
