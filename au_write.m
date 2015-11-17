function au_write(szFilename, data, fs, iStart, szDataType)
%AU_WRITE Write data in an au-file.
%   AU_WRITE(FILENAME, DATA, FS) writes the audio data in DATA with a given
%   FS in a au-file, which was specified by the string FILENAME. If a
%   au-file with FILENAME already exists, it will be overwritten.

%   AU_WRITE(FILENAME, DATA, FS, START) writes the DATA in theinterval
%   START through START+size(DATA,1) for each channel in the file. If you
%   set START to Inf, AU_WRITE will append DATA on an existing au-file.
%   Furthermore AU_WRITE will overwrite all existing samples if START is
%   not specified or START = [].
%
%   AU_WRITE(FILENAME, DATA, FS, START, DATATYPE) writes a au-file
%   with a specified DATATYPE. Valid strings are int8, int16, int24,
%   int32, float32 or float64.
%
%   Usage:
%       au_write('testfile.au', rand(10*44100, 2)-.5)
%       au_write('testfile.au', .9*ones(5,2), 44100, 3)
%       au_write('testfile.au', rand(10*44100, 2)-.5, 44100, 3, 'int32')
%       au_write('testfile.au', rand(10*44100, 2)-.5, 44100, 3, 'float64')
%
%   Output Data Ranges
%   DATA should be a m-by-n matrix, where m is the number of audio samples
%   read and n is the number of audio channels in the file.
%
%   Note:
%   * If datatype is a kind if int, samples >1 or <(-1) will be clipped.
%
%   See also: au_info, au_write, audioinfo, audioread, audiowrite

%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule
% This project is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------

if nargin < 4 || isempty(iStart)
    szPermission = 'new';
    iStart = 1;
else
    szPermission = 'readwrite';
end

if nargin < 5
    szDataType = 'int16';
end

vSize   = size(data);
objAU   = AUFile(szFilename, szPermission, vSize(2), fs, szDataType);

if iStart == Inf
    iStart = objAU.TotalSamples +1;
end


objAU.seek(iStart);
objAU.write(data);
