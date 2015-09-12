classdef AUClass < handle

    
%% properties  
    
    properties (SetAccess = protected, GetAccess = public)
        
        % fields from audioinfo
        Filename            = [];
        CompressionMethod   = [];
        NumChannels         = [];
        SampleRate          = [];
        TotalSamples        = [];
        Duration            = [];
        Title               = [];
        Comment             = [];
        Artist              = [];
        BitsPerSample       = [];
        
        % au specific
        Datatype            = [];
        
        iCurSample          = [];
    end

    
    properties (SetAccess = protected, GetAccess = public, Hidden)
        iDataOffset = [];
    end
    
    
    properties ( Access = private )
        
        fid         = [];
        iEncoding   = [];
        szFormat    = [];
        
        % Datatype {iEncoding, fwritePrecission, iBitsPerSample, szCompression, bSupported, szDescription}
        stDetails   = struct( ...
            'mu',       {1, '',        8,  'u-law',        false}, ...
            'int8',     {2, 'bit8',    8,  'Uncompressed', true},  ...
            'int16',    {3, 'bit16'    16, 'Uncompressed', true},  ...
            'int24',    {4, 'bit24',   24, 'Uncompressed', true},  ...
            'int32',    {5, 'bit32',   32, 'Uncompressed', true},  ...
            'float32',  {6, 'float32', 32, 'Uncompressed', true},  ...
            'float64',  {7, 'float64', 64, 'Uncompressed', true}   ...
            );    
    end
    
    
