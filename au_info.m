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
%                       values are 8,16,24,32 or 64.
%
%   'Datatype'          Format in which the values should be written. Valid
%                       strings are int8, int16, int24, int32, float32
%                       or float64.
%
%   DATAOFFSET returns the offset after which the audio data starts, it is
%   equal to the size of the header. DATASIZE is specified as the size of
%   the au data.
%
%   See also: AUFile, au_read, au_write, audioinfo, audioread, audiowrite

%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule
% This project is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------

objAU       = AUFile(szFilename, 'read');

warning('off')              %#ok
stInfo      = struct(objAU);
warning('on')               %#ok
iDataOffset = objAU.iDataOffset;
iDataSize   = objAU.iDataOffset + objAU.TotalSamples * objAU.BitsPerSample/8;
