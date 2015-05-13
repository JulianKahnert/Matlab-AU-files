function [] = au_write(szFilename,y,fs)
% TGM_auwrite Write audiodata in an au-file.
%
%--------------------------------------------------------------------------
%
% [] = TGM_auwrite(szFilename,y,fs)
%
%
% szFilename:   String which contains the name of the au-file, that should
%               be created. If a path is specified, it can be absolute,
%               relative, or partial.
%
% y:            Vector or matrix which contains the audio data, specified
%               as an m-by-n matrix, where m is the number of audio samples
%               to write and n is the number of audio channels to write.
%
% fs:           Samplerate of you audio data.
%
%--------------------------------------------------------------------------
%
% Example:      TGM_auwrite('test.au',rand(44100*3,1)-0.5,44100)
%
%--------------------------------------------------------------------------
% This projected is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% See also: TGM_auinfo, TGM_auread.

% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create                                   29-Apr-2015 JK
% Ver. 0.02 help update                                      06-May-2015 JK

% To-Do:
%   * check if .au extension is missing and attends it automatically
%   * check if reshape really increases performance
%   * error message, if aufile could not be written
%   * blockwise writing

%--------------------------------------------------------------------------

% variable values
[iSamples,iCH]  = size(y);
iSamples_total  = iCH * iSamples;
% iEncoding       = 3;
iEncoding       = 4;
% szFormat        = 'int16';
% nbits           = 16;
nbits           = 24;

% fixed values
szMagicNumber   = '.snd';


%% input checking

if strcmp(szFilename(end-3),'.au')
    szFilename = [szFilename '.au'];
end


%% write header

FID = fopen(szFilename,'w','b');
fwrite(FID,int32(szMagicNumber),'uchar');          % 0 magic number
fwrite(FID,24,                  'uint32');         % 1 data offset
fwrite(FID,intmax('uint32'),    'uint32');         % 2 data size
fwrite(FID,iEncoding,           'uint32');         % 3 encoding
fwrite(FID,fs,                  'uint32');         % 4 sample rate
fwrite(FID,iCH,                 'uint32');         % 5 channels


%% write data

% quantisation
max_amp = 2^(nbits-1);
quant_data = round(y*max_amp);
if nbits == 8,
  % in order to fit number range -128...+127 into that of an unsigned char:
  quant_data = quant_data + 128; 
end

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

% fwrite(FID, quant_data, szFormat);
fwrite(FID, quant_data, 'bit24');
fclose(FID);

