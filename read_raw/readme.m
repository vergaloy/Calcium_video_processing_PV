% RAW Camera File reader and info functions.
% 
% I.  Background
% --------------
% 
% These functions will read raw images from many digital cameras into
% MATLAB. The reader function, READRAWC, is a C MEX-file implementation of
% Dave Coffin's dcraw.c program (version 1.194) from:
% 
%   https://www.dechifro.org/dcraw/
% 
% Questions specific to reading behavior can probably be best answered
% from the FAQ included in the above-referenced webpage.
% 
% 
% II. Contents
% ------------
% 
% The following files should be included in this archive:
% 
%   1.  readme.m
%   
%       This file.
%   
%   2.  readrawc.c
%   
%       The uncompiled C MEX-file for reading RAW Camera files, adapted
%       from Dave Coffin's dcraw.c program.
%   
%   3.  readrawc.dll
%   
%       The compiled MEX-file for use on Windows.  Compiled using MSVC 6.0.
%   
%   4.  readrawc.mexglx
%   
%       The compiled MEX-file for use on Linux.  Compiled using GCC 3.2.3.
%   
%   5.  readraw.m
%   
%       A wrapper M-file for calling into the compiled readraw MEX-file to
%       read RAW camera files.  For more information, issue the following
%       command at the MATLAB command prompt:
%       
%         help readraw
%   
%   6.  israw.m
% 
%       A wrapper M-file for calling into the compiled readraw MEX-file to
%       determine whether a file is a RAW camera file.  For more information,
%       issue the following command at the MATLAB command prompt:
%       
%         help israw
% 
%         
% III.  Installation
% ------------------
% 
% A.  Compiling the readrawc.c MEX-file.
% 
%     Although compiled versions of readrawc.c have been included for Windows
%     and Linux, it is advisable to (re)compile the file for use with your
%     specific platform and version of MATLAB.
%      
%     To compile readrawc.c:
%      
%     1.  Set up your MEX-file compiler.
%      
%         a.  Issue the following command at the MATLAB command prompt:
%          
%             mex -setup
%            
%         b.  Follow the prompts to choose a C compiler.  Note that the LCC
%             compiler included on Windows installations will not work --
%             I have had success with MSVC 6.0 and MSVC 7.1, though.
%              
%     2.  Compile the readrawc.c MEX-file
%      
%         a.  Issue the following command at the MATLAB command prompt:
%         
%             if ispc
%                 mex -O -DWIN32 -DNO_JPEG readrawc.c
%             else
%                 mex -O -lm -ljpeg readrawc.c
%             end
%              
%         b.  If compilation is successful, readrawc.<mex extension>
%             should be produced, where <mex extension> is dependent on
%             your platform (e.g., mexw32, mexglx, etc.).
%              
% B.  Integrating READRAW with MATLAB
% 
%     1.  Copy files to a destination directory.
%         
%         Create a destination directory where the READRAW program will
%         reside.  The following MATLAB code should work (you may wish
%         to change the value of destinationDir):
%             
%           destinationDir = fullfile(matlabroot, 'work', 'readraw');
%           mkdir(destinationDir);
%           copyfile('israw.m', destinationDir);
%           copyfile('readraw*.*', destinationDir);
%           copyfile('readme.m', destinationDir);
%              
%     2.  Add the destination directory to your MATLAB path.
%         
%           addpath(destinationDir);
%               
%     3.  Save the destination directory onto your MATLAB path.
%         
%           if sscanf(version, '%d') < 7
%               path2rc;
%           else
%               savepath;
%           end
%
%     4.  Modify the IMFORMATS registry.
%
%         To use these functions with IMREAD, you will need to register 
%         them once per MATLAB session in the IMFORMATS registry.
%         The code that follows will do this.

rawFormat.ext = {'raw', 'crw', 'dcr', 'mrw'};
rawFormat.isa = @israw;
rawFormat.info = '';
rawFormat.read = @readraw;
rawFormat.write = '';
rawFormat.alpha = 0;
rawFormat.description = 'RAW Camera Format (RAW)';

% Adding functions to the IMFORMATS registry changed in MATLAB 7 (R14).
if sscanf(version, '%d') < 7
    formats = imformats;
    formats(end + 1) = rawFormat;
    imformats(formats);
    clear formats
else
    imformats('add', rawFormat);
end

% Clean up.
clear rawFormat
