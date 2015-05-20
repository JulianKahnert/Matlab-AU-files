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
% This project is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule
% Version History:
% Ver. 0.1.0 initial create                                  05-May-2015 JK
% Ver. 0.2.0 help update                                     06-May-2015 JK
% Ver. 0.3.0 first mayor release                             19-May-2015 JK
%--------------------------------------------------------------------------


%% read header from file

fid = fopen(szFilename,'r');
if fid == -1
    error('Can not read file. Is the path correct?')
end
magicnumber = fread(fid,4,'uint8',0,'b');
if ~all(magicnumber' == uint8('.snd'))
    fclose(fid);
    error('Header of the file corrupt. Is it a au-file?')
end
iDataOffset     = fread(fid,1,'uint32',0,'b');
iDataSize       = fread(fid,1,'uint32',0,'b');  % ignored
iEncoding       = fread(fid,1,'uint32',0,'b');
iSampleRate     = fread(fid,1,'uint32',0,'b');
iChannels       = fread(fid,1,'uint32',0,'b');

% get absolute file path
szAbsPath = fopen(fid);
fclose(fid);
% get file size
stFile = dir(szAbsPath);
iDataSize = stFile.bytes - iDataOffset;


%% write info struct

% {iEncoding, szEncoding, iBitsPerSample, fwritePrecission, szCompression, bSupported, szDescription}
caEncoding = [];
load(fullfile(which(fileparts(mfilename('fullpath'))),'encoding.mat'))

iRowEncoding    = find([caEncoding{:,1}]==iEncoding);
iBitsPerSample  = caEncoding{iRowEncoding,3};
stInfo          = struct(...
    'Filename',             szAbsPath, ...
    'CompressionMethod',    caEncoding{iRowEncoding,4}, ...
    'NumChannels',          iChannels, ...
    'SampleRate',           iSampleRate, ...
    'TotalSamples',         iDataSize*8 / iBitsPerSample / iChannels, ...
    'Duration',             iDataSize*8 / iBitsPerSample / iSampleRate / iChannels, ...
    'Title',                [], ...
    'Comment',              [], ...
    'Artist',               [], ...
    'BitsPerSample',        iBitsPerSample, ...
    'DataOffset',           iDataOffset, ...
    'Encoding',             iEncoding, ...
    'EncodingDescription',  caEncoding{iRowEncoding,end});

