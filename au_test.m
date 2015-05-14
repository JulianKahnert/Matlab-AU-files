%AU_TEST Unit-test of metadata of au_info, au_read and au_write.
%
%   To test the integrity of the au_* functions, run:
%       runtests('au_test.m')
%
%   See also: au_info, au_read, au_write.

%--------------------------------------------------------------------------
% This projected is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create                                   05-May-2015 JK
% Ver. 0.02 help update                                      06-May-2015 JK
%--------------------------------------------------------------------------


%% Main function to generate tests
function tests = tester_fun
tests = functiontests(localfunctions);
end


%% INFO-function

function testInfo(testCase)
    for i =1:numel(testCase.TestData.stFiles_all)
        szPath  = fullfile(...
            testCase.TestData.szPath,...
            testCase.TestData.stFiles_all(i).name);
        stInfo1 = au_info(szPath);
        stInfo2 = audioinfo(szPath);

        if ~strcmp(stInfo1.Filename,stInfo2.Filename)
            error('Filename not consistent!')
        end
        if ~strcmp(stInfo1.CompressionMethod,stInfo2.CompressionMethod)
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
        szPath  = fullfile(...
            testCase.TestData.szPath,...
            testCase.TestData.stFiles_all(i).name);
        [y1,fs1] = au_read(szPath);
        [y2,fs2] = audioread(szPath);

        if fs1 ~= fs2 || any(y1(:) ~= y2(:))
            error('Data corrupt!')
        end
    end
end

function testReadInterval1(testCase)
% READ: read data with interval (1)
    vSamples= [2 5];
    for i =1:numel(testCase.TestData.stFiles_all)
        szPath  = fullfile(...
            testCase.TestData.szPath,...
            testCase.TestData.stFiles_all(i).name);
        [y1,fs1] = au_read(szPath,vSamples);
        [y2,fs2] = audioread(szPath,vSamples);
        
        if fs1 ~= fs2 || any(y1(:) ~= y2(:))
            error('Data corrupt!')
        end
    end
end

function testReadInterval2(testCase)
% READ: read data with interval (2)
    vSamples= [3 Inf];
    for i =1:numel(testCase.TestData.stFiles_all)
        szPath  = fullfile(...
            testCase.TestData.szPath,...
            testCase.TestData.stFiles_all(i).name);
        
        [y1,fs1] = au_read(szPath,vSamples);
        [y2,fs2] = audioread(szPath,vSamples);
        
        if fs1 ~= fs2 || any(y1(:) ~= y2(:))
            error('Data corrupt!')
        end
    end
end


%% WRITE-function

function testWrite(testCase)
    %#% SMOTHING IS WRONG HERE!!
    for i =1:numel(testCase.TestData.stFiles_all)
        szPath      = fullfile(...
            testCase.TestData.szPath,...
            testCase.TestData.stFiles_all(i).name);
        szFile_new  = fullfile(testCase.TestData.szPath_tmp,...
            [testCase.TestData.stFiles_all(i).name(1:end-3) '_test.au']);
        % reference file
        [y1,fs1] = audioread(szPath);
        
        % self-generated file
        au_write(szFile_new,y1,fs1)
        if ~exist(szFile_new,'file')
            error('Au-file not written!')
        end
        [y2,fs2] = audioread(szFile_new);
        
        if fs1 ~= fs2 || any(y1(:) ~= y2(:))
            plot(y1 - y2)
            title('Difference between signals: ref - new')
            error('ATTENTION: Saved vectors are not identical!!')
        end
    end
    
end


%% Optional file fixtures

function setupOnce(testCase)  % do not change function name
    clc
    szPath          = fileparts(which('au_test.m'));
    cd(szPath)
    szPath = fileparts(which('au_test.m'));
    szPath = fullfile(szPath,'audio_files');
    cd(szPath)
    szPath_tmp = fullfile(szPath,'temp');
    if ~exist(szPath_tmp,'dir')
        mkdir(szPath_tmp)
    end

    testCase.TestData.szPath_tmp  = szPath_tmp;
    testCase.TestData.szPath      = szPath;
    testCase.TestData.stFiles_all = dir(fullfile(szPath,'*.au'));

end


function teardownOnce(testCase)  % do not change function name
    rmdir(testCase.TestData.szPath_tmp,'s')
end
