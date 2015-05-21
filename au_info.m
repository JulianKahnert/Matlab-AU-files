function [stInfo, iDataOffset, iDataSize] = au_info(szFilename)
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
% Ver. 0.4.0 new structure + avoid load('*.mat')             21-May-2015 JK
%--------------------------------------------------------------------------


%% read header from file

fid = fopen(szFilename, 'r');
if fid == -1
    error('Can not read file. Is the path correct?')
end
magicnumber = fread(fid, 4, 'uint8', 0, 'b');
if ~all(magicnumber' == uint8('.snd'))
    fclose(fid);
    error('Header of the file corrupt. Is it a au-file?')
end
iDataOffset = fread(fid, 1, 'uint32', 0, 'b');
iDataSize   = fread(fid, 1, 'uint32', 0, 'b');      %#ok overwrite later
iEncoding   = fread(fid, 1, 'uint32', 0, 'b');
iSampleRate = fread(fid, 1, 'uint32', 0, 'b');
iChannels   = fread(fid, 1, 'uint32', 0, 'b');

% get absolute file path
szAbsPath = fopen(fid);
fclose(fid);
% get file size
stFile = dir(szAbsPath);
iDataSize = stFile.bytes - iDataOffset;


%% write info struct

% Datatype {iEncoding, fwritePrecission, iBitsPerSample, szCompression, bSupported, szDescription}
stDetails = struct( ...
    'mu',       {1, '',        8,  'u-law',        false}, ...
    'int8',     {2, 'bit8',    8,  'Uncompressed', true},  ...
    'int16',    {3, 'bit16'    16, 'Uncompressed', true},  ...
    'int24',    {4, 'bit24',   24, 'Uncompressed', true},  ...
    'int32',    {5, 'bit32',   32, 'Uncompressed', true},  ...
    'float32',  {6, 'float32', 32, 'Uncompressed', true},  ...
    'float64',  {7, 'float64', 64, 'Uncompressed', true}   ...
    );

szDatatype  = fieldnames(stDetails);
szDatatype  = szDatatype{iEncoding};
iBitsPerSample = stDetails(3).(szDatatype);

stInfo = struct(...
    'Filename',             szAbsPath, ...
    'CompressionMethod',    stDetails(4).(szDatatype), ...
    'NumChannels',          iChannels, ...
    'SampleRate',           iSampleRate, ...
    'TotalSamples',         iDataSize*8 / iBitsPerSample / iChannels, ...
    'Duration',             iDataSize*8 / iBitsPerSample / iSampleRate / iChannels, ...
    'Title',                [], ...
    'Comment',              [], ...
    'Artist',               [], ...
    'BitsPerSample',        iBitsPerSample, ...
    'Datatype',             szDatatype);

end
