function CreateFilterScript(opath, dpath, tgt_NPP, tgt_TC)
% run_TC_processing - Processes tropical cyclone data and creates shell scripts.
%
% Syntax:
%   run_TC_processing(opath, dpath, tgt_NPP, tgt_TC)
%
% Inputs:
%   opath   - Output base directory (e.g., '/home/user_006/01_WORK/2025/NPP/')
%   dpath   - Data directory path relative to opath (e.g., '05_DATA/processed')
%   tgt_NPP - Target NPP name (e.g., 'SAEUL')
%   tgt_TC  - Target TC identifier (e.g., '2211_HINNAMNOR')
%
% This function loads RSMC track data, interpolates the track variables to an
% hourly resolution, loads merged netCDF files, and writes shell scripts that
% export various parameters for each file group.
%
% Example:
%   run_TC_processing('/home/user_006/01_WORK/2025/NPP/', ...
%                     '05_DATA/processed', 'SAEUL', '2211_HINNAMNOR')

% Set default inputs if not provided
if nargin < 1, opath   = '/home/user_006/01_WORK/2025/NPP/'; end
if nargin < 2, dpath   = '05_DATA/processed'; end
if nargin < 3, tgt_NPP = 'SAEUL'; end
if nargin < 4, tgt_TC  = '2009_MAYSAK'; end

% Add library paths
addpath(genpath('/home/user_006/08_MATLIB'));

%% Save current path and load RSMC and TC info
current_path = pwd;
rs_path      = '/data/2.DATA/DATA_SHARE/DATA/RSMC_BEST_TRACK';
bst_file     = fullfile(rs_path, 'bst_all.txt');
RSMC         = read_RSMC_track_all(bst_file);

load('/home/user_006/03_DATA/TC_INFO.mat'); 

%% Identify matching TC in RSMC data using vectorized comparison
TC_num = extractBefore(tgt_TC, '_');
matchIndices = find(arrayfun(@(x) str2double(x.INT_NUMID) == str2double(TC_num), RSMC));
if isempty(matchIndices)
    error('Target TC "%s" not found in the RSMC data.', tgt_TC);
end
% Process only the first matching entry (adjust if you need multiple)
rs_index = matchIndices;

%% Hourly interpolation along the TC track
interp_value.TIME = [];
interp_value.R30  = [];
interp_value.R50  = [];
interp_value.LON  = [];
interp_value.LAT  = [];
interp_value.VMAX = [];
interp_value.MSLP = [];

timeData = RSMC(rs_index).TIME;
nPoints = length(timeData);
for i = 1:nPoints-1
    t_start = timeData(i);
    t_end   = timeData(i+1);
    
    % Create hourly time steps (excluding the end point)
    TIME_INTERP = (t_start : 1/24 : (t_end - 1/24))';
    
    % Interpolate each field between successive points
    R30_INTERP  = interp1([t_start, t_end], [RSMC(rs_index).R30L(i),      RSMC(rs_index).R30L(i+1)],      TIME_INTERP);
    R50_INTERP  = interp1([t_start, t_end], [RSMC(rs_index).R50L(i),      RSMC(rs_index).R50L(i+1)],      TIME_INTERP);
    LON_INTERP  = interp1([t_start, t_end], [RSMC(rs_index).LONGITUDE(i), RSMC(rs_index).LONGITUDE(i+1)], TIME_INTERP);
    LAT_INTERP  = interp1([t_start, t_end], [RSMC(rs_index).LATITUDE(i),  RSMC(rs_index).LATITUDE(i+1)],  TIME_INTERP);
    VMAX_INTERP = interp1([t_start, t_end], [RSMC(rs_index).VMAX_KNOT(i), RSMC(rs_index).VMAX_KNOT(i+1)], TIME_INTERP);
    MSLP_INTERP = interp1([t_start, t_end], [RSMC(rs_index).MSLP(i),      RSMC(rs_index).MSLP(i+1)],      TIME_INTERP);
    
    % Concatenate the results
    interp_value.TIME = [interp_value.TIME; TIME_INTERP];
    interp_value.R30  = [interp_value.R30;  R30_INTERP];
    interp_value.R50  = [interp_value.R50;  R50_INTERP];
    interp_value.LON  = [interp_value.LON;  LON_INTERP];
    interp_value.LAT  = [interp_value.LAT;  LAT_INTERP];
    interp_value.VMAX = [interp_value.VMAX; VMAX_INTERP];
    interp_value.MSLP = [interp_value.MSLP; MSLP_INTERP];
