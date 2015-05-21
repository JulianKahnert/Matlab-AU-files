function [data, fs, stInfo] = au_read(szFilename,vRange)
%AU_READ Read the audio data of an au-file.
%
%   [data, fs] = AU_READ(szFilename,vRange)
%
%   szFilename:
%       String which contains the name of the au-file, that should be read.
%       If a path is specified, it can be absolute, relative, or partial.
%   vRange:
%       Two element vector [start end] which specifies the reading
%       interval. Start represents the first and end the last sample in
%       this interval.
%
%   data:
%       Vector or matrix which contains the audio data, specified as an
%       m-by-n matrix, where m is the number of audio samples and n is the
%       number of audio channels.
%   fs:
%       Samplerate of you audio data.
%
%   See also: au_info, au_write

%--------------------------------------------------------------------------
% This project is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule
% Version History:
% Ver. 0.1.0 initial create                                  05-May-2015 JK
% Ver. 0.2.0 help update                                     06-May-2015 JK
% Ver. 1.0.0 first mayor release                             19-May-2015 JK
%--------------------------------------------------------------------------


%% read header from file

% defaul input settings
vRange_default = [1 Inf];
if nargin < 2 || isempty(vRange)
    vRange = vRange_default;
end

% Datatype {iEncoding, fwritePrecission, iBitsPerSample, szCompression, bSupported, szDescription}
stDetails = struct(...
    'mu',       {1, '',        8,  'u-law',        false}, ...
    'int8',     {2, 'bit8',    8,  'Uncompressed', true}, ...
    'int16',    {3, 'bit16'    16, 'Uncompressed', true}, ...
    'int24',    {4, 'bit24',   24, 'Uncompressed', true}, ...
    'int32',    {5, 'bit32',   32, 'Uncompressed', true}, ...
    'float32',  {6, 'float32', 32, 'Uncompressed', true}, ...
    'float64',  {7, 'float64', 64, 'Uncompressed', true} ...
    );

[stInfo, iDataOffset, iDataSize]  = au_info(szFilename);
fs      = stInfo.SampleRate;
fid     = fopen(szFilename,'r','b');
if fid == -1
    error('Can not open file.')
end

if ~stDetails(5).(stInfo.Datatype)
    fclose(fid);
    error('The datatype ''%s'' is not supported.',...
        stInfo.Datatype)
end

szFormat        = stDetails(2).(stInfo.Datatype);
iBitsPerSample  = stDetails(3).(stInfo.Datatype);


%% read audio data

iTotal_smp = iDataSize*8/iBitsPerSample;
if vRange(2) == Inf
    vRange(2) = iTotal_smp/stInfo.NumChannels;
end

b1 = any(vRange <= 0);
b2 = vRange(1) > vRange(2);
b3 = vRange(2) > iTotal_smp/stInfo.NumChannels;
b4 = length(vRange) ~= 2;
if b1 || b2 || b3 || b4
    fclose(fid);
    error('Selected range not correct.')
end

% define first byte in the desired interval and jump to it
iOffset = iDataOffset + (vRange(1)-1)*iBitsPerSample/8*stInfo.NumChannels;
fseek(fid,iOffset,'bof');

% define length of the desired interval and read the samples
iNum_smp= ( vRange(2)-vRange(1)+1 ) *stInfo.NumChannels;
vSig    = fread(fid,iNum_smp,szFormat,0,'b');
fclose(fid);

% normalization in case of int*
if strcmp(stInfo.Datatype(1:2),'in')
    vSig = vSig/2^(iBitsPerSample-1);
end

data = reshape(vSig,stInfo.NumChannels,[]).';

end
