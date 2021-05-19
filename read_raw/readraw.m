function [X,map] = readraw(filename,varargin)
%READRAW Read a RAW camera file.
%[X,map] = readraw('C:\Users\BigBrain\Desktop\Remapping project\jy150non\recording_20210517_160809.raw')
%   READRAW(FILENAME) reads the RAW file specified by FILENAME.
%
%   READRAW(FILENAME,OPTIONS) allows you to specify options for the way in
%   in which the file is to be read.  OPTIONS is a structure with any of the
%   following fields:
%
%     'AutomaticWhiteBalance'       Use automatic white balance:  true or
%                                   false (default).
%
%     'BitsPerPixel'                Specify the bits per pixel:  24 (default)
%                                   or 48.
%
%     'BlueMultiplier'              Set blue multiplier (daylight = 1.0).
%
%     'Brightness'                  Set brightness:  1.0 by default.
%
%     'CameraWhiteBalance'          Use camera white balance, if possible:
%                                   true or false (default).
%
%     'Gamma'                       Set gamma:  0.6 by default (only for
%                                   24 bits per pixel output).
%
%     'RedMultiplier'               Set red multiplier (daylight = 1.0).
%
%   READRAW(FILENAME,'ATTRIBUTE1','VALUE1','ATTRIBUTE2','VALUE2'...)
%   An alternative calling syntax that uses attribute value pairs for
%   specifying optional arguments to READRAW. The order of the
%   attribute-value pairs does not matter, as long as an appropriate value
%   follows each attribute tag. 
%
%   EXAMPLES:
%
%   % Read the file myRawPicture.raw using 48 bits per pixel
%   % and a blue multiplier of 3.
%   options = struct('BitsPerPixel',48,'BlueMultiplier',3)
%   readraw('myRawPicture.raw',options) 
%
%   % Read the file myRawPicture.raw using a brightness of 1.6,
%   % a gamma value of 0.8, and a red multiplier of 0.33.
%   readraw('myRawPicture.raw','Brightness',1.6,'Gamma',0.8,'RedMultiplier',0.33)
%
%   See also ISRAW.

%% Verify that a filename was specified and that the file exists.
if (nargin < 1)
    eid = 'readraw:tooFewInputs';
    error(eid, 'A file name must be specified.')
end

if ischar(filename)
    % FILENAME is a string.  Check to see whether file exists.
    if exist(filename,'file') ~= 2
        eid = 'readraw:invalidFileName';
        msg = '%s: No such file or directory';
        error(eid,msg,filename)
    end
else
    % FILENAME is not a string.  Throw error.
    eid = 'readraw:invalidDataType';
    msg = 'Invalid data type specified for FILENAME.  Char expected, but %s was specified.';
    error(eid,msg,class(filename))
end

%% Verify that FILENAME is a (supported) RAW camera file.  Error if it is not.
if ~israw(filename)
    eid = 'readraw:invalidRawFile';
    msg = 'Invalid RAW Camera File specified.  %s is not a supported RAW file type.';
    error(eid,msg,filename)
end    

%% Parse input option parameters.
options = parse_inputs(varargin{:});

