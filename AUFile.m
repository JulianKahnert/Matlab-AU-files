classdef AUFile < handle
% AUFILE is a class to access .au-files.
    
%% properties

    properties
        CurSample       = [];       % Current position in au-file.
    end

    properties (SetAccess = private, GetAccess = public)
        Filename        = [];       % Full filepath to au-File(from audioinfo)
        CompressionMethod = [];     % Compression method of data.
        NumChannels     = [];       % Number of channels of data.
        SampleRate      = [];       % Sample rate of data.
        TotalSamples    = [];       % Number of total samples (rows).
        Duration        = [];       % Duration in seconds.
        Title           = [];       % Title of data (empty in au-files).
        Comment         = [];       % Comment of data (empty in au-files).
        Artist          = [];       % Artist of data (empty in au-files).
        BitsPerSample   = [];       % Number, which indicates the bits per sample.
        DataType        = [];       % Type of data (int16, float32, ...).
        eof             = [];       % Boolean, which indicates if the End-Of-File (eof) is reached.
    end
    
    properties (SetAccess = private, Hidden = true )
        fid             = [];
        iEncoding       = [];
        szFormat        = [];
        Permission      = [];
        
        iDataOffset     = [];
        
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

    methods
        function set.CurSample(self, iNewSample)
            seek(self,iNewSample)
            self.CurSample = iNewSample;
        end
        
        function CurSample = get.CurSample(self)
            CurSample = tell(self);
        end
        
        function TotalSamples = get.TotalSamples(self)
            stFile      = dir(self.Filename);
            dataSize    = stFile.bytes - self.iDataOffset;
            TotalSamples= dataSize / (self.BitsPerSample/8) / self.NumChannels;
            
            self.Duration = TotalSamples/self.SampleRate;
        end
        
        function eof = get.eof(self)
            tmp = dir(self.Filename);
            eof = (ftell(self.fid) == tmp.bytes);
        end
    end


    methods (Hidden = false)
   
        function self = AUFile(szFilename, szPermission, varargin)
            %AUFILE     class to read and write .au-files.
            % [OBJ] = AUFILE(FILENAME, PERMISSION, [NUMCHANNELS, FS, DATATYPE]) returns an object
            % with properties which contain information about a specified au-file.
            %
            % FILENAME is a string that specifies the name of the audio file, it can be absolute,
            % relative, or partial. 
            %
            % PERMISSION allows multiple values:
            %   * 'n' or 'new'      : write a new file, discard existing content
            %   * 'r' or 'read'     : read permission
            %   * 'rw'or 'readwrite': read and write permission
            %   * 'a' or 'append'   : read and write permission, seek to eof and append data
            %   * 'x' or 'xnew'     : write a new file, discard existing content and show error if file already exists
            %
            % NUMCHANNELS number of channels (default: 2)
            %
            % FS samplerate (default: 44100)
            %
            % DATATYPE datatype of data (default: 'int16')
            %
            % Usage:
            %   objAU = AUFile('testfile.au', 'read')
            %   objAU = AUFile('testfile.au', 'n', 5, 4800, 'float32')
            
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
            if any(strcmp(szPermission, {'n' 'new'})) || ~exist(self.Filename, 'file')
                self.Permission = 'w+';
                open(self, varargin)
                
            elseif any(strcmp(szPermission, {'r' 'read'}))
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
                seek(self, 1, 'eof');
                
            elseif any(strcmp(szPermission, {'x' 'xnew'}))
                if exist(self.Filename, 'file')
                    error('A file with this name already exists!')
                end
                self.Permission = 'w+';
                open(self, varargin)
                
            else
                error('Permission not found!')
            end
            
            if ~any(strcmp(szPermission, {'a' 'append'}))
                seek(self, 1, 'bof')
            end
        end  
      
        function seek(self, iSample, szOrigin)
            % SEEK  moves the current position to a specified position.
            % [] = seek(SAMPLE[, ORIGIN]) sets the position in the data to
            % SAMPLE, with respect to ORIGIN.
            % If ORIGIN is not specified, it is set to 'bof'.
            %
            % possible values for ORIGIN:
            %   * 'bof' - beginning of data (default)
            %   * 'cof' - current position in data
            %   * 'eof' - end of data
            
            if nargin == 1
                error('Not enough input arguments.');
            end
            if nargin < 3
                szOrigin = 'bof';
            end
            
            iPos = (iSample-1) * (self.BitsPerSample/8) * self.NumChannels;
            if strcmp(szOrigin, 'bof')
                iPos = iPos + self.iDataOffset;
            end
            status = fseek(self.fid, iPos, szOrigin);
            if status == -1
                error('Something went wrong!')
            end
        end
        
        function iSample = tell(self)
            % TELL  returns the current position in the data.
            % SAMPLE = TELL()
            
            iPos    = ftell(self.fid);
            iSample = (iPos - self.iDataOffset) / (self.BitsPerSample/8) / self.NumChannels +1;
        end
        
        function vSignal = read(self, varargin)
            % READ  returns data of the au-file.
            % SIGNAL = READ([NUMBER, ADDVAL]) returns the data from the "current
            % position" to "NUMBER+current position". If NUMBER is not
            % specified, read will return the data from "current position"
            % to the end of data. If ADDVAL also exists, READ will always
            % return a SIGNAL with NUMBER of rows. If the end of data is
            % reached, READ will add values of ADDVAL to achieve a
            % (NUMBER x CHANNELS) matrix.
            
            if length(varargin) == 1 && varargin{1} > self.TotalSamples-self.CurSample+1
                error('Not enough samples to read. Choose less samples!')
            end
            if self.CurSample < 1
                error('Seek to a valid position!')
            end
            
            if isempty(varargin)
                 iNumSamples = self.TotalSamples - self.CurSample +1;
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
            vSignal = reshape(vSignal, self.NumChannels,[]).';
            
            vSize   = size(vSignal);
            if length(varargin) == 2 && vSize(1) < iNumSamples
                iAdd    = varargin{2};
                vSignal = [vSignal; iAdd * ones(iNumSamples-vSize(1), self.NumChannels)];
                warning('Attention: values added!')
            end
            
        end
        
        function vSignal = readall(self)
            % READALL   returns the data of the whole au-file.
            % SIGNAL = READALL()
            
            seek(self, 1, 'bof');
            vSignal = read(self);
        end
        
        function write(self, data)
            % WRITE     (over)writes or appends data to an au-file.
            % WRITE(DATA) writes DATA from "current position" to "current
            % position + size(DATA,1)". If the end of data is reached,
            % samples will be added to the au-file.
            % The following commands will append data to an au-file:
            % obj.seek(0,'eof');
            % obj.write(DATA);
            
            if any(strcmp(self.Permission, {'r' 'read'}))
                error('Wrong permission for writing!')
            end
            if self.CurSample < 1
                error('Seek to a valid position!')
            end
            [~, iCol] = size(data);
            if iCol ~= self.NumChannels
                error('Number of channels mismatch')
            end
            
            % for a higher speed
            if self.NumChannels > 1,
                data = reshape(data', self.NumChannels * size(data, 1), 1);
            end
            % write data
            if strcmp(self.DataType(1:2),'in')  % case of int*
                data = round(data*2^(self.BitsPerSample-1));
                fwrite(self.fid, data, self.szFormat);
                
            else                                % case of float*
                fwrite(self.fid, data, self.szFormat);
                
            end
        end
        
    end
    
    methods (Hidden = true)
               
        function open(self, caArgin)%(self, iNumChannels, fs, szDatatype)
            % check if file exists (before open)
            bExist = exist(self.Filename, 'file');
            
            % open file
            self.fid = fopen(self.Filename, self.Permission, 'b');
            if self.fid == -1
                error('Can not open file.')
            end
            
            if bExist && ~strcmp(self.Permission, 'w+')
                readHeader(self);
                
            else
                if strcmp(self.Permission, 'r')
                    error('Wrong permission, because file does not exist!')
                end
                
                if isempty(caArgin) || isempty(caArgin{1})
                    self.NumChannels = 2;
                    fprintf('\t==> chosen default number of channels: %i\n', self.NumChannels)
                else
                    self.NumChannels = caArgin{1};
                end
                
                if length(caArgin) < 2
                    self.SampleRate = 44100;
                    fprintf('\t==> chosen default sample rate: %i Hz\n', self.SampleRate)
                else
                    self.SampleRate = caArgin{2};
                end
                
                if length(caArgin) < 3
                    self.DataType = 'int16';
                    fprintf('\t==> chosen default datatype: %s\n', self.DataType)
                else
                    self.DataType = caArgin{3};
                end
                
                self.iDataOffset = 24;
                writeHeader(self);
            end
            
            % write properties
            self.iEncoding          = self.stDetails(1).(self.DataType);
            self.szFormat           = self.stDetails(2).(self.DataType);
            self.BitsPerSample      = self.stDetails(3).(self.DataType);
            self.CompressionMethod  = self.stDetails(4).(self.DataType);
            
        end
   
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
            seek(self,1)
        end
        
    end
    
       
%% methods from superclass (handle)

    methods ( Hidden = true)
        function addlistener(self),end;
        function eq(self),end;
        function findobj(self),end;
        function findprop(self),end;
        function ge(self),end;
        function gt(self),end;
%         function isvalid(self),end;
        function le(self),end;
        function lt(self),end;
        function ne(self),end;
        function notify(self),end;
    end
    
end