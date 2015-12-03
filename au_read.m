function [data, fs, stInfo] = au_read(szFilename, vRange)
%AU_READ Read the audio data of an au-file.
%   [DATA, FS] = AU_READ(FILENAME) returns the audio data and
%   samplerate of a au-file, which was specified by the string FILENAME.
%
%   [DATA, FS] = AU_READ(FILENAME, [START END]) returns only samples START 
%   through END from each channel in the file.
%
%   [DATA, FS, INFO] = AU_READ(FILENAME, [START END]) also returns a INFO
%   struct, which is also returned by au_info().
%
%   Usage:
%       [data, fs, stInfo] = au_read('testfile.au',[100 200])
%
%   Output Data Ranges
%   DATA is returned as an m-by-n matrix, where m is the number of audio 
%   samples read and n is the number of audio channels in the file.
%
%   See also: AUFile, au_info, au_write, audioinfo, audioread, audiowrite

%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule
% This project is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------

if nargin < 2 || isempty(vRange)
    vRange = [1 Inf];
end

objAU = AUFile(szFilename, 'read');

if vRange(2) == Inf
    vRange(2) = objAU.TotalSamples;
end

bNegative   = any(vRange <= 0);
bSwapped    = vRange(1) > vRange(2);
bOutOfRange = vRange(2) > objAU.TotalSamples;
bWrongSize  = length(vRange) ~= 2;
if bNegative || bSwapped || bOutOfRange || bWrongSize
    error('Selected range not correct.')
end

objAU.seek(vRange(1));
data    = objAU.read( vRange(2)-vRange(1)+1 );
fs      = objAU.SampleRate;
stInfo  = au_info(szFilename);