%% If options have been specified, verify that the correct data types and values have been specified.
if ~isempty( fieldnames( options ) )

    % Check Gamma and BitPerPixel.
    % Throw warning of BitsPerPixel ~= 24 and a Gamma other than 0.6 has been specified.
    if ( isfield(options,'bitsperpixel')    && isscalar(options.bitsperpixel) && ...
            isnumeric(options.bitsperpixel) && options.bitsperpixel ~= 24     && ...
         isfield(options,'gamma')           && isscalar(options.gamma)        && ...
            isnumeric(options.gamma)        && options.gamma ~= 0.6 )
        wid = 'readraw:invalidGammaSetting';
        msg = 'Gamma values cannot be specified for images that are not 24 BitsPerPixel.';
        warning(wid,msg)
    end

    % Step through the fields of the options struct
    for idx = 1:length( fieldnames(options) );
        
        field_names = fieldnames(options);
        current_field = field_names{idx};
        
        % Check whether an empty value was specified for the field.
        % Empty field values are acceptable -- default values will be used.
        if ~isempty( options.(current_field) )
            
            % Check whether a nonscalar matrix was specified as a value.
            if ~ischar( options.(current_field) ) && ~isscalar( options.(current_field) )
                eid = 'readraw:nonscalarParameterValue';
                error(eid, 'Invalid size specified for ''%s'' value.  Scalar expected, but %s matrix specified.', ...
                    current_field, ['<' strrep( num2str( size( options.(current_field) ) ),'  ','x') '>'] );
            end

            % Check data types of fields
            switch current_field

                case {'automaticwhitebalance','camerawhitebalance'}  % Logical Fields

                    % Check whether a logical was specified.
                    % If not, try to convert it to a logical.  (e.g., "1" -> "true")
                    if  ~islogical( options.(current_field) ) 
                        try
                            options.(current_field) = logical(options.(current_field));
                        catch
                            eid = 'readraw:invalidParameterDataType';
                            error(eid, 'Invalid data type specified for ''%s''.  Logical expected, but %s was specified.',...
                                current_field, class(options.(current_field)));
                        end
                    end

                case {'bitsperpixel','bluemultiplier','brightness','gamma','redmultiplier'}  % Numeric Fields

                    if ( isnumeric( options.(current_field) ) )

                        % Check to see whether a complex number, Inf, NaN, or a negative number was specified.
                        if ( imag(  options.(current_field) ) || isinf( options.(current_field) ) || ...
                             isnan( options.(current_field) ) || options.(current_field) < 0    )

                            eid = 'readraw:invalidNumeric';
                            error(eid, 'Invalid numeric specified for ''%s''.  Value cannot be complex, Inf, NaN, or negative.', current_field);

                        end

                        % For certain numeric fields, the value must be converted to a string.
                        switch current_field
                            case {'bluemultiplier','brightness','gamma','redmultiplier'}

                                % Convert numeric value to string.
                                options.(current_field) = num2str(options.(current_field));
                        end

                    else

                        eid = 'readraw:invalidParameterDataType';
                        error(eid, 'Invalid data type specified for ''%s''.  Numeric expected, but %s was specified.',...
                            current_field, class(options.(current_field)));

                    end

            end

        end

    end

end

%% Call readrawc MEX-function to read the raw image file.
X = readrawc(filename,options);
map = [];  % For compatibility with IMREAD.

function options = parse_inputs(varargin)
%PARSE_INPUTS   Obtain AutomaticWhiteBalance, BitsPerPixel, BlueMultiplier, Brightness,
% CameraWhiteBalance, Gamma, and RedMultiplier values from input.

% Structures containing multiple values can occur anywhere in the
% metadata information as long as they don't split a parameter-value
% pair.  Any number of structures can appear.

readraw_fields = {'automaticwhitebalance'
                  'bitsperpixel'
                  'bluemultiplier'
                  'brightness'
                  'camerawhitebalance'
                  'gamma'
                  'redmultiplier'};

options = struct;  % Create an empty struct in case nothing was specified.
total_args  = nargin;
current_arg = 1;

while (current_arg <= total_args)

    if (ischar(varargin{current_arg}))
        
        % Parameter-value pair.
        
        if (current_arg == total_args)

            eid = 'readraw:missingValue';
            msg = 'Parameter ''%s'' must have an associated value.';
            error(eid,msg,varargin{current_arg});
            
        else

            % See whether the specified parameter matches any of the
            % valid readraw_fields
            param = varargin{current_arg};
            idx = find(strcmpi(param, readraw_fields));
            
            % If exactly one field matched the specified param,
            % assign the value to the options structure.
            if (numel(idx) > 1)      % Multiple matches.
                eid = 'readraw:ambiguousParameter';
                error(eid, 'Ambiguous parameter ''%s'' specified.', param);
            elseif (numel(idx) < 1)  % No matches.
                eid = 'readraw:invalidParameter';
                error(eid, 'Invalid parameter ''%s'' specified.', param);
            else                     % One match.  It's a READRAW parameter.
                options.(readraw_fields{idx}) = varargin{current_arg + 1};
            end
            
            current_arg = current_arg + 2;

        end
        
    elseif (isstruct(varargin{current_arg}))
        
        % Structure of parameters and values.
        
        str = varargin{current_arg};
        field_names = fieldnames(str);
        
        for p = 1:numel(field_names)
            
            % See whether the specified parameter matches any of the
            % valid readraw_fields
            param = field_names{p};
            idx = find(strcmpi(param, readraw_fields));
            
            % If exactly one field matched the specified param,
            % assign the value to the options structure.
            if (numel(idx) > 1)      % Multiple matches.
                eid = 'readraw:ambiguousParameter';
                error(eid, 'Ambiguous parameter ''%s'' specified.', param);
            elseif (numel(idx) < 1)  % No matches.
                eid = 'readraw:invalidParameter';
                error(eid, 'Invalid parameter ''%s'' specified.', param);
            else                     % One match.
                options.(readraw_fields{idx}) = str.(param);
            end
            
        end
        
        current_arg = current_arg + 1;
        
    else
        
        eid = 'readraw:expectedStructOrParameterValuePair';
        msg = 'Argument must be either a structure or parameter-value pair.';
        error(eid,msg);
        
    end

end