end

%% Load merged netCDF data
mergedDir = fullfile(opath, dpath, tgt_NPP, tgt_TC, '07_GMSM');
cd(mergedDir);
ncFiles = dir('nc_uv_*met_em*00.nc');
if isempty(ncFiles)
    error('No matching netCDF files found in %s', mergedDir);
end
LON_mat = ncread(ncFiles(1).name, 'XLONG_M');
LAT_mat = ncread(ncFiles(1).name, 'XLAT_M');

%% Process each netCDF file in groups and write shell scripts
circ_id = 20;  % files per script
nFile   = 1;
totalFiles = length(ncFiles);
numGroups = ceil(totalFiles / circ_id);

for s_id = 1:numGroups
    scriptName = sprintf('run_script_%02d.sh', s_id);
    fid = fopen(scriptName, 'w');
    if fid == -1
        error('Cannot open file %s for writing', scriptName);
    end
    
    fprintf(fid, '#!/bin/bash\n');
    
    groupEnd = min(nFile + circ_id - 1, totalFiles);
    for i = nFile:groupEnd
        fileName = ncFiles(i).name;
        
        % Assume the met time is located between the 2nd and 3rd dots in the file name
        dotIndices = strfind(fileName, '.');
        if length(dotIndices) < 3
            error('Unexpected file name format: %s', fileName);
        end
        metTimeStr = fileName(dotIndices(2)+1 : dotIndices(3)-1);
        met_time = datenum(metTimeStr, 'yyyy-mm-dd_HH:MM:SS');
        
        % Find closest time index in the interpolated data
        [~, time_id] = min(abs(interp_value.TIME - met_time));
        R30_val = interp_value.R30(time_id) * 1.852;
        if R30_val < 1
            R30_val = 300;
        end
        
        % Read pressure field and extract track position
        PMSL = ncread(fileName, 'PMSL');
        track_lon = interp_value.LON(time_id);
        track_lat = interp_value.LAT(time_id);
        
        % Determine spatial window (5 degree radius)
        x_id = (LON_mat > (track_lon - 5)) & (LON_mat < (track_lon + 5));
        y_id = (LAT_mat > (track_lat - 5)) & (LAT_mat < (track_lat + 5));
        in_id = x_id & y_id;
        
        % Set out-of-window values very high so that min finds the minimum within the window
        FIND_MIN_PMSL = PMSL;
        FIND_MIN_PMSL(~in_id) = 9e10;
        MINP = min(FIND_MIN_PMSL(in_id));
        [I, J] = find(FIND_MIN_PMSL == MINP);
        
        % Use the first occurrence if multiple found
        TC_X = LON_mat(I(1), J(1));
        TC_Y = LAT_mat(I(1), J(1));
        
        % Write export commands to the shell script
        fprintf(fid, 'export file_name=%s\n', fileName);
        filterFileName = ['filter_' datestr(met_time, 'yymmddHH') '.ncl'];
        fprintf(fid, 'export filter_name=%s\n', filterFileName);
        
        % File name variations
        baseName = fileName(1:end-3);
        fprintf(fid, 'export file_name_vortex=%s\n', [baseName '.vortex.nc']);
        fprintf(fid, 'export file_name_env=%s\n',    [baseName '.env.nc']);
        fprintf(fid, 'export file_name_basic=%s\n',  [baseName '.basic.nc']);
        fprintf(fid, 'export file_name_vortex_as=%s\n',[baseName '.vortex_as.nc']);
        fprintf(fid, 'export file_name_vortex_ax=%s\n',[baseName '.vortex_ax.nc']);
        
        % Write TC location and R0 (converted to meters)
        fprintf(fid, 'export TC_i=%d\n', I(1));
        fprintf(fid, 'export TC_j=%d\n', J(1));
        fprintf(fid, 'export TC_lat=%.4f\n', TC_Y);
        fprintf(fid, 'export TC_lon=%.4f\n', TC_X);
        fprintf(fid, 'export R0=%d\n', R30_val * 1000);
        
        % Copy the filter file from a fixed location using MATLAB's copyfile
        filterSrc = 'filter.ncl';
        copyfile(filterSrc, filterFileName);
        
        % Write commands to run the filter scripts
        fprintf(fid, 'csh ./filter_csh2.csh\n');
        fprintf(fid, ['ncl ' filterFileName ' &\n']);
    end
    fclose(fid);
    system(['chmod u+x ' scriptName]);
    nFile = groupEnd + 1;
end

% Return to the original directory
cd(current_path);
end
