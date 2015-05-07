function [stInfo] = TGM_auinfo(szFilename)
% TGM_auinfo Return metadata of an au-file.
%
%--------------------------------------------------------------------------
%
% [stInfo] = TGM_auinfo(szFilename)
%
%
% szFilename:   String which contains the name of the au-file. If a path is
%               specified, it can be absolute, relative, or partial.
%
% stInfo:       Struct which contains the relevant information about the
%               au-file.
%
%--------------------------------------------------------------------------
%
% Example:      stInfo = TGM_auinfo('temp/TomShort.au')
%
%--------------------------------------------------------------------------
% This projected is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% See also: TGM_auread, TGM_auwrite.

% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create                                   05-May-2015 JK
% Ver. 0.02 help update                                      06-May-2015 JK

%--------------------------------------------------------------------------


%% read header from file

FID             = fopen(szFilename,'r');
if FID == -1
    error('Can not read file. Is the path correct?')
end
szMagicNumber   = fread(FID,4,'*char',0,'b');
iDataOffset     = fread(FID,1,'uint32',0,'b');
fseek(FID,4,'cof');                             % 2 data size
iEncoding       = fread(FID,1,'uint32',0,'b');
iSampleRate     = fread(FID,1,'uint32',0,'b');
iChannels       = fread(FID,1,'uint32',0,'b');

szPath          = fopen(FID);
stFile          = dir(szPath);
iDataSize       = stFile.bytes - iDataOffset;
fclose(FID);


%% show warnings if the data is corrupt

if ~strcmp(szMagicNumber.','.snd')
    error('The first 32 bits of your file are corrupt. Is it a au-file?')
end


%% write info struct
if iEncoding == 1       % 8-bit G.711 µ-law
    szCompression   = 'Compressed';
    iBitsPerSample  = 8;

elseif iEncoding == 2   % 8-bit linear PCM
    szCompression   = 'Uncompressed';
    iBitsPerSample  = 8;

elseif iEncoding == 3   % 16-bit linear PCM
    szCompression   = 'Uncompressed';
    iBitsPerSample  = 16;

elseif iEncoding == 4   % 24-bit linear PCM
    szCompression   = 'Uncompressed';
    iBitsPerSample  = 24;

elseif iEncoding == 5   % 32-bit linear PCM
    szCompression   = 'Uncompressed';
    iBitsPerSample  = 32;

elseif iEncoding == 6   % 32-bit IEEE floating point
    szCompression   = 'Uncompressed';
    iBitsPerSample  = 32;

% elseif iEncoding == 8   % Fragmented sample data
%     szCompression   = '';
%     iBitsPerSample  = [];

% elseif iEncoding == 9   % DSP program
%     szCompression   = '';
%     iBitsPerSample  = [];

elseif iEncoding == 10  % 8-bit fixed point
    szCompression   = 'Uncompressed';
    iBitsPerSample  = 8;

elseif iEncoding == 11  % 16-bit fixed point
    szCompression   = 'Uncompressed';
    iBitsPerSample  = 16;

elseif iEncoding == 12  % 24-bit fixed point
    szCompression   = 'Uncompressed';
    iBitsPerSample  = 24;

elseif iEncoding == 13  % 32-bit fixed point
    szCompression   = 'Uncompressed';
    iBitsPerSample  = 32;

% elseif iEncoding == 18  % 16-bit linear with emphasis
%     szCompression   = 'Uncompressed';
%     iBitsPerSample  = 16;

elseif iEncoding == 19  % 16-bit linear compressed
    szCompression   = 'compressed';
    iBitsPerSample  = 16;

elseif iEncoding == 20  % 16-bit linear with emphasis and compression
    szCompression   = 'compressed';
    iBitsPerSample  = 16;

% elseif iEncoding == 21  % Music kit DSP commands
%     szCompression   = '';
%     iBitsPerSample  = [];

elseif iEncoding == 23  % 4-bit compressed using the ITU-T G.721 ADPCM voice data encoding scheme
    szCompression   = 'compressed';
    iBitsPerSample  = 4;

% elseif iEncoding == 24  % ITU-T G.722 SB-ADPCM
%     szCompression   = '';
%     iBitsPerSample  = [];

% elseif iEncoding == 25  % ITU-T G.723 3-bit ADPCM
%     szCompression   = '';
%     iBitsPerSample  = 3;

% elseif iEncoding == 26  % ITU-T G.723 5-bit ADPCM
%     szCompression   = '';
%     iBitsPerSample  = 5;

elseif iEncoding == 27  % 8-bit G.711 A-law
    szCompression   = 'compressed';
    iBitsPerSample  = 8;
end


stInfo = struct(...
    'Filename',         szPath,...
    'CompressionMethod',szCompression,...
    'NumChannels',      iChannels,...
    'SampleRate',       iSampleRate,...
    'TotalSamples',     iDataSize*8 / iBitsPerSample / iChannels,...
    'Duration',         iDataSize*8 / iBitsPerSample / iSampleRate / iChannels,...
    'Title',            [],...
    'Comment',          [],...
    'Artist',           [],...
    'BitsPerSample',    iBitsPerSample,...
    'Encoding',         iEncoding,...
    'DataOffset',       iDataOffset);

