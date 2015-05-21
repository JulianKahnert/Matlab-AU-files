%AU_TEST Unit-test of metadata of au_info, au_read and au_write.
%
%   To test the integrity of the au_* functions, run:
%       runtests('au_test.m')
%
%   See also: au_info, au_read, au_write, audioinfo, audioread, audiowrite

%--------------------------------------------------------------------------
% This project is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule
% Version History:
% Ver. 0.1.0 initial create                                  05-May-2015 JK
% Ver. 0.2.0 help update                                     06-May-2015 JK
% Ver. 0.3.0 first mayor release                             19-May-2015 JK
% Ver. 0.4.0 avoid load('*.mat')                             21-May-2015 JK
%--------------------------------------------------------------------------


%% Main function to generate tests

function tests = tester_fun
tests = functiontests(localfunctions);
end


%% INFO-function

function testInfo(testCase)
    for i =1:numel(testCase.TestData.stFiles_all)
        szPath  = fullfile( ...
            testCase.TestData.szPath, ...
            testCase.TestData.stFiles_all(i).name);
        stInfo1 = au_info(szPath);
        stInfo2 = audioinfo(szPath);

        if ~strcmp(stInfo1.Filename, stInfo2.Filename)
            error('Filename not consistent!')
        end
        if ~strcmp(stInfo1.CompressionMethod, stInfo2.CompressionMethod)
            error('CompressionMethod not consistent!')
        end
        if stInfo1.NumChannels ~= stInfo2.NumChannels
            error('NumChannels not consistent!')
        end
        if stInfo1.SampleRate ~= stInfo2.SampleRate
            error('SampleRate not consistent!')
        end
        if stInfo1.TotalSamples ~= stInfo2.TotalSamples
            error('TotalSamples not consistent!')
        end
        if stInfo1.Duration ~= stInfo2.Duration
            error('Duration not consistent!')
        end
        if stInfo1.BitsPerSample ~= stInfo2.BitsPerSample
            error('NumChannels not consistent!')
        end
    end
end


%% READ-functions

function testRead(testCase)
% READ: read data without interval
    for i =1:numel(testCase.TestData.stFiles_all)
        szPath  = fullfile( ...
            testCase.TestData.szPath, ...
            testCase.TestData.stFiles_all(i).name);
        if strcmp(testCase.TestData.stFiles_all(i).name, 'test_MU.au')
            warning('mu-law not yet supported')
            return;
        end
        [y1, fs1] = au_read(szPath);
        [y2, fs2] = audioread(szPath);

        if fs1 ~= fs2 || any(y1(:) ~= y2(:))
            error('Data corrupt!')
        end
    end
end

function testReadInterval1(testCase)
% READ: read data with interval (1)
    vSamples= [2 5];
    for i =1:numel(testCase.TestData.stFiles_all)
        szPath  = fullfile( ...
            testCase.TestData.szPath, ...
            testCase.TestData.stFiles_all(i).name);
        if strcmp(testCase.TestData.stFiles_all(i).name, 'test_MU.au')
            warning('mu-law not yet supported')
            return;
        end
        [y1, fs1] = au_read(szPath, vSamples);
        [y2, fs2] = audioread(szPath, vSamples);
        
        if fs1 ~= fs2 || any(y1(:) ~= y2(:))
            error('Data corrupt!')
        end
    end
end

function testReadInterval2(testCase)
% READ: read data with interval (2)
    vSamples= [3 Inf];
    for i =1:numel(testCase.TestData.stFiles_all)
        szPath  = fullfile( ...
            testCase.TestData.szPath, ...
            testCase.TestData.stFiles_all(i).name);
        if strcmp(testCase.TestData.stFiles_all(i).name, 'test_MU.au')
            warning('mu-law not yet supported')
            return;
        end
        [y1, fs1] = au_read(szPath, vSamples);
        [y2, fs2] = audioread(szPath, vSamples);
        
        if fs1 ~= fs2 || any(y1(:) ~= y2(:))
            error('Data corrupt!')
        end
    end
end


%% WRITE-function

function testWrite_all(testCase)
% WRITE: different channel/sample-rate configurations + clipping
    for i =1:numel(testCase.TestData.stFiles_all)
        szPath      = fullfile( ...
            testCase.TestData.szPath, ...
            testCase.TestData.stFiles_all(i).name);
        szFile_new  = fullfile(testCase.TestData.szPath_tmp, ...
            [testCase.TestData.stFiles_all(i).name(1:end-3) '_test.au']);
        % reference file
        [y1, fs1] = audioread(szPath);
        
        % self-generated file
        au_write(szFile_new, y1, fs1)
        if ~exist(szFile_new, 'file')
            keyboard
            error('Au-file not written!')
        end
        [y2, fs2] = audioread(szFile_new);
        
        if fs1 ~= fs2 || any(y1(:) ~= y2(:))
            plot(y1 - y2)
            title('Difference between signals: ref - new')
            error('ATTENTION: Saved vectors are not identical!!')
        end
    end
    
end

