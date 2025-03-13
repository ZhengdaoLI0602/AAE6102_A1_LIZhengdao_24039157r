%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FGI-GSRx software GNSS receiver
%
% Finnish Geospatial Research Institute
% Department of Navigation and Positioning
% DO NOT DISTRIBUTE
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ini_data = ls3wReadIni(filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extracts parameters from LabSat .ini-file
%
% Inputs:
%   filename        - Path to input LabSat .ini-file
%
% Outputs:
%   ini_data        - Struct of parsed parameters included in the input
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize a struct to hold .ini-file data
ini_data = struct();

% Open the input .ini-file
fid = fopen(filename, 'r');
if fid == -1
    error('Could not open the .ini file.');
end

% Read and parse the .ini-file line by line
while ~feof(fid)
    line = fgetl(fid);
    if startsWith(line, '[config]')
        section = 'config';
    elseif startsWith(line, '[channel A]')
        section = 'channel_A';
    elseif startsWith(line, '[channel B]')
        section = 'channel_B';
    elseif startsWith(line, '[channel C]')
        section = 'channel_C';
    elseif startsWith(line, '[notes]')
        section = 'notes';
    else
        % Extract key-value pairs
        tokens = regexp(line, '(.*)=(.*)', 'tokens');
        if ~isempty(tokens)
            key = strtrim(tokens{1}{1});
            key = strrep(key,' ','');
            value = strtrim(tokens{1}{2});
            ini_data.(section).(key) = value;
        end
    end
end

% Close the opened ini-file
fclose(fid);