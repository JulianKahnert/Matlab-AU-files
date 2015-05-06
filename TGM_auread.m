function [y, fs] = TGM_auread(szFilename,vSamples)
% TGM_auread Read the audio data of an au-file.
%
%--------------------------------------------------------------------------
%
% stInfo = TGM_auwrite(szFilename,y,fs)
%
%
% szFilename:   String which contains the name of the au-file, that should
%               be read. If a path is specified, it can be absolute,
%               relative, or partial.
%
% vSamples:     Two element vector [start end] which specifies the reading
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
% Example:      [y,fs] = TGM_auwrite('test.au',rand(44100*3,1)-0.5,44100)
%
%--------------------------------------------------------------------------
% See also: TGM_auinfo, TGM_auread.

% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create                                   05-May-2015 JK
% Ver. 0.02 help update                                      06-May-2015 JK

% To-Do:
%   *

%--------------------------------------------------------------------------


%% check input

if nargin == 1
    vSamples = [1 Inf];
end


%% read header from file

FID = fopen(szFilename,'r');
if FID == -1
    error('Can not read file. Is the path correct?')
end
fseek(FID,4,'bof');                         % 0 magic number
iDataOffset = fread(FID,1,'int32',0,'b');   % 1 data offset
fseek(FID,4,'cof');                         % 2 data size
iEncoding   = fread(FID,1,'int32',0,'b');   % 3 encoding
fs          = fread(FID,1,'int32',0,'b');   % 4 sample rate
iChannels   = fread(FID,1,'int32',0,'b');   % 5 channels

szPath      = fopen(FID);
stFile      = dir(szPath);
iDataSize   = stFile.bytes - iDataOffset;

if iEncoding == 3
    szCompression   = 'Uncompressed';
    iBitsPerSample  = 16;
end


%% read audio data

fseek(FID, iDataOffset, 'bof');     % jump to begin of data block

nSamples = iDataSize*8/iBitsPerSample;

vSig = zeros(nSamples,1);

k = 1;
while ~feof(FID)
    iCurr = fread(FID,1,'int16',0,'b');
    if isempty(iCurr)
        disp(k)
    else
        vSig(k) = iCurr;
    end
    k = k+1;
end

% normalization
max_amp = 2^(iBitsPerSample-1);
y       = vSig/max_amp;
y       = reshape(y,iChannels,[]).';

fclose(FID);

%--------------------------------------------------------------------------
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