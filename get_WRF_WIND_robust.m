function get_WRF_WIND_robust(setting)
% Extract settings
ORG_PATH     = setting.ORG_PATH;
TGT_PATH     = setting.TGT_PATH;
OUT_PATH     = setting.OUT_PATH;
TC_NAME      = setting.TC_NAME;
mname        = setting.MODEL_NAME;
numWorkers   = setting.numWorkers;
tgt_SL       = setting.TGT_SL;

% Set lib path
addpath(genpath('/home/user_006/08_MATLIB'));

% Get depth info
fgs = grd_to_opnml(fullfile(ORG_PATH, tgt_SL, 'fort.14'));

% Check if a parallel pool already exists
% poolobj = gcp('nocreate');
% if isempty(poolobj)
%     parpool(numWorkers);
% end

% Extract yearStr
yearStr = extractYear(TC_NAME);

% Navigate to target directory
target_dir = TGT_PATH;
cd(target_dir);

% Load coordinate data
x_mat = load('longitude.dat');
y_mat = load('latitude.dat');

% Load file lists
PRESS_FILES = dir('slp_*');
U_FILES = dir('u10_*');
V_FILES = dir('v10_*');

% Constants
fac = 9.81 * 1e3; % Conversion factor

% Process based on model type
switch mname
    case 'ADCIRC'
        spath = OUT_PATH;
        if ~exist(spath, 'dir'), mkdir(spath); end
        process_files_PARFOR(PRESS_FILES, U_FILES, V_FILES, x_mat, y_mat, fgs, fac, spath, true);
        system(['cat ', fullfile(spath, '*.dat'), ' > ', fullfile(spath, 'fort.22')]);
        
    case 'SWAN'
        spath = OUT_PATH;
        if ~exist(spath, 'dir'), mkdir(spath); end
        process_files_PARFOR(PRESS_FILES, U_FILES, V_FILES, x_mat, y_mat, fgs, fac, spath, false);
        cd(spath)
        system(['find . -type f -name "', yearStr, '*.dat' '" | sort -V > WIND_NAMES.dat']);
end

% Return to initial path
cd(ORG_PATH);
end

%% Helper function
function process_files_PARFOR(PRESS_FILES, U_FILES, V_FILES, x_mat, y_mat, fgs, fac, spath, is_ADCIRC)
    % Parallel processing of files
    parfor file_id = 1:length(PRESS_FILES)
        % Load data
        u10 = load(U_FILES(file_id).name);
        v10 = load(V_FILES(file_id).name);
        press = load(PRESS_FILES(file_id).name) / fac * 100; % Convert hPa to Pa
        
        % Extract date string
        date_string = extract_date(U_FILES(file_id).name);
        
        % Interpolate data
        u_interp = griddata(x_mat, y_mat, u10, fgs.x, fgs.y, 'linear');
        v_interp = griddata(x_mat, y_mat, v10, fgs.x, fgs.y, 'linear');
        if is_ADCIRC
            press_interp = griddata(x_mat, y_mat, press, fgs.x, fgs.y, 'linear');
            % Handle NaN values
            [u_interp, v_interp, press_interp] = handle_nans(u_interp, v_interp, press_interp, fgs);
            output_data = [(1:length(fgs.x))', u_interp, v_interp, press_interp];
        else
            % Handle NaN values
            u_interp(isnan(u_interp)) = 0;
            v_interp(isnan(v_interp)) = 0;
            output_data = [u_interp; v_interp];
        end
        
        % Save output data
        output_file = fullfile(spath, [datestr(datenum(date_string, 'yyyy-mm-dd_HH'), 'yyyy-mm-dd_HH') '.dat']);
        dlmwrite(output_file, output_data, 'delimiter', ' ', 'precision', '%.5f');
    end
end

%% Helper function
function date_string = extract_date(file_name)
    % Extract date string using regex
    pattern = '\d{4}-\d{2}-\d{2}_\d{2}';
    date_string = regexp(file_name, pattern, 'match', 'once');
end

function [u, v, press] = handle_nans(u, v, press, fgs)
    % Handle NaN values by replacing with nearest neighbors
    nan_mask = isnan(press);
    for id = find(nan_mask)'
        dist = sqrt((fgs.x(id) - fgs.x(~nan_mask)).^2 + (fgs.y(id) - fgs.y(~nan_mask)).^2);
        [~, nearest_idx] = min(dist);
        press(id) = press(nearest_idx);
    end
    u(isnan(u)) = 0;
    v(isnan(v)) = 0;
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

