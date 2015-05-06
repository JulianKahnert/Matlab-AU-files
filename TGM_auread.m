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

%% read data from file

FID             = fopen(szFilename,'r');
if FID == -1
    error('Can not read file. Is the path correct?')
end
szMagicNumber   = fread(FID,4,'*char',0,'b');
iDataOffset     = fread(FID,1,'uint32',0,'b');
iDataSize       = fread(FID,1,'uint32',0,'b');
iEncoding       = fread(FID,1,'uint32',0,'b');
iSampleRate     = fread(FID,1,'uint32',0,'b');
iChannels       = fread(FID,1,'uint32',0,'b');

szPath          = fopen(FID);
stFile          = dir(szPath);
iDataSize_new   = stFile.bytes - iDataOffset;


%% show warnings if the data is corrupt

if ~strcmp(szMagicNumber.','.snd')
    warning('The magic number in your .au-file is corrupt!')
end

if iDataSize ~= iDataSize_new
    warning('DataSize in header is not correct!')
end



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