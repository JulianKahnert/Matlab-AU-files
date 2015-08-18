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
            
            
%             if ~exist(szFilename,'file')
%                 disp('CREATING NEW FILE!') %#%                
%                 self.fid = fopen(szFilename, 'w', 'b');
%                 
%             else
%                 self.fid = fopen(szFilename, 'r+', 'b');
%                 self.readHeader();
%                 
%             end
%             
%             % error check: fopen
%             if self.fid == -1
%                 error('Can not read/create file. Is the path correct?')
%             end
%             
%             %#% returns the absolute path, when fopen has 'r+'
%             self.Filename = fopen(self.fid);
            
        end
        
        
        function open(self)
        end
        function close(self)
        end
        
        function seek(self)
        end
        
        function read(self)
        end
        function write(self)
        end
        
        
    end
    
    
    
    methods ( Access = private)
        
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