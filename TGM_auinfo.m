function [stInfo] = TGM_auinfo(szFilename)
% TGM_auinfo Return metadata of an au-file.
%
%--------------------------------------------------------------------------
%
% [stInfo] = TGM_auinfo(szFilename)
%
%
% szFilename:   String which contains the name of the au-file. If a path is
%               specified, it can be absolute, relative, or partial.
%
% stInfo:       Struct which contains the relevant information about the
%               au-file.
%
%--------------------------------------------------------------------------
%
% Example:      stInfo = TGM_auinfo('temp/TomShort.au')
%
%--------------------------------------------------------------------------
% This projected is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% See also: TGM_auread, TGM_auwrite.

% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create                                   05-May-2015 JK
% Ver. 0.02 help update                                      06-May-2015 JK

%--------------------------------------------------------------------------


%% read header from file

FID             = fopen(szFilename,'r');
if FID == -1
    error('Can not read file. Is the path correct?')
end
szMagicNumber   = fread(FID,4,'*char',0,'b');   % 0 magic number
iDataOffset     = fread(FID,1,'int32',0,'b');  % 1 data offset
iDataSize       = fread(FID,1,'int32',0,'b');  % 2 data size
iEncoding       = fread(FID,1,'int32',0,'b');  % 3 encoding
iSampleRate     = fread(FID,1,'int32',0,'b');  % 4 sample rate
iChannels       = fread(FID,1,'int32',0,'b');  % 5 channels

szPath          = fopen(FID);
stFile          = dir(szPath);
iDataSize_new   = stFile.bytes - iDataOffset;
fclose(FID);


%% show warnings if the data is corrupt

if ~strcmp(szMagicNumber.','.snd')
    warning('The magic number in your .au-file is corrupt!')
end

if iDataSize ~= iDataSize_new
    warning('DataSize in header is not correct!')
end


%% write info struct

if iEncoding == 3
    szCompression   = 'Uncompressed';
    iBitsPerSample  = 16;
end

stInfo = struct(...
    'Filename',         szPath,...
    'CompressionMethod',szCompression,...
    'NumChannels',      iChannels,...
    'SampleRate',       iSampleRate,...
    'TotalSamples',     iDataSize_new*8 / iBitsPerSample / iChannels,...
    'Duration',         iDataSize_new*8 / iBitsPerSample / iSampleRate / iChannels,...
    'Title',            [],...
    'Comment',          [],...
    'Artist',           [],...
    'BitsPerSample',    iBitsPerSample);


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