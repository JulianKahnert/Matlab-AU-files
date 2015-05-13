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
        keyboard
        au_write(szFile_new,y1,fs1)
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
    szPath_tmp      = 'temp';
    if ~exist(szPath_tmp,'dir')
        mkdir(szPath_tmp)
    end

    szPath = fileparts(which('au_test.m'));
    szPath = fullfile(szPath,'audio_files');
    cd(szPath)


    testCase.TestData.szPath_tmp  = szPath_tmp;
    testCase.TestData.szPath      = szPath;
    testCase.TestData.stFiles_all = dir(fullfile(szPath,'*.au'));

end


function teardownOnce(testCase)  % do not change function name
keyboard
    rmdir(testCase.TestData.szPath_tmp,'s')
end
%
% %% Optional fresh fixtures
% function setup(testCase)  % do not change function name
% % open a figure, for example
% keyboard
% end
%
% function teardown(testCase)  % do not change function name
% % close figure, for example
% end