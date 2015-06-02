function [stInfo, iDataOffset, iDataSize] = au_info(szFilename)
%AU_INFO Metadata of a au-file.
%   [INFO, DATAOFFSET, DATASIZE] = AU_INFO(FILENAME) returns a struct with
%   fields which contain information about a specified au-file. FILENAME is
%   a string that specifies the name of the audio file, it can be absolute,
%   relative, or partial.
%
%   Usage:
%       [stInfo, iDataOffset, iDataSize] = au_info('testfile.au')
%
%   The first ten fields of the struct are same as in the Matlab function
%   audioinfo. The last field is au-specific:
%
%   'Filename'          A string containing the name of the file
%   'CompressionMethod' Method of audio compression in the file
%   'NumChannels'       Number of audio channels in the file.
%   'SampleRate'        The sample rate (in Hertz) of the data in the file.
%   'TotalSamples'      Total number of audio samples in the file.
%   'Duration'          Total duration in seconds of the audio in the file.
%   'Title'             Always empty for au-files.
%   'Comment'           Always empty for au-files.
%   'Artist'            Always empty for au-files.
%   'BitsPerSample'     Number of bits per sample in the au-file. Valid
%                       values are 8,16,24,32, or 64.
%
%   'Datatype'          Format in which the values should be written. Valid
%                       strings are int8, int16, int24, int32, float32
%                       or float64.
%
%   DATAOFFSET returns the offset after which the audio data starts, it is
%   equal to the size of the header. DATASIZE is specified as the size of
%   the au data.
%
%   See also: au_read, au_write, audioinfo, audioread, audiowrite

%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule
% This project is licensed under the terms of the MIT license.
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
