function [] = au_write(szFilename,y,fs,szEncoding,vInterval)
%AU_WRITE Write audiodata in an au-file.
%
% [] = AU_WRITE(szFilename,y,fs)
%
%   szFilename:
%       String which contains the name of the au-file, that should be
%       created. If a path is specified, it can be absolute, relative, or
%       partial.
%
%   y:
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
%
%   See also: au_info, au_read

%--------------------------------------------------------------------------
% This projected is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create                                   29-Apr-2015 JK
% Ver. 0.02 help update                                      06-May-2015 JK
% Ver. 1.0.0 first mayor release                             19-May-2015 JK
%--------------------------------------------------------------------------
% To-Do:
%   * check if .au extension is missing and attends it automatically
%   * check if reshape really increases performance
%   * error message, if aufile could not be written
%   * blockwise writing
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
[iSamples,iCH]  = size(y);
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
        warning('Wrong file-ending! New filename: ''%s''\n',[szName '.au'])
        szFilename = fullfile(szPath,[szName '.au']);
    end

    % write header, if file does not exist
    FID  = fopen(szFilename,'w','b');
    fwrite(FID,int32(szMagicNumber),'uchar');          % 0 magic number
    fwrite(FID,24,                  'uint32');         % 1 data offset
    fwrite(FID,intmax('uint32'),    'uint32');         % 2 data size
    fwrite(FID,iEncoding,           'uint32');         % 3 encoding
    fwrite(FID,fs,                  'uint32');         % 4 sample rate
    fwrite(FID,iCH,                 'uint32');         % 5 channels
    
else
    % get information, if file exists
    stInfo          = au_info(szFilename);
    if stInfo.NumChannels ~= size(y,2)
            error('Number of channels in existing file and input matrix dismatch!')
    end
    
    iEncoding       = stInfo.Encoding;
    iRowEncoding    = find([caEncoding{:,1}] == iEncoding);
    iBitsPerSample  = caEncoding{iRowEncoding,3};
    szFormat        = caEncoding{iRowEncoding,6};
    
    if vInterval(1) == Inf
        % case: append samples
        FID         = fopen(szFilename,'a','b');
    
    else
        % case: change samples in interval
        if vInterval(2)-vInterval(1)+1 ~= size(y,1)
            error('Number of samples in interval and rows of input matrix dismatch!')
        end
        FID         = fopen(szFilename,'r+','b');
        % define frist byte in the desired interval and jump to it
        iOffset_B   = stInfo.DataOffset + ...
            (vInterval(1)-1)*iBitsPerSample/8*stInfo.NumChannels;
        fseek(FID,iOffset_B,'bof');
        
    end
end


%% write data

% quantisation
max_amp = 2^(iBitsPerSample-1);
quant_data = round(y*max_amp);

% check for possible clipping:
nclips = numel(find( quant_data<-max_amp | quant_data >=max_amp ));
if nclips > 0,
  warning(['your data block exhibits %d clipped sample(s), '...
      'of %d samples in total\n'], nclips, iSamples_total);
  % no explicit clipping necessayr here, as clipping is
  % automatically performed by fwrite later 
end

% for a higher speed:  
% in case of stereo data, reshape them into 1 long column  
if iCH > 1,
  quant_data = reshape(quant_data', iSamples_total, 1);
end

fwrite(FID, quant_data, szFormat);

fclose(FID);