%% methods
    
    methods ( Access = public)
        
        function self = AUClass(szFilename)
            [szPath, ~, szExt] = fileparts(szFilename);
            if ~strcmp(szExt, '.au')
                error('Please choose a au-file!')
            end
            
            if isempty(szPath)
                self.Filename = fullfile(pwd,szFilename);
            else
                self.Filename = szFilename;
            end
        end  
        
        function open(self, szPermission, varargin)%(self, szPermission, iNumChannels, fs, szDatatype)
            % CASE: read
            if strcmp(szPermission, 'read')
                    self.fid = fopen(self.Filename, 'r', 'b');
                    if self.fid == -1
                        error('Can not open file.')
                    end
                    readHeader(self);
                    
            elseif strcmp(szPermission(1:5), 'write')
                % CASE: write
                if exist(self.Filename, 'file') && strcmp(szPermission, 'write')
                    self.fid = fopen(self.Filename, 'r+', 'b');
                    if self.fid == -1
                        error('Can not open file.')
                    end
                    readHeader(self);
                    
                    % change datasize to unkown value
                    fseek(self.fid, 8, 'bof');
                    fwrite(self.fid, intmax('uint32'), 'uint32'); % 2 data size

                % CASE: writenew
                else
                    if isempty(varargin)
                        self.NumChannels = 2;
                        fprintf('\t==> chosen default number of channels: %i\n', self.NumChannels)
                    else
                        self.NumChannels = varargin{1};
                    end
                    
                    if length(varargin) < 2
                        self.SampleRate = 44100;
                        fprintf('\t==> chosen default sample rate: %i Hz\n', self.SampleRate)
                    else
                        self.SampleRate = varargin{2};
                    end
                    
                    if length(varargin) < 3
                        self.Datatype = 'int16';
                        fprintf('\t==> chosen default datatype: %s\n', self.Datatype)
                    else
                        self.Datatype = varargin{3};
                    end
                    
                    self.iDataOffset = 24;
                    
                    self.fid = fopen(self.Filename, 'w+', 'b');
                    if self.fid == -1
                        error('Can not open file.')
                    end
                    writeHeader(self);
                end
                
            else
                error('Permission unkown!')
            end
            
            % get file size
            stFile = dir(self.Filename);
            dataSize = stFile.bytes - self.iDataOffset;
            
            % write properties
            self.iEncoding          = self.stDetails(1).(self.Datatype);
            self.szFormat           = self.stDetails(2).(self.Datatype);
            self.BitsPerSample      = self.stDetails(3).(self.Datatype);
            self.CompressionMethod  = self.stDetails(4).(self.Datatype);
            
            self.TotalSamples       = dataSize / (self.BitsPerSample/8) / self.NumChannels;
            self.Duration           = self.TotalSamples/self.SampleRate;
            
            fseek(self.fid, self.iDataOffset, 'bof');
            self.iCurSample         = 1;
        end
        
        function close(self)
            fclose(self.fid);
        end
        
        function seek(self, iSample)
            if iSample <= 0
                iSample = 1;
            end
            
            if iSample == Inf
                fseek(self.fid, 0, 'eof');
                self.iCurSample = self.TotalSamples;
            else
                iOffset = self.iDataOffset + ...
                    (iSample-1) * self.BitsPerSample/8 * self.NumChannels;
                fseek(self.fid, iOffset, 'bof');
                self.iCurSample = iSample;
            end
            
        end
        
        function vSignal = read(self, varargin)
            if ~isempty(varargin) && varargin{1} > self.TotalSamples-self.iCurSample+1
                error('Not enough samples to read. Choose less samples!')
            end
            
            if isempty(varargin)
                seek(self,1)
                iNumSamples = self.TotalSamples;
            else 
                iNumSamples = varargin{1};
            end
            
            
            % define length of the desired interval and read the samples
            iNum_smp= iNumSamples * self.NumChannels;
            vSignal = fread(self.fid, iNum_smp, self.szFormat, 0, 'b');

            % normalization in case of int*
            if strcmp(self.Datatype(1:2), 'in')
                vSignal = vSignal/2^(self.BitsPerSample-1);
            end
            vSignal         = reshape(vSignal, self.NumChannels,[]).';
            self.iCurSample = self.iCurSample+iNumSamples;
            
        end
        
        function write(self, data)
            [iRow, iCol] = size(data);
            if iCol ~= self.NumChannels
                error('Number of channels mismatch')
            end
            
            % write data
            if strcmp(self.Datatype(1:2),'in') % case of int*
                data = round(data*2^(self.BitsPerSample-1));
                fwrite(self.fid, data, self.szFormat);
                
            else                            % case of float*
                fwrite(self.fid, data, self.szFormat);
                
            end
            
            if self.TotalSamples == self.iCurSample-1
                self.TotalSamples   = self.TotalSamples + iRow;
                self.Duration       = self.TotalSamples/self.SampleRate;
            end
            self.iCurSample = self.iCurSample + iRow;
        end
        
    end
    
    
    methods ( Access = private)
        function delete(self)
            close(self)
        end
        
        function writeHeader(self)
            fwrite(self.fid, int32('.snd'),     'uchar');  % 0 magic number
            fwrite(self.fid, self.iDataOffset,  'uint32'); % 1 data offset
            fwrite(self.fid, intmax('uint32'),  'uint32'); % 2 data size
            fwrite(self.fid, self.stDetails(1).(self.Datatype), 'uint32'); % 3 encoding
            fwrite(self.fid, self.SampleRate,   'uint32'); % 4 sample rate
            fwrite(self.fid, self.NumChannels,  'uint32'); % 5 channels 
        end
        
        function readHeader(self)
            magicnumber = fread(self.fid, 4, 'uint8', 0, 'b');
            if ~all(magicnumber' == uint8('.snd'))
                error('Header of the file corrupt. Is it a au-file?')
            end
            self.iDataOffset    = fread(self.fid, 1, 'uint32', 0, 'b');
            dataSize            = fread(self.fid, 1, 'uint32', 0, 'b'); %#ok not needed
            encoding            = fread(self.fid, 1, 'uint32', 0, 'b');
            self.SampleRate     = fread(self.fid, 1, 'uint32', 0, 'b');
            self.NumChannels    = fread(self.fid, 1, 'uint32', 0, 'b');
            
            caDatatypes = fieldnames(self.stDetails);
            temp        = struct2cell(self.stDetails(1));
            szDatatype  = caDatatypes{ [temp{:}] == encoding};
            
            self.Datatype       = szDatatype;
            
        end
        
        function getNumSamples(self)
            stFile  = dir(self.Filename);
            dataSize= stFile.bytes - dataOffset;
            iNumSamples = dataSize / (self.stDetails(3).(szDatatype)/8) / iNumChannels;
        end
    end
    
    
end