function []=TGM_auwrite(szName,y,fs)
% function to do something usefull (fill out)
% Usage [outParam]=TGM_auwrite(inParam)
%
% Parameters
% ----------
% inParam :  type
%	 explanation
%
% Returns
% -------
% outParam :  type
%	 explanation
%
%------------------------------------------------------------------------ 
% Example: Provide example here if applicable (one or two lines) 

% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF 
% Source: If the function is based on a scientific paper or a web site, 
%         provide the citation detail here (with equation no. if applicable)  
% Version History:
% Ver. 0.01 initial create                                   29-Apr-2015 JK

% To-Do:
%   * check if .au extension is missing and attends it automatically
%   * check if reshape really increases performance
%   * error message, if aufile could not be written
%   * blockwise writing

%------------Your function implementation here--------------------------- 



% variable values
[iSamples,iCH]  = size(y);
iSamples_total  = iCH * iSamples;
iEncoding       = 3;

% szFormat        = 'uint32';
szFormat        = 'int16';
nbits           = 16;


% fixed values
szMagicNumber   = '.snd';
szDataSize      = 'ffffffff';


%% input checking

if strcmp(szName(end-3),'.au')
    szName = [szName '.au'];
end


%% write header

[FID,msg] = fopen(szName,'w','b');
fwrite(FID,int32(szMagicNumber),'uchar');       % 0 magic number
fwrite(FID,24,'uint32');                        % 1 data offset
fwrite(FID,hex2dec(szDataSize),'uint32');       % 2 data size
fwrite(FID,iEncoding,'uint32');                 % 3 encoding
fwrite(FID,fs,'uint32');                        % 4 sample rate
fwrite(FID,iCH,'uint32');                    % 5 channels


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
  warning('your data block exhibits %d clipped sample(s), of %d samples in total\n', nclips, iSamples_total);
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


%--------------------Licence ---------------------------------------------
% Copyright (c) <2015> Julian Kahnert
% Jade University of Applied Sciences 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files 
% (the "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject
% to the following conditions:
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.