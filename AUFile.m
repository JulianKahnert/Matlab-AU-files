classdef AUFile < handle
    
    
%% properties
    
    properties (SetAccess = protected, GetAccess = public)
        
        % fields from audioinfo
        Filename        = [];
        CompressionMethod = [];
        NumChannels     = [];
        SampleRate      = [];
        TotalSamples    = [];
        Duration        = [];
        Title           = [];
        Comment         = [];
        Artist          = [];
        BitsPerSample   = [];
        
        % au specific
        DataType        = [];
        
        CurSample       = [];
    end

    properties (SetAccess = protected, GetAccess = public, Hidden)
        iDataOffset     = [];
    end
    
    properties ( Access = private )
        
        fid             = [];
        iEncoding       = [];
        szFormat        = [];
        Permission    = [];
        
        % DataType {iEncoding, fwritePrecission, iBitsPerSample, szCompression, bSupported, szDescription}
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
   
        function self = AUFile(szFilename, szPermission, varargin)
            % generating full path
            [szPath, ~, szExt] = fileparts(szFilename);
            if ~strcmp(szExt, '.au')
                error('Please choose a au-file!')
            end
            if isempty(szPath)
                self.Filename = fullfile(pwd,szFilename);
            else
                self.Filename = szFilename;
            end
            
            % permission parsing
            if any(strcmp(szPermission, {'r' 'read'}))
                self.Permission = 'r';
                open(self, varargin)
                
            elseif any(strcmp(szPermission, {'rw' 'readwrite'}))
                self.Permission = 'r+';
                open(self, varargin)
                changeDataSize(self);
                
            elseif any(strcmp(szPermission, {'a' 'append'}))
                self.Permission = 'r+';
                open(self, varargin)
                changeDataSize(self);
                seek(self, 1);
                
            elseif any(strcmp(szPermission, {'n' 'new'}))
                self.Permission = 'w+';
                open(self, varargin)
                
            elseif any(strcmp(szPermission, {'x' 'xnew'}))
                self.Permission = 'w+';
                open(self, varargin)
                
            else
                error('Permission not found!')
            end
            
            
            % write properties
            
            fseek(self.fid, self.iDataOffset, 'bof');
            self.CurSample         = 1;
                        
            % get file size
            stFile = dir(self.Filename);
            dataSize = stFile.bytes - self.iDataOffset;
            
            self.iEncoding          = self.stDetails(1).(self.DataType);
            self.szFormat           = self.stDetails(2).(self.DataType);
            self.BitsPerSample      = self.stDetails(3).(self.DataType);
            self.CompressionMethod  = self.stDetails(4).(self.DataType);
            
            self.TotalSamples       = dataSize / (self.BitsPerSample/8) / self.NumChannels;
            self.Duration           = self.TotalSamples/self.SampleRate;
            
        end  
        
        function open(self, varargin)%(self, iNumChannels, fs, szDatatype)
            
            self.fid = fopen(self.Filename, self.Permission, 'b');
            if self.fid == -1
                error('Can not open file.')
            end
            
            if exist(self.Filename, 'file') && ~any(strcmp(self.Permission, {'n' 'new' 'x' 'xnew'}))
                readHeader(self);
                
            else
                if strcmp(self.Permission, {'r' 'read'})
                    error('Wrong permission, because file does not exist!')
                end
                
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
                    self.DataType = 'int16';
                    fprintf('\t==> chosen default datatype: %s\n', self.DataType)
                else
                    self.DataType = varargin{3};
                end
                
                self.iDataOffset = 24;
                writeHeader(self);
            end
            
        end
        
        function seek(self, iSample, szOrigin)
            if nargin < 3
                szOrigin = 'bof';
            end
            
            if iSample < 0
                iSample = 0;
            end
            
            iPos = (iSample-1) * (self.BitsPerSample/8) * self.NumChannels;
            if strcmp(szOrigin, 'bof')
                iPos = iPos + self.iDataOffset;
            end
            status = fseek(self.fid, iPos, szOrigin);
            if status == -1
                error('Something went wrong!')
            end
            tell(self); %#% better with setter/getter functions
        end
        
        function iSample = tell(self)
            iPos    = ftell(self.fid);
            iSample = (iPos - self.iDataOffset) / (self.BitsPerSample/8) / self.NumChannels +1;
            self.CurSample = iSample;
        end
        
        function vSignal = read(self, varargin)
            if ~isempty(varargin) && varargin{1} > self.TotalSamples-self.CurSample+1
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
            if strcmp(self.DataType(1:2), 'in')
                vSignal = vSignal/2^(self.BitsPerSample-1);
            end
            vSignal         = reshape(vSignal, self.NumChannels,[]).';
            self.CurSample = self.CurSample+iNumSamples;
            
        end
        
        function write(self, data)
            if any(strcmp(self.Permission, {'r' 'read'}))
                error('Wrong permission for writing!')
            end
            [iRow, iCol] = size(data);
            if iCol ~= self.NumChannels
                error('Number of channels mismatch')
            end
            
            % write data
            if strcmp(self.DataType(1:2),'in') % case of int*
                data = round(data*2^(self.BitsPerSample-1));
                fwrite(self.fid, data, self.szFormat);
                
            else                            % case of float*
                fwrite(self.fid, data, self.szFormat);
                
            end
            
            if self.TotalSamples == self.CurSample-1
                self.TotalSamples   = self.TotalSamples + iRow;
                self.Duration       = self.TotalSamples/self.SampleRate;
            end
            self.CurSample = self.CurSample + iRow;
        end
        
    end
    
    methods ( Access = private)
        
        function delete(self)
            fclose(self.fid);
        end
        
        function writeHeader(self)
            fwrite(self.fid, int32('.snd'),     'uchar');  % 0 magic number
            fwrite(self.fid, self.iDataOffset,  'uint32'); % 1 data offset
            fwrite(self.fid, intmax('uint32'),  'uint32'); % 2 data size
            fwrite(self.fid, self.stDetails(1).(self.DataType), 'uint32'); % 3 encoding
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
            
            caDatatypes     = fieldnames(self.stDetails);
            temp            = struct2cell(self.stDetails(1));
            self.DataType   = caDatatypes{ [temp{:}] == encoding};
            
        end
        
        function changeDataSize(self)
            % change datasize to unkown value
            fseek(self.fid, 8, 'bof');
            fwrite(self.fid, intmax('uint32'), 'uint32'); % 2 data size
        end
        
        function getNumSamples(self)
            stFile  = dir(self.Filename);
            dataSize= stFile.bytes - dataOffset;
            iNumSamples = dataSize / (self.stDetails(3).(szDatatype)/8) / iNumChannels;
        end
    end
    
    
end