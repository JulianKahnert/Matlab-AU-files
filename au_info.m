function [stInfo] = au_info(szFilename)
%AU_INFO Returns metadata of an au-file.
%
%   stInfo = AU_INFO(szFilename)
%
%   szFilename:
%       String which contains the name of the au-file. If a path is
%       specified, it can be absolute, relative, or partial.
%
%   stInfo:
%       Struct which contains the relevant information about the au-file.
%
%   See also: au_read, au_write.

%--------------------------------------------------------------------------
% This projected is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
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
szMagicNumber   = fread(FID,4,'*char',0,'b');
iDataOffset     = fread(FID,1,'uint32',0,'b');
fseek(FID,4,'cof');                             % 2 data size
iEncoding       = fread(FID,1,'uint32',0,'b');
iSampleRate     = fread(FID,1,'uint32',0,'b');
iChannels       = fread(FID,1,'uint32',0,'b');

szPath          = fopen(FID);
stFile          = dir(szPath);
iDataSize       = stFile.bytes - iDataOffset;
fclose(FID);


%% show warnings if the data is corrupt

if ~strcmp(szMagicNumber.','.snd')
    error('Header of the file corrupt. Is it a au-file?')
end


%% write info struct

% {iEncoding, szEncoding, iBitsPerSample, fwritePrecission, szCompression, bSupported, szDescription}
caEncoding = [];
load(fullfile(which(fileparts(mfilename('fullpath'))),'encoding.mat'))

iRowEncoding    = find([caEncoding{:,1}]==iEncoding);
iBitsPerSample  = caEncoding{iRowEncoding,3};
stInfo          = struct(...
    'Filename',             szPath,...
    'CompressionMethod',    caEncoding{iRowEncoding,4},...
    'NumChannels',          iChannels,...
    'SampleRate',           iSampleRate,...
    'TotalSamples',         iDataSize*8 / iBitsPerSample / iChannels,...
    'Duration',             iDataSize*8 / iBitsPerSample / iSampleRate / iChannels,...
    'Title',                [],...
    'Comment',              [],...
    'Artist',               [],...
    'BitsPerSample',        iBitsPerSample,...
    'DataOffset',           iDataOffset,...
    'Encoding',             iEncoding,...
    'EncodingDescription',  caEncoding{iRowEncoding,end});

