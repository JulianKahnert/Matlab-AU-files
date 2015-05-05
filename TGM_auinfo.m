function [stInfo]=TGM_auinfo(szFilename)
% function to do something usefull (fill out)
% Usage [outParam]=TGM_auinfo(inParam)
%
% Parameters
% ----------
% inParam :  type
%	 explanation
%
% Returns
% -------
% outParam :  type
%	 explanation
%
%------------------------------------------------------------------------ 
% Example: Provide example here if applicable (one or two lines) 

% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF 
% Source: If the function is based on a scientific paper or a web site, 
%         provide the citation detail here (with equation no. if applicable)  
% Version History:
% Ver. 0.01 initial create (empty) 05-May-2015  Initials (eg. JB)

%------------Your function implementation here--------------------------- 

%% read data from file
[FID,msg]       = fopen(szFilename,'r');
szMagicNumber   = fread(FID,4,'*char',0,'b');
iDataOffset     = fread(FID,1,'uint32',0,'b');
iDataSize       = fread(FID,1,'uint32',0,'b');
iEncoding       = fread(FID,1,'uint32',0,'b');
iSampleRate     = fread(FID,1,'uint32',0,'b');
iChannels       = fread(FID,1,'uint32',0,'b');

stFile          = dir(which(szFilename));
iDataSize_new   = stFile.bytes - iDataOffset;

%% show warnings if the data is corrupt

if ~strcmp(szMagicNumber.','.snd')
    warning('The magic number at the beginning of your .au-file is corrupt!')
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
    'Filename',         which(szFilename),...
    'CompressionMethod',szCompression,...
    'NumChannels',      iChannels,...
    'SampleRate',       iSampleRate,...
    'TotalSamples',     iDataSize_new*8 / iBitsPerSample,...
    'Duration',         iDataSize_new*8 / iBitsPerSample / iSampleRate,...
    'Title',            [],...
    'Comment',          [],...
    'Artist',           [],...
    'BitsPerSample',    iBitsPerSample);

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