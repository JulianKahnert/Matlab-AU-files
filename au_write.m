function au_write(szFilename, data, fs, vRange, szDatatype)
%AU_WRITE Write data in an au-file.
%   AU_WRITE(FILENAME, DATA, FS) writes the audio data in DATA with a given
%   FS in a au-file, which was specified by the string FILENAME. If a
%   au-file with FILENAME already exists, it will be overwritten.

%   AU_WRITE(FILENAME, DATA, FS, [START END]) writes the DATA in the
%   interval START through END for each channel in the file. If you set
%   START to Inf, AU_WRITE will append DATA on an existing au-file.
%   Furthermore AU_WRITE will overwrite all existing samples if: 
%       [START END] = [1 Inf], or
%       [START END] = []
%
%   AU_WRITE(FILENAME, DATA, FS, [START END], DATATYPE) writes a au-file
%   with a specified DATATYPE. Valid strings are mu, int8, int16, int24,
%   int32, float32 or float64.
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
% This project is licensed under the terms of the MIT license.
%--------------------------------------------------------------------------
% Author: Julian Kahnert (c) TGM @ Jade Hochschule
% Version History:
% Ver. 0.1.0 initial create                                  29-Apr-2015 JK
% Ver. 0.2.0 help update                                     06-May-2015 JK
% Ver. 0.3.0 first mayor release                             19-May-2015 JK
% Ver. 0.4.0 blockwise writing                               21-May-2015 JK
%--------------------------------------------------------------------------


%% input check

% defaul input settings
szEncoding_default  = 'int16';
vRange_default   = [1 Inf];
if nargin < 4 || isempty(vRange)
    vRange = vRange_default;
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

b1 = vRange(2)-vRange(1)+1 ~= size(data, 1);
b2 = any(vRange <= 0);
b3 = vRange(1) > vRange(2);
if ~any(vRange == Inf) && (b1 || b2 || b3)
    error('Input arguments data and range not consistent.')
end

[szPath, szName, szExt]= fileparts(szFilename);
if isempty(szExt) || ~strcmp(szExt, '.au')
    szFilename = fullfile(szPath, [szName '.au']);
end

iEncoding       = stDetails(1).(szDatatype);
szFormat        = stDetails(2).(szDatatype);
iBitsPerSample  = stDetails(3).(szDatatype);

if ~exist(szFilename,'file') || all(vRange == vRange_default)
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

if all(vRange == vRange_default)    % case: new file
    iOffset = iDataOffset;
    
elseif vRange(1) == Inf             % case: append data
    iOffset = iDataOffset + iDataSize;
    
else                                % case: write interval
    iOffset = iDataOffset + (vRange(1)-1)*iBitsPerSample/8*iNumChannels;
    
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
