% TGM_au_test tests the TGM_au* functions.
%
%--------------------------------------------------------------------------
% This projected is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% See also: au_info, au_read, au_write.


% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create                                   05-May-2015 JK
% Ver. 0.02 combined all test files                          06-May-2015 JK

% Generation of wav-files in Matlab:
%   * n=1; audiowrite(['ref_Bit' num2str(n) '.wav'],1./2.^[0:n-1],44100);
%   * audiowrite('ref.wav',rand(fs,1)-.5,44100);
%   * audiowrite('ref_48kHz.wav',rand(fs,1)-.5,48000);

% Convert wav- to au-files via SoX:
%   * sox ref.wav -e signed-integer -c {nChans} ref_CH{nChans}.au
%   * sox ref_Bit{nBits}.wav -e signed-integer -c 1 -b {nBits} ref_Bit{nBits}.au
%   * sox ref_Bit{nBits}.wav -e floating-point -c 1 -b {nBits} ref_Bit{nBits}_float.au
%   * sox ref_48kHz.wav -e signed-integer -c 1 -b 16 ref_48kHz.au

%--------------------------------------------------------------------------

% caEncoding = {...
%      1, 'mu',       8, 'Compressed',   false,     'bit8', '8-bit G.711 µ-law';...
%      2, 'int8',     8, 'Uncompressed', true,   'bit8', '8-bit linear PCM';...
%      3, 'int16',   16, 'Uncompressed', true,  'bit16', '16-bit linear PCM';...
%      4, 'int24',   24, 'Uncompressed', true,  'bit24', '24-bit linear PCM';...
%      5, 'int32',   32, 'Uncompressed', true,  'bit32', '32-bit linear PCM';...
%      6, 'single',  32, 'Uncompressed', true,'float32', '32-bit IEEE floating point';...
%      7, 'double',  64, 'Uncompressed', true,'float64', '64-bit IEEE floating point';...
%      8, '',        [], '',             false,       '', 'Fragmented sample data';...
%      9, '',        [], '',             false,       '', 'DSP program';...
%     10, '',         8, 'Uncompressed', false,       '', '8-bit fixed point';...
%     11, '',        16, 'Uncompressed', false,       '', '16-bit fixed point';...
%     12, '',        24, 'Uncompressed', false,       '', '24-bit fixed point';...
%     13, '',        32, 'Uncompressed', false,       '', '32-bit fixed point';...
%     18, '',        16, 'Compressed',   false,       '', '16-bit linear with emphasis';...
%     19, '',        16, 'Compressed',   false,       '', '16-bit linear compressed';...
%     20, '',        16, 'Compressed',   false,       '', '16-bit linear with emphasis and compression';...
%     21, '',        [], '',             false,       '', 'Music kit DSP commands';...
%     23, '',         4, '',             false,       '', '4-bit ITU-T G.721 ADPCM';...
%     24, '',        [], '',             false,       '', 'ITU-T G.722 SB-ADPCM';...
%     25, '',         3, '',             false,       '', 'ITU-T G.723 3-bit ADPCM';...
%     26, '',         5, '',             false,       '', 'ITU-T G.723 5-bit ADPCM';...
%     27, '',         8, 'Compressed',   false,       '', '8-bit G.711 A-law';...
%     };
% save('encoding.mat')


%% preferences

iChannels       = 2;                            % Channels: 1|2|4

szPath          = fileparts(which('au_test.m'));
cd(szPath)
szName          = 'tester_noise.wav';           % name of a reference wav
fs              = 44100;
audiowrite(szName,rand(fs*10,1)-.5,fs);
szFile_wav      = fullfile(szPath,szName);
szFile_au_ref   = fullfile(szPath,[szName(1:end-4) '_ref.au']);
szFile_au_new   = fullfile(szPath,[szName(1:end-4) '_TGM.au']);

% Include usr/local binaries (necessary on OSX for brew versions)
if isunix
    PATH = getenv('PATH');
    setenv('PATH', [PATH ':/usr/local/bin']);
end

szCmd = sprintf('sox "%s" -c %i "%s"',szFile_wav,iChannels,szFile_au_ref);

[bError, msg] = system(szCmd);
if bError
    error('Sox Commandline error!')
end
save(fullfile(szPath,'tester_temp.mat'),...
    'szPath','szFile_wav','szFile_au_ref','szFile_au_new')



%--------------------------------------------------------------------------
%                   ####   AU WRITE   ####
%--------------------------------------------------------------------------



%% WRITE: generate testing-data
load(which('tester_temp.mat'))
[vSig,fs] = audioread(szFile_au_ref);
au_write(szFile_au_new,vSig,fs)

%% WRITE: testing
load(which('tester_temp.mat'))
[vSig_ref,fs_ref] = audioread(szFile_au_ref);
[vSig_new,fs_new] = audioread(szFile_au_new);

if fs_ref~=fs_new || any(vSig_ref(:) ~= vSig_new(:))
    plot(vSig_ref - vSig_new)
    title('Difference between signals: ref - new')
    error('ATTENTION: Saved vectors are not identical!!')
end



%--------------------------------------------------------------------------
%                   ####   AU INFO   ####
%--------------------------------------------------------------------------



%% INFO: create info struct
load(which('tester_temp.mat'))
stInfo      = au_info(szFile_au_ref);
stInfo_ref  = audioinfo(szFile_au_ref);

if ~strcmp(stInfo.Filename,stInfo_ref.Filename)
    error('Filename not consistent!')
end
if ~strcmp(stInfo.CompressionMethod,stInfo_ref.CompressionMethod)
    error('CompressionMethod not consistent!')
end
if stInfo.NumChannels ~= stInfo_ref.NumChannels
    error('NumChannels not consistent!')
end
if stInfo.SampleRate ~= stInfo_ref.SampleRate
    error('SampleRate not consistent!')
end
if stInfo.TotalSamples ~= stInfo_ref.TotalSamples
    error('TotalSamples not consistent!')
end
if stInfo.Duration ~= stInfo_ref.Duration
    error('Duration not consistent!')
end
if stInfo.BitsPerSample ~= stInfo_ref.BitsPerSample
    error('NumChannels not consistent!')
end



%--------------------------------------------------------------------------
%                   ####   AU READ   ####
%--------------------------------------------------------------------------



%% READ: read data without interval
load(which('tester_temp.mat'))
[y,fs]          = au_read(szFile_au_ref);
[y_ref,fs_ref]  = audioread(szFile_au_ref);

if fs ~= fs_ref || any(y(:) ~= y_ref(:))
    error('Data corrupt!')
end

%% READ: read data with interval (1)
load(which('tester_temp.mat'))
vSamples = [10 200];

[y,fs]          = au_read(szFile_au_ref,vSamples);
[y_ref,fs_ref]  = audioread(szFile_au_ref,vSamples);

if fs ~= fs_ref || any(y(:) ~= y_ref(:))
    error('Data corrupt!')
end

%% READ: read data with interval (2)
load(which('tester_temp.mat'))
vSamples = [10 Inf];

[y,fs]          = au_read(szFile_au_ref,vSamples);
[y_ref,fs_ref]  = audioread(szFile_au_ref,vSamples);

if fs ~= fs_ref || any(y(:) ~= y_ref(:))
    error('Data corrupt!')
end
