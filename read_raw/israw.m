function result = israw(filename)
%ISRAW True if specified FILENAME is a RAW camera file.
%   ISRAW returns true for files that are RAW camera files and false otherwise.
%
%   See also READRAW.
if (nargin < 1)
    eid = 'Images:israw:tooFewInputs';
    error(eid, 'A file name must be specified.')
end

s.israw = true;
result = readrawc(filename,s);