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

    properties ( Access = private )
        
        fid         = [];
        szFullPath  = [];
        iDataOffset = [];
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
            self.szFullPath     = szFilename; %#% not the full path in every case!!
            [~, self.Filename]  = fileparts(szFilename);
            
%             % get full path
%             fid_tmp     = fopen(szFilename, 'r');
%             self.szFullPath  = fopen(fid_tmp);
%             fclose(fid_tmp);
%             
%             [szPath, szName, szExt]= fileparts(self.szFullPath);
%             if isempty(szExt) || ~strcmp(szExt, '.au')
%                 self.szFullPath = fullfile(szPath, [szName '.au']);
%             end
%             
%             disp(self.szFullPath)
%             keyboard

        end  
        
        function open(self, szPermission, iNumChannels, fs, szDatatype)
            if exist(self.szFullPath, 'file')
                switch szPermission
                    case 'read'
                        self.fid = fopen(self.szFullPath, 'r', 'b');
                    case 'write'
                        self.fid = fopen(self.szFullPath, 'r+', 'b');
                end
                if self.fid == -1
                    error('Can not open file.')
                end
                
                % read header
                magicnumber = fread(self.fid, 4, 'uint8', 0, 'b');
                if ~all(magicnumber' == uint8('.snd'))
                    error('Header of the file corrupt. Is it a au-file?')
                end
                dataOffset  = fread(self.fid, 1, 'uint32', 0, 'b');
                dataSize    = fread(self.fid, 1, 'uint32', 0, 'b');
                encoding    = fread(self.fid, 1, 'uint32', 0, 'b');
                fs          = fread(self.fid, 1, 'uint32', 0, 'b');
                iNumChannels= fread(self.fid, 1, 'uint32', 0, 'b');
                
                % change datasize to unkown value
                if strcmp(szPermission, 'write') && dataSize ~= intmax('uint32')
                    fseek(self.fid, 8, 'bof');
                    fwrite(self.fid, intmax('uint32'), 'uint32'); % 2 data size
                end
                
                caDatatypes = fieldnames(self.stDetails);
                temp        = struct2cell(self.stDetails(1));
                szDatatype  = caDatatypes{ [temp{:}] == encoding};
                
                % get file size
                stFile = dir(self.szFullPath);
                dataSize = stFile.bytes - dataOffset;
                iNumSamples = dataSize / (self.stDetails(3).(szDatatype)/8) / iNumChannels;
                
            else
                if strcmp(szPermission, 'read')
                    error('Wrong permission for creating a new file.')
                end
                
                if nargin < 3
                    iNumChannels = 2;
                    fprintf('\t==> chosen default number of channels: 2\n')
                end
                if nargin < 4
                    fs = 44100;
                    fprintf('\t==> chosen default sample rate: 44100 Hz\n')
                end
                if nargin < 5
                    szDatatype = 'int16';
                    fprintf('\t==> chosen default datatype: int16\n')
                end
                
                iNumSamples   = 0;
                dataOffset = 24;
                
                % write header
                self.fid  = fopen(self.szFullPath, 'w+', 'b');
                if self.fid == -1
                    error('Can not open file.')
                end
                fwrite(self.fid, int32('.snd'),     'uchar');  % 0 magic number
                fwrite(self.fid, dataOffset,       'uint32'); % 1 data offset
                fwrite(self.fid, intmax('uint32'),  'uint32'); % 2 data size
                fwrite(self.fid, self.stDetails(1).(szDatatype),    'uint32'); % 3 encoding
                fwrite(self.fid, fs,                'uint32'); % 4 sample rate
                fwrite(self.fid, iNumChannels,      'uint32'); % 5 channels
            end
            
            fseek(self.fid, dataOffset, 'bof');
            
            % write properties
            self.NumChannels    = iNumChannels;
            self.SampleRate     = fs;
            self.TotalSamples   = iNumSamples;
            self.Duration       = iNumSamples/fs;
            self.BitsPerSample  = self.stDetails(3).(szDatatype);
            self.Datatype       = szDatatype;
            
            self.iDataOffset    = dataOffset;
            self.iEncoding      = self.stDetails(1).(szDatatype);
            self.szFormat       = self.stDetails(2).(szDatatype);
            
            self.iCurSample     = 1;
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
        
        function vSignal = read(self, iNumSamples)
            if iNumSamples == Inf
                seek(self,1)
                iNumSamples = self.TotalSamples;
            end
            if iNumSamples > self.TotalSamples-self.iCurSample+1
                error('Not enough samples to read. Chose less samples!')
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
                self.TotalSamples = self.TotalSamples + iRow;
            end
            self.iCurSample = self.iCurSample + iRow;
        end
        
    end
    
    
    methods ( Access = private)
        function delete(self)
            close(self)
            disp('DESTRUCTOR CALLED!!') %#%
        end
        
    end
    
    
end