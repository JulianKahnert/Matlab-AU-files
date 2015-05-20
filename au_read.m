function [data, fs, stInfo] = au_read(szFilename,vInterval_smp)
%AU_READ Read the audio data of an au-file.
%
%   [data, fs] = AU_READ(szFilename,vInterval_smp)
%
%   szFilename:
%       String which contains the name of the au-file, that should be read.
%       If a path is specified, it can be absolute, relative, or partial.
%   vInterval_smp:
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

stInfo  = au_info(szFilename);
fs      = stInfo.SampleRate;
fid     = fopen(szFilename,'r','b');
if fid == -1
    error('Can not open file.')
end

szPath          = fopen(fid);
stFile          = dir(szPath);
iDataSize_B     = stFile.bytes - stInfo.DataOffset;

caEncoding      = [];
load('encoding.mat')
iRowEncoding    = find([caEncoding{:,1}]==stInfo.Encoding);
if ~caEncoding{iRowEncoding,5}
    fclose(fid);
    error('The encoding-type ''%s'' is not supported.',...
        caEncoding{iRowEncoding,end})
end

iBitsPerSample  = caEncoding{iRowEncoding,3};
szFormat        = caEncoding{iRowEncoding,6};


%% read audio data

iTotal_smp = iDataSize_B*8/iBitsPerSample;
if nargin == 1
    vInterval_smp = [1 iTotal_smp];
elseif vInterval_smp(2) > iTotal_smp/stInfo.NumChannels && vInterval_smp(2) ~= Inf
    fclose(fid);
    error('The choosen interval is out of range!')
elseif vInterval_smp(2) == Inf
    vInterval_smp(2) = iTotal_smp;
end

if vInterval_smp(2) < vInterval_smp(1)
    fclose(fid);
    error('Incorrect range.')
end

% define first byte in the desired interval and jump to it
iOffset_B = stInfo.DataOffset + (vInterval_smp(1)-1)*iBitsPerSample/8*stInfo.NumChannels;
fseek(fid,iOffset_B,'bof');

% define length of the desired interval and read the samples
iNum_smp= ( vInterval_smp(2)-vInterval_smp(1)+1 ) *stInfo.NumChannels;
vSig    = fread(fid,iNum_smp,szFormat,0,'b');
fclose(fid);
% vSig    = fread(FID,iNum_smp,'float',0,'b');

% normalization
%#%
% max_amp = 2^(iBitsPerSample-1);
% vSig    = vSig/max_amp;
data       = reshape(vSig,stInfo.NumChannels,[]).';


