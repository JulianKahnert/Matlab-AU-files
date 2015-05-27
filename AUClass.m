classdef AUClass < handle
    
    properties (SetAccess = protected, GetAccess = public)
        
        % fields from audioinfo
        Filename            = '';
        CompressionMethod   = '';
        NumChannels         = [];
        SampleRate          = [];
        TotalSamples        = [];
        Duration            = [];
        Title               = '';
        Comment             = '';
        Artist              = '';
        BitsPerSample       = [];
        
        % au specific
        Datatype            = '';
        
    end
    
    properties ( Access = private )
        
        fid         = [];
        szFilename  = [];
        DataSize    = [];
        DataOffset  = [];
        
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
    
    
    
    
    methods ( Access = public)
        
        function self = AUClass(szFilename)
            
            [szPath, szName, szExt]= fileparts(szFilename);
            if isempty(szExt) || ~strcmp(szExt, '.au')
                szFilename = fullfile(szPath, [szName '.au']);
            end
            
            
            
            
            
            if ~exist(szFilename,'file')
                disp('CREATING NEW FILE!') %#%                
                self.fid = fopen(szFilename, 'w', 'b');
                
            else
                self.fid = fopen(szFilename, 'r+', 'b');
                self.readHeader();
                
            end
            
            % error check: fopen
            if self.fid == -1
                error('Can not read/create file. Is the path correct?')
            end
            
            %#% returns the absolute path, when fopen has 'r+'
            self.Filename = fopen(self.fid);
            
            
        end
    end
    
    
    
    methods ( Access = private)
        
        function writeData(self, data, vRange, szDatatype)
            % default input settings
            szEncoding_default  = 'int16';
            vRange_default   = [1 Inf];
            if nargin < 3 || isempty(vRange)
                vRange = vRange_default;
            end
            if nargin < 4 || isempty(szDatatype)
                szDatatype = szEncoding_default;
            end
            
            b1 = vRange(2)-vRange(1)+1 ~= size(data, 1);
            b2 = any(vRange <= 0);
            b3 = vRange(1) > vRange(2);
            if ~any(vRange == Inf) && (b1 || b2 || b3)
                error('Input arguments data and range not consistent.')
            end
            
            iEncoding       = self.stDetails(1).(szDatatype);
            szFormat        = self.stDetails(2).(szDatatype);
            iBitsPerSample  = self.stDetails(3).(szDatatype);
            
            if ~exist(self.szPath,'file') || all(vRange == vRange_default)
                self.DataOffset     = 24;
                self.DataSize       = 0;
%                 writeHeader(szFilename, iDataOffset, iEncoding, fs, iNumChannels)
                self.writeHeader(iEncoding);
                
            end
            
            
            %% open & write
            
            % for a higher speed
            if self.NumChannels > 1,
                data = reshape(data', self.NumChannels * size(data, 1), 1);
            end
                       
            if all(vRange == vRange_default)    % case: new file
                iOffset = self.DataOffset;
                
            elseif vRange(1) == Inf             % case: append data
                iOffset = self.DataOffset + self.DataSize;
                
            else                                % case: write interval
                iOffset = self.DataOffset + (vRange(1)-1)*iBitsPerSample/8*self.NumChannels;
                
            end
            
            % jump to offset
            fseek(self.fid,iOffset,'bof');
            
            % write data
            if strcmp(szDatatype(1:2),'in') % case of int*
                fwrite(self.fid, data*2^(iBitsPerSample-1), szFormat);
                
            else                            % case of float*
                fwrite(self.fid, data, szFormat);
                
            end
        end
        
        
        function writeHeader(self, iEncoding)
            fwrite(self.fid, int32('.snd'),     'uchar');  % 0 magic number
            fwrite(self.fid, self.DataOffset,   'uint32'); % 1 data offset
            fwrite(self.fid, intmax('uint32'),  'uint32'); % 2 data size
            fwrite(self.fid, iEncoding,         'uint32'); % 3 encoding
            fwrite(self.fid, self.SampleRate,   'uint32'); % 4 sample rate
            fwrite(self.fid, self.NumChannels,  'uint32'); % 5 channels
        end
        
        
        function readHeader(self)
            magicnumber = fread(self.fid, 4, 'uint8', 0, 'b');
            if ~all(magicnumber' == uint8('.snd'))
                fclose(self.fid);
                error('Header of the file corrupt. Is it a au-file?')
            end
            self.DataOffset = fread(self.fid, 1, 'uint32', 0, 'b');
            iDataSize       = fread(self.fid, 1, 'uint32', 0, 'b');      %#ok overwrite later
            iEncoding       = fread(self.fid, 1, 'uint32', 0, 'b');
            iSampleRate     = fread(self.fid, 1, 'uint32', 0, 'b');
            iChannels       = fread(self.fid, 1, 'uint32', 0, 'b');
            
            % write info struct
            szDatatype  = fieldnames(self.stDetails);
            szDatatype  = szDatatype{iEncoding};
            iBitsPerSample = self.stDetails(3).(szDatatype);
            
            self.CompressionMethod  =  self.stDetails(4).(szDatatype);
            self.NumChannels        = iChannels;
            self.SampleRate         = iSampleRate;
            self.TotalSamples       = self.DataSize*8 / iBitsPerSample / iChannels;
            self.Duration           = self.DataSize*8 / iBitsPerSample / iSampleRate / iChannels;
            % self.Title              = [];
            % self.Comment            = [];
            % self.Artist             = [];
            self.BitsPerSample      = iBitsPerSample;
            self.Datatype           = szDatatype;
        end
        
        
        
        function delete(self)
            
            fclose(self.fid);
            if self.DataSize == 0
                delete(self.Filename)
                keyboard
            end
            disp('DESTRUCTOR CALLED!!') %#%
            
        end
        
    end
    
    
    
    
end