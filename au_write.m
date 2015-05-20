function au_write(szFilename,data,fs,szEncoding,vInterval)
%AU_WRITE Write audiodata in an au-file.
%
% AU_WRITE(szFilename,data,fs,szEncoding,vInterval)
%
%   szFilename:
%       String which contains the name of the au-file, that should be
%       created. If a path is specified, it can be absolute, relative, or
%       partial.
%
%   data:
%       Vector or matrix which contains the audio data, specified as an
%       m-by-n matrix, where m is the number of audio samples to write and
%       n is the number of audio channels to write.
%   fs:
%       Samplerate of you audio data.
%   szEncoding:
%       'mu'
%       'int8'
%       'int16'
%       'int24'
%       'int32'
%       'single'
%       'double'
%   vInterval
%
%   See also: au_info, au_read, 

%--------------------------------------------------------------------------
% This project is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule
% Version History:
% Ver. 0.1.0 initial create                                  29-Apr-2015 JK
% Ver. 0.2.0 help update                                     06-May-2015 JK
% Ver. 0.3.0 first mayor release                             19-May-2015 JK
%--------------------------------------------------------------------------
% To-Do:
%   * check if .au extension is missing and appends it automatically
%   * check if reshape really increases performance
%   * error message, if aufile could not be written
%--------------------------------------------------------------------------


%% input check

% defaul input settings
szEncoding_default  = 'int16';
vInterval_default   = [1 Inf];
if nargin < 4 || isempty(szEncoding)
    szEncoding = szEncoding_default;
end
if nargin < 5 || isempty(vInterval)
    vInterval = vInterval_default;
end

% variable values
[iSamples,iCH]  = size(data);
iSamples_total  = iCH * iSamples;

% {iEncoding, szEncoding, iBitsPerSample, fwritePrecission, szCompression, bSupported, szDescription}
caEncoding = [];
load(fullfile(which(fileparts(mfilename('fullpath'))),'encoding.mat'))


if ~exist(szFilename,'file') || all(vInterval == vInterval_default)
    iRowEncoding    = strcmpi(szEncoding,caEncoding(:,2));
    iEncoding       = caEncoding{iRowEncoding,1};
    iBitsPerSample  = caEncoding{iRowEncoding,3};
    szFormat        = caEncoding{iRowEncoding,6};

    % fixed values
    szMagicNumber   = '.snd';

    [szPath,szName,szExt]= fileparts(szFilename);
    if isempty(szExt) || ~strcmp(szExt,'.au')
        szFilename = fullfile(szPath,[szName '.au']);
    end

    % write header, if file does not exist
    fid  = fopen(szFilename,'w','b');
    fwrite(fid,int32(szMagicNumber),'uchar');          % 0 magic number
    fwrite(fid,24,                  'uint32');         % 1 data offset
    fwrite(fid,intmax('uint32'),    'uint32');         % 2 data size
    fwrite(fid,iEncoding,           'uint32');         % 3 encoding
    fwrite(fid,fs,                  'uint32');         % 4 sample rate
    fwrite(fid,iCH,                 'uint32');         % 5 channels
    
else
    % get information, if file exists
    stInfo          = au_info(szFilename);
    if stInfo.NumChannels ~= size(data,2)
            error('Number of channels in existing file and input matrix dismatch!')
    end
    
    iEncoding       = stInfo.Encoding;
    iRowEncoding    = find([caEncoding{:,1}] == iEncoding);
    iBitsPerSample  = caEncoding{iRowEncoding,3};
    szFormat        = caEncoding{iRowEncoding,6};
    
    if vInterval(1) == Inf
        % case: append samples
        fid = fopen(szFilename,'a','b');
    
    else
        % case: change samples in interval
        if vInterval(2)-vInterval(1)+1 ~= size(data,1)
            error('Number of samples in interval and rows of input matrix dismatch!')
        end
        fid = fopen(szFilename,'r+','b');
        % define first byte in the desired interval and jump to it
        iOffset = stInfo.DataOffset + ...
            (vInterval(1)-1)*iBitsPerSample/8*stInfo.NumChannels;
        fseek(fid,iOffset,'bof');
        
    end
end


%% write data

% for a higher speed:  
% in case of stereo data, reshape them into 1 long column  
if iCH > 1,
  data = reshape(data', iSamples_total, 1);
end

%#% falls int strcmp(sz(1:3),'int')
fwrite(fid, data*2^(iBitsPerSample-1), szFormat);
fclose(fid);

