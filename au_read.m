function [data, fs, stInfo] = au_read(szFilename, vRange)
%AU_READ Read the audio data of an au-file.
%   [DATA, FS] = AU_READ(FILENAME, RANGE) returns the audio data and
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
%   See also: au_info, au_write, audioinfo, audioread, audiowrite

%--------------------------------------------------------------------------
% This project is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule
% Version History:
% Ver. 0.1.0 initial create                                  05-May-2015 JK
% Ver. 0.2.0 help update                                     06-May-2015 JK
% Ver. 0.3.0 first mayor release                             19-May-2015 JK
% Ver. 0.4.0 new structure + avoid load('*.mat')             21-May-2015 JK
% Ver. 0.5.0 implementation of au class                      12-sep-2015 JK
%--------------------------------------------------------------------------

if nargin < 2 || isempty(vRange)
    vRange = [1 Inf];
end

objAU       = AUClass(szFilename);
objAU.open('read');

if vRange(2) == Inf
    vRange(2) = objAU.TotalSamples;
end

b1 = any(vRange <= 0);
b2 = vRange(1) > vRange(2);
b3 = vRange(2) > objAU.TotalSamples;
b4 = length(vRange) ~= 2;
if b1 || b2 || b3 || b4
    error('Selected range not correct.')
end

objAU.seek(vRange(1));


%% define output

data    = objAU.read( vRange(2)-vRange(1)+1 );
fs      = objAU.SampleRate;
warning('off')                  %#ok
stInfo  = struct(objAU);
warning('on')                   %#ok
