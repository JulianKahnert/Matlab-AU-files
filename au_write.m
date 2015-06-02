function au_write(szFilename, data, fs, iStart, szDatatype)
%AU_WRITE Write data in an au-file.
%   AU_WRITE(FILENAME, DATA, FS) writes the audio data in DATA with a given
%   FS in a au-file, which was specified by the string FILENAME. If a
%   au-file with FILENAME already exists, it will be overwritten.

%   AU_WRITE(FILENAME, DATA, FS, START) writes the DATA in theinterval
%   START through START+size(DATA,1) for each channel in the file. If you
%   set START to Inf, AU_WRITE will append DATA on an existing au-file.
%   Furthermore AU_WRITE will overwrite all existing samples if START is
%   not specified or START = [].
%
%   AU_WRITE(FILENAME, DATA, FS, START, DATATYPE) writes a au-file
%   with a specified DATATYPE. Valid strings are int8, int16, int24,
%   int32, float32 or float64.
%
%   Usage:
%       au_write('testfile.au', rand(10*44100, 2)-.5)
%       au_write('testfile.au', .9*ones(5,2), 44100, 3)
%       au_write('testfile.au', rand(10*44100, 2)-.5, 44100, 3, 'int32')
%       au_write('testfile.au', rand(10*44100, 2)-.5, 44100, 3, 'float64')
%
%   Output Data Ranges
%   DATA should be a m-by-n matrix, where m is the number of audio samples
%   read and n is the number of audio channels in the file.
%
%   Note:
%   * If datatype is a kind if int, samples >1 or <(-1) will be clipped.
%   * END automatically set: END = START+size(DATA,1)
%
%   See also: au_info, au_write, audioinfo, audioread, audiowrite

%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule
% This project is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------


%% input check

% defaul input settings
szEncoding_default  = 'int16';
if nargin < 4
    iStart = [];
end
if nargin < 5 || isempty(szDatatype)
    szDatatype = szEncoding_default;
end

% Datatype {iEncoding, fwritePrecission, iBitsPerSample, szCompression, bSupported, szDescription}
stDetails = struct( ...
    'mu',       {1, '',        8,  'u-law',        false}, ...
    'int8',     {2, 'bit8',    8,  'Uncompressed', true},  ...
    'int16',    {3, 'bit16'    16, 'Uncompressed', true},  ...
    'int24',    {4, 'bit24',   24, 'Uncompressed', true},  ...
    'int32',    {5, 'bit32',   32, 'Uncompressed', true},  ...
    'float32',  {6, 'float32', 32, 'Uncompressed', true},  ...
    'float64',  {7, 'float64', 64, 'Uncompressed', true}   ...
    );

b1 = any(iStart <= 0);
b2 = numel(iStart) ~= 1;
if ~isempty(iStart) && (b1 || b2)
    error('Check your input arguments!')
end

[szPath, szName, szExt]= fileparts(szFilename);
if isempty(szExt) || ~strcmp(szExt, '.au')
    szFilename = fullfile(szPath, [szName '.au']);
end

iEncoding       = stDetails(1).(szDatatype);
szFormat        = stDetails(2).(szDatatype);
iBitsPerSample  = stDetails(3).(szDatatype);

if ~exist(szFilename,'file') || isempty(iStart)
    iNumChannels    = size(data, 2);
    iDataOffset     = 24;
    iDataSize       = 0;
    writeHeader(szFilename, iDataOffset, iEncoding, fs, iNumChannels)
    
else
    [stInfo, iDataOffset, iDataSize] = au_info(szFilename);
    iNumChannels= stInfo.NumChannels;
    
end


%% open & write

% for a higher speed
if iNumChannels > 1,
    data = reshape(data', iNumChannels * size(data, 1), 1);
end

% open a file
fid = fopen(szFilename, 'r+', 'b');

if isempty(iStart)                  % case: new file
    iOffset = iDataOffset;
    
elseif iStart == Inf                % case: append data
    iOffset = iDataOffset + iDataSize;
    
else                                % case: write interval
    iOffset = iDataOffset + (iStart-1)*iBitsPerSample/8*iNumChannels;
    
end

% jump to offset
fseek(fid,iOffset,'bof');

% write data
if strcmp(szDatatype(1:2),'in') % case of int*
    fwrite(fid, data*2^(iBitsPerSample-1), szFormat);
    
else                            % case of float*
    fwrite(fid, data, szFormat);
    
end
fclose(fid);


%% helper functions

    function writeHeader(szFilename, iDataOffset, iEncoding, fs, iNumChannels)
        % write header, if file does not exist
        fid_header  = fopen(szFilename, 'w', 'b');
        if fid_header == -1
            error('Can not open file.')
        end
        fwrite(fid_header, int32('.snd'),    'uchar');  % 0 magic number
        fwrite(fid_header, iDataOffset,      'uint32'); % 1 data offset
        fwrite(fid_header, intmax('uint32'), 'uint32'); % 2 data size
        fwrite(fid_header, iEncoding,        'uint32'); % 3 encoding
        fwrite(fid_header, fs,               'uint32'); % 4 sample rate
        fwrite(fid_header, iNumChannels,     'uint32'); % 5 channels
        fclose(fid_header);
    end

end
