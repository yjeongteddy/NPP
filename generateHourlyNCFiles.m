function generateHourlyNCFiles(tgt_tc, tgt_NPP, opath, tgt_dir, out_dir)
% generateHourlyNCFiles interpolates 3-hourly netCDF files to hourly data.
% 
%   generateHourlyNCFiles(tgt_dir, tgt_tc)
% 
%   Inputs:
%     tgt_dir - Target directory containing the raw files.
%     tgt_tc  - A string with the case name (e.g., '2009_MAYSAK')
% 
% Example:
%   generateHourlyNCFiles('/home/user_006/01_WORK/2025/NPP/05_DATA/raw/JMA-MSM-S/', '2009_MAYSAK')

% Set default inputs if not provided
if nargin < 1, tgt_tc   = '2211_HINNAMNOR'; end
if nargin < 2, tgt_NPP  = 'SAEUL'; end
if nargin < 3, opath    = '/home/user_006/01_WORK/2025/NPP/05_DATA/'; end
if nargin < 4, tgt_dir  = fullfile(opath, 'raw', 'JMA-MSM-P'); end
if nargin < 5, out_dir  = fullfile(opath, 'processed', tgt_NPP, tgt_tc, '05_MSM-P'); end

%% Change to target directory
cd(fullfile(tgt_dir, tgt_tc));

%% Set flag: if the target case contains 'MSM-S', skip processing 'ght'
isMSM_S = contains(tgt_dir, 'MSM-S');

%% Extract Year from target case string
yearStr = extractYear(tgt_tc);

%% Get list of netCDF files (sorted)
files = getSortedFileList('*.nc');

%% Determine start and end dates based on file names
% Assumes the file name (without extension) contains date info as 'yyyymmdd'
start_date = datenum([yearStr, files{1}(1:end-3)],   'yyyymmdd');
end_date   = datenum([yearStr, files{end}(1:end-3)], 'yyyymmdd');
time_vec   = start_date:end_date;

%% Pre-compute interpolation weights for hourly interpolation.
% For each day, the 3-hourly file gives 9 slices (0h,3h,...,24h).
% We want hourly values (0-23h).
[lower_idx, upper_idx, weightLower, weightUpper] = computeInterpolationWeights();

%% Loop through days (each day is processed using two consecutive files)
% The assumption is that each day corresponds to one file, and you need the 
% following file for the next 3-hour block.
w = waitbar(0, 'Processing...');
if isMSM_S
    for i = 1:length(time_vec)-1
        processDay_S(files, i, time_vec);
        waitbar(i/(length(time_vec)-1),w);
        pause(0.005);
        drawnow;
    end
else
    for i = 1:length(time_vec)-1
        processDay_P(files, i, time_vec, lower_idx, upper_idx, weightLower, weightUpper, out_dir);
        waitbar(i/(length(time_vec)-1),w)
        pause(0.005);
        drawnow;
    end
end
close(w)
end

%% Helper Function: Extract Year from target case string
function yearStr = extractYear(tgt_tc)
% Extracts a year from the target case string. This version first looks for 
% any numeric substring. (Adjust this logic as needed.)
tc_num = extractBefore(tgt_tc, '_');
raw_year = str2double(tc_num(1:2));
if raw_year < 50
    yearVal = raw_year + 2000;
else
    yearVal = raw_year + 1900;
end
yearStr = num2str(yearVal);
end

%% Helper Function: Get Sorted File List
function fileList = getSortedFileList(pattern)
files     = dir(pattern);
fileNames = {files.name};
fileList  = sort(fileNames);
end

%% Helper Function: Compute Interpolation Weights
function [lower_idx, upper_idx, weightLower, weightUpper] = computeInterpolationWeights()
% For each day, the 3-hourly time steps are:
% t0, t0+3h, t0+6h, ..., t0+24h (9 points)
% We need to linearly interpolate to hourly data (0-23 hours).
h_offsets   = 0:23;                     % Hourly offsets (in hours)
lower_idx   = floor(h_offsets/3) + 1;   % Lower index in the 9-slice array (1-indexed)
upper_idx   = lower_idx + 1;            % Upper index (next slice)
weightUpper = mod(h_offsets, 3) / 3;    % Weight for the upper time value
weightLower = 1 - weightUpper;          % Weight for the lower time value
end

%% Helper Function: Process a Single Day for MSM-P
function processDay_P(files, dayIndex, time_vec, lower_idx, upper_idx, weightLower, weightUpper, out_dir)
% Read 3-hourly data for two consecutive files to create a 9-slice 4-D array.
% Note: Variables 'u', 'v', 'rh', and 'temp' are assumed to be 4-D arrays 
% with the 4th dimension representing the 3-hourly time slices.

% Read U
UU1   = ncread(files{dayIndex},   'u');
UU2   = ncread(files{dayIndex+1}, 'u');
N_UU  = cat(4, UU1, UU2(:,:,:,1));  % 9 slices: 8 from UU1 + first slice of UU2

% Read V
VV1   = ncread(files{dayIndex},   'v');
VV2   = ncread(files{dayIndex+1}, 'v');
N_VV  = cat(4, VV1, VV2(:,:,:,1));

% Read RH
RH1   = ncread(files{dayIndex},   'rh');
RH2   = ncread(files{dayIndex+1}, 'rh');
N_RH  = cat(4, RH1, RH2(:,:,:,1));

