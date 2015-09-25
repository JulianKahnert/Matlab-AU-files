function au_write(szFilename, data, fs, vRange, szDataType)
%AU_WRITE Write data in an au-file.
%   AU_WRITE(FILENAME, DATA, FS) writes the audio data in DATA with a given
%   FS in a au-file, which was specified by the string FILENAME. If a
%   au-file with FILENAME already exists, it will be overwritten.

%   AU_WRITE(FILENAME, DATA, FS, [START END]) writes the DATA in the
%   interval START through END for each channel in the file. If you set
%   START to Inf, AU_WRITE will append DATA on an existing au-file.
%   Furthermore AU_WRITE will overwrite all existing samples if: 
%       [START END] = [1 Inf], or
%       [START END] = []
%
%   AU_WRITE(FILENAME, DATA, FS, [START END], DATATYPE) writes a au-file
%   with a specified DATATYPE. Valid strings are int8, int16, int24,
%   int32, float32 or float64.
%
%   Usage:
%       au_write('testfile.au',rand(10*44100,2)-.5)
%       au_write('testfile.au',.9*ones(5,2),[3 7])
%       au_write('testfile.au',rand(10*44100,2)-.5,'int32')
%       au_write('testfile.au',rand(10*44100,2)-.5,'float64')
%
%   Output Data Ranges
%   DATA should be a m-by-n matrix, where m is the number of audio samples
%   read and n is the number of audio channels in the file.
%
%   Note:
%   * If datatype is a kind if int, samples >1 or <(-1) will be clipped.
%   * END automatically set: END = START+size(DATA,1)
%
%   See also: au_info, au_write, audioinfo, audioread, audiowrite

%--------------------------------------------------------------------------
% This project is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule
% Version History:
% Ver. 0.1.0 initial create                                  29-Apr-2015 JK
% Ver. 0.2.0 help update                                     06-May-2015 JK
% Ver. 0.3.0 first mayor release                             19-May-2015 JK
% Ver. 0.4.0 blockwise writing                               21-May-2015 JK
%--------------------------------------------------------------------------

if nargin < 4 || isempty(vRange) || all(vRange == [1 Inf])
    szPermission = 'new';
    vRange = [1 Inf];
else
    szPermission = 'readwrite';
end

if nargin < 5
    szDataType = 'int16';
end

vSize   = size(data);
objAU   = AUFile(szFilename, szPermission, vSize(2), fs, szDataType);


if all(vRange == [1 Inf])
    objAU.write(data);
else
    objAU.seek(vRange(1));
    objAU.write(data); % vRange(2)-vRange(1)+1
end