function testWrite_bitDepths(testCase)
% WRITE: different bit-depths
    caDatatypes = fieldnames(testCase.TestData.stDetails);
    caDatatypes = caDatatypes(struct2array(testCase.TestData.stDetails(5)));
    for i = 1:numel(caDatatypes)
        iBitsPerSample = testCase.TestData.stDetails(3).(caDatatypes{i});
        szFile_new = fullfile(testCase.TestData.szPath_tmp, ...
            ['WriteTest_Bit' num2str(iBitsPerSample) '.au']);
        
        % reference signal
        y1 = 1./2.^(1:iBitsPerSample-1).';
        
        % self-generated file
        au_write(szFile_new, y1, 44100, [], caDatatypes{i})
        if ~exist(szFile_new, 'file')
            error('Au-file not written!')
        end
        [y2, ~] = audioread(szFile_new);
        
        if any(y1(:) ~= y2(:))
            plot(y1 - y2)
            title('Difference between signals: ref - new')
            error('ATTENTION: Saved vectors are not identical!!')
        end
    end
    
end

function testWrite_interval_CH1(testCase)
% WRITE: specified interval 1 channel
    szFile_new      = fullfile(testCase.TestData.szPath_tmp, ...
        'test_writeInterval_CH3.au');

    vInterval   = [2 4];
    iCH         = 1;

    % reference signal
    y_ref       = ones(10, iCH)/2;
    au_write(szFile_new, y_ref, 44100)

    % generate new signal
    iNumSamples = vInterval(2)-vInterval(1)+1;
    y_new       = repmat(linspace(0, 1/4, iCH), iNumSamples, 1);
    y_1         = [y_ref(1:vInterval(1)-1, :); ...
        y_new; ...
        y_ref(vInterval(2)+1:end, :)];

    % write interval
    au_write(szFile_new, y_new, 44100, vInterval)
    y_2         = audioread(szFile_new);

    if any(any(y_1 ~= y_2))
        error('Write interval (CH1): Data corrupt!')
    end
end

function testWrite_interval_CH3(testCase)
% WRITE: specified interval 3 channels
    szFile_new      = fullfile(testCase.TestData.szPath_tmp, ...
        'test_writeInterval_CH3.au');

    vInterval   = [2 4];
    iCH         = 3;

    % reference signal
    y_ref       = ones(10, iCH)/2;
    au_write(szFile_new, y_ref, 44100)

    % generate new signal
    iNumSamples = vInterval(2)-vInterval(1)+1;
    y_new       = repmat(linspace(0, 1/4, iCH), iNumSamples, 1);
    y_1         = [y_ref(1:vInterval(1)-1, :); ...
        y_new; ...
        y_ref(vInterval(2)+1:end, :)];

    % write interval
    au_write(szFile_new, y_new, 44100, vInterval)
    y_2         = audioread(szFile_new);

    if any(any(y_1 ~= y_2))
        error('Write interval (CH2): Data corrupt!')
    end
end

function testWrite_append(testCase)
% WRITE: append data
    szFile_new      = fullfile(testCase.TestData.szPath_tmp, ...
        'test_writeInterval_append.au');

    vInterval   = [Inf 4];
    iCH         = 3;

    % reference signal
    y_ref       = ones(10, iCH)/2;
    au_write(szFile_new, y_ref, 44100)

    % generate new signal
    iNumSamples = 3;
    y_new       = repmat(linspace(0, 1/4, iCH), iNumSamples, 1);
    y_1         = [y_ref; ...
        y_new];

    % write interval
    au_write(szFile_new, y_new, 44100, vInterval)
    y_2 = audioread(szFile_new);

    if any(any(y_1 ~= y_2))
        error('Append data: Data corrupt!')
    end
end


%% Optional file fixtures

function setupOnce(testCase)  % do not change function name
    clc
    szPath          = fileparts(which('au_test.m'));
    cd(szPath)
    szPath = fileparts(which('au_test.m'));
    szPath = fullfile(szPath, 'audio_files');
    cd(szPath)
    szPath_tmp = fullfile(szPath, 'temp');
    if ~exist(szPath_tmp, 'dir')
        mkdir(szPath_tmp)
    end
    % Datatype {iEncoding, fwritePrecission, iBitsPerSample, szCompression, bSupported, szDescription}
    testCase.TestData.stDetails = struct( ...
        'mu',       {1, '',        8,  'u-law',        false}, ...
        'int8',     {2, 'bit8',    8,  'Uncompressed', true},  ...
        'int16',    {3, 'bit16'    16, 'Uncompressed', true},  ...
        'int24',    {4, 'bit24',   24, 'Uncompressed', true},  ...
        'int32',    {5, 'bit32',   32, 'Uncompressed', true},  ...
        'float32',  {6, 'float32', 32, 'Uncompressed', true},  ...
        'float64',  {7, 'float64', 64, 'Uncompressed', true}   ...
        );
    testCase.TestData.szPath_tmp  = szPath_tmp;
    testCase.TestData.szPath      = szPath;
    testCase.TestData.stFiles_all = dir(fullfile(szPath, '*.au'));

end


function teardownOnce(testCase)  % do not change function name
    rmdir(testCase.TestData.szPath_tmp, 's')
end