% Read 'ght'
GHT1  = ncread(files{dayIndex},   'z');
GHT2  = ncread(files{dayIndex+1}, 'z');
N_GHT = cat(4, GHT1, GHT2(:,:,:,1));

% Read Temperature (TT)
TT1   = ncread(files{dayIndex},   'temp');
TT2   = ncread(files{dayIndex+1}, 'temp');
N_TT  = cat(4, TT1, TT2(:,:,:,1));

% Loop over 24 hours in the day
for h = 1:24
    % Interpolate each variable at hour h
    NEW_UU  = N_UU(:,:,:,  lower_idx(h)) .* weightLower(h) + ...
              N_UU(:,:,:,  upper_idx(h)) .* weightUpper(h);
    NEW_VV  = N_VV(:,:,:,  lower_idx(h)) .* weightLower(h) + ...
              N_VV(:,:,:,  upper_idx(h)) .* weightUpper(h);
    NEW_RH  = N_RH(:,:,:,  lower_idx(h)) .* weightLower(h) + ...
              N_RH(:,:,:,  upper_idx(h)) .* weightUpper(h);
    NEW_TT  = N_TT(:,:,:,  lower_idx(h)) .* weightLower(h) + ...
              N_TT(:,:,:,  upper_idx(h)) .* weightUpper(h);
    NEW_GHT = N_GHT(:,:,:, lower_idx(h)) .* weightLower(h) + ...
              N_GHT(:,:,:, upper_idx(h)) .* weightUpper(h);
    
    % Determine the interpolated time for naming the output file
    temp_time     = time_vec(dayIndex) + (h-1)/24;
    new_file_name = fullfile(out_dir, [datestr(temp_time, 'yyyymmddHH') '.nc']);
    
    % Write the interpolated fields to a new netCDF file    
    writeInterpolatedFile_P(new_file_name, NEW_UU, NEW_VV, NEW_RH, NEW_TT, NEW_GHT);
end
end

%% Helper Function: Process a Single Day for MSM-S
function processDay_S(files, dayIndex, time_vec)
% Read U
UU   = ncread(files{dayIndex}, 'u');

% Read V
VV   = ncread(files{dayIndex}, 'v');

% Read RH
RH   = ncread(files{dayIndex}, 'rh');

% Read psea
PSEA = ncread(files{dayIndex}, 'psea');

% Read Temperature (TT)
TT   = ncread(files{dayIndex}, 'temp');

for h = 1:24
    temp_time     = time_vec(dayIndex) + (h-1)/24;
    new_file_name = [datestr(temp_time, 'yyyymmddHH') '.nc'];
    writeInterpolatedFile_S(new_file_name, UU, VV, RH, TT, PSEA);
end
end

%% Helper Function: Write Interpolated Data from MSM-P to netCDF File
function writeInterpolatedFile_P(fileName, NEW_UU, NEW_VV, NEW_RH, NEW_TT, NEW_GHT)
% Write variable 'u'
dims = size(NEW_UU);
nccreate(fileName, 'u', 'Dimensions', {'lon', dims(1), 'lat', dims(2), 'pres', dims(3)});
ncwrite(fileName, 'u', NEW_UU);

% Write variable 'v'
dims = size(NEW_VV);
nccreate(fileName, 'v', 'Dimensions', {'lon', dims(1), 'lat', dims(2), 'pres', dims(3)});
ncwrite(fileName, 'v', NEW_VV);

% Write variable 'rh'
dims = size(NEW_RH);
nccreate(fileName, 'rh', 'Dimensions', {'lon', dims(1), 'lat', dims(2), 'pres', dims(3)});
ncwrite(fileName, 'rh', NEW_RH);

% Write variable 'ght'
dims = size(NEW_GHT);
nccreate(fileName, 'ght', 'Dimensions', {'lon', dims(1), 'lat', dims(2), 'pres', dims(3)});
ncwrite(fileName, 'ght', NEW_GHT);

% Write variable 'tt'
dims = size(NEW_TT);
nccreate(fileName, 'tt', 'Dimensions', {'lon', dims(1), 'lat', dims(2), 'pres', dims(3)});
ncwrite(fileName, 'tt', NEW_TT);
end

%% Helper Function: Write Interpolated Data from MSM-S to netCDF File
function writeInterpolatedFile_S(fileName, UU, VV, RH, PSEA, TT)
% Write variable 'u'
dims = size(UU);
nccreate(fileName, 'u', 'Dimensions', {'lon', dims(1), 'lat', dims(2), 'pres', dims(3)});
ncwrite(fileName, 'u', UU);

% Write variable 'v'
dims = size(VV);
nccreate(fileName, 'v', 'Dimensions', {'lon', dims(1), 'lat', dims(2), 'pres', dims(3)});
ncwrite(fileName, 'v', VV);

% Write variable 'rh'
dims = size(RH);
nccreate(fileName, 'rh', 'Dimensions', {'lon', dims(1), 'lat', dims(2), 'pres', dims(3)});
ncwrite(fileName, 'rh', RH);

% Write variable 'ght'
dims = size(PSEA);
nccreate(fileName, 'psea', 'Dimensions', {'lon', dims(1), 'lat', dims(2), 'pres', dims(3)});
ncwrite(fileName, 'psea', PSEA);

% Write variable 'tt'
dims = size(TT);
nccreate(fileName, 'tt', 'Dimensions', {'lon', dims(1), 'lat', dims(2), 'pres', dims(3)});
ncwrite(fileName, 'tt', TT);
end
