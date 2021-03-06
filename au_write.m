function au_write(szFilename, data, fs, varargin)
%AU_WRITE Write data in an au-file.
%   AU_WRITE(FILENAME, DATA, FS) writes the audio data in DATA with a given
%   FS in a au-file, which was specified by the string FILENAME. If a
%   au-file with FILENAME already exists, it will be overwritten.
%
%   AU_WRITE(FILENAME, DATA, FS, START]) writes the DATA in the interval
%   START through START+size(DATA,1) for each channel in the file. If you
%   set START to Inf, AU_WRITE will append DATA on an existing file.
%
%   AU_WRITE(FILENAME, DATA, FS, START, DATATYPE) writes a au-file with a
%   specified DATATYPE. Valid strings are int8, int16, int24, int32,
%   float32 or float64. If DATATYPE is specified, you have to assign START.
%
%   Usage:
%       au_write('testfile.au', rand(10*44100, 2)-.5)
%       au_write('testfile.au', .9*ones(5,2), 44100, 3)
%       au_write('testfile.au', rand(10*44100, 2)-.5, 44100, 1, 'int32')
%       au_write('testfile.au', rand(10*44100, 2)-.5, 44100, 3, 'float64')
%
%   Output Data Ranges
%   DATA should be a m-by-n matrix, where m is the number of audio samples
%   read and n is the number of audio channels in the file.
%
%   Note:
%   * If datatype is a kind if int, samples >1 or <(-1) will be clipped.
%   * Matlab does not support any kind of file truncation, so there is no
%   feature in au_write either.
%
%   See also: AUFile, au_info, au_write, audioinfo, audioread, audiowrite

%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule
% This project is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------

objParser= inputParser;
valiFcn1 = @(x) ischar(x) && strcmp(x(end-2:end),'.au');
valiFcn2 = @(x) validateattributes(x,{'numeric'},{'scalar','integer','positive'});
valiFcn4 = @(x) any(strcmp(x,{'int8' 'int16' 'int24' 'int32' 'float32' 'float64'}));

addRequired(objParser, 'szFilename',        valiFcn1)
addRequired(objParser, 'data',              @isnumeric)
addRequired(objParser, 'fs',                valiFcn2)
addOptional(objParser, 'iStart',    1)
addOptional(objParser, 'szDatatype','int16',valiFcn4)

parse(objParser, szFilename, data, fs, varargin{:})

szFilename  = objParser.Results.szFilename;
data        = objParser.Results.data;
fs          = objParser.Results.fs;
iStart      = objParser.Results.iStart;
szDatatype  = objParser.Results.szDatatype;

if iStart == 1
    szPermission    = 'new';
else
    szPermission    = 'readwrite';
end

vSize   = size(data);
objAU   = AUFile(szFilename, szPermission, vSize(2), fs, szDatatype);

if iStart == Inf
    iStart = objAU.TotalSamples +1;
end

objAU.seek(iStart);
objAU.write(data);
