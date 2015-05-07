% TGM_au_test tests the TGM_au* functions.
%
%--------------------------------------------------------------------------
% This projected is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% See also: TGM_auinfo, TGM_auread, TGM_auwrite.


% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create                                   05-May-2015 JK
% Ver. 0.02 combined all test files                          06-May-2015 JK

% To-Do:
%   *

%--------------------------------------------------------------------------


%% preferences
szName          = 'KriegDerWeltenShort.wav';    % name of a reference wav
iChannels       = 2;                            % Channels: 1|2|4

szPath          = fileparts(which('TGM_au_test.m'));
cd(szPath)

szFile_wav      = fullfile(szPath,szName);
szFile_au_ref   = ['tester_' szName(1:end-4) '_ref.au'];
szFile_au_new   = ['tester_' szName(1:end-4) '_TGM.au'];

% Include usr/local binaries (necessary on OSX for brew versions)
PATH = getenv('PATH');
setenv('PATH', [PATH ':/usr/local/bin']);

szCmd = sprintf('sox "%s" -c %i "%s"',szFile_wav,iChannels,szFile_au_ref);

[bError, msg] = system(szCmd);
save(fullfile(szPath,'tester_temp.mat'),...
    'szPath','szFile_wav','szFile_au_ref','szFile_au_new')



%--------------------------------------------------------------------------
%                   ####   AU WRITE   ####
%--------------------------------------------------------------------------



%% WRITE: generate testing-data
load(which('tester_temp.mat'))
[vSig,fs] = audioread(szFile_au_ref);
TGM_auwrite(szFile_au_new,vSig,fs)

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
stInfo      = TGM_auinfo(szFile_au_ref);
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
[y,fs]          = TGM_auread(szFile_au_ref);
[y_ref,fs_ref]  = audioread(szFile_au_ref);

if fs ~= fs_ref || any(y(:) ~= y_ref(:))
    warning('Data corrupt!')
end

%% READ: read data with interval (1)
load(which('tester_temp.mat'))
vSamples = [10 200];

[y,fs]          = TGM_auread(szFile_au_ref,vSamples);
[y_ref,fs_ref]  = audioread(szFile_au_ref,vSamples);

if fs ~= fs_ref || any(y(:) ~= y_ref(:))
    warning('Data corrupt!')
end

%% READ: read data with interval (2)
load(which('tester_temp.mat'))
vSamples = [10 Inf];

[y,fs]          = TGM_auread(szFile_au_ref,vSamples);
[y_ref,fs_ref]  = audioread(szFile_au_ref,vSamples);

if fs ~= fs_ref || any(y(:) ~= y_ref(:))
    error('Data corrupt!')
end
