function get_JMA_WIND_robust(setting)
% Take params
ORG_PATH     = setting.ORG_PATH;
TGT_PATH     = setting.TGT_PATH;
OUT_PATH     = setting.OUT_PATH;
TC_NAME      = setting.TC_NAME;
mname        = setting.MODEL_NAME;
numWorkers   = setting.numWorkers;
TGT_SL       = setting.TGT_SL;

% Set lib path
addpath(genpath('/home/user_006/08_MATLIB'));

% Get depth info
fgs = grd_to_opnml(fullfile(ORG_PATH, TGT_SL, 'fort.14'));

% Load the entire list of TC
load('/home/user_006/03_DATA/TC_INFO.mat');

% Index target TC out of loaded TC list
tc_num = cell2mat(regexp(TC_NAME, '^\d+', 'match'));
find_id = strcmp(string(num2str(str2num(str2mat(TC_INFO(:,1))),'%04d')),tc_num);

% Get time span during TC occurred
period = str2mat(TC_INFO(find_id,3));
idx_str = strfind(period,'~');
start_date = datenum(period(1:idx_str-1),'yymmddHH');
end_date = datenum(period(idx_str+1:end),'yymmddHH');

% Hourly
date_vec = start_date:1/24:end_date;

% Load target wind dataset
tgt_year = datestr(start_date,'yyyy');
cd(TGT_PATH);
dlist = dir('*.nc');

% Select fac
if str2num(tgt_year) < 2006
    fac = 9.81*10;
else
    fac = 9.81*10^3;
end

% Do the work
switch mname
    case 'ADCIRC'
        parpool(numWorkers)
        process_ADCIRC(date_vec, OUT_PATH, TC_NAME, fgs);
    case 'SWAN'
        parpool(numWorkers)
        process_SWAN(date_vec, OUT_PATH, fgs);
end
cd(ORG_PATH);
end

%% Helper function
function process_ADCIRC(date_vec, OUT_PATH, TC_NAME, fgs)
% Set up output path
spath = fullfile(OUT_PATH, ['ADCIRC_' TC_NAME], [TC_NAME '_PRESS']);
if ~exist(spath, 'dir'), mkdir(spath); end

parfor date_id = 1:length(date_vec)
    current_date = date_vec(date_id);
    process_single_time(current_date, fgs, spath, true);
end

% Combine all data files
system(['cat ', fullfile(spath, '*.dat'), ' > ', fullfile(spath, 'fort.22')]);
end

%% Helper function
function process_SWAN(date_vec, OUT_PATH, fgs)
% Set up output path
spath = OUT_PATH;
if ~exist(spath, 'dir'), mkdir(spath); end

parfor date_id = 1:length(date_vec)
    current_date = date_vec(date_id);
    process_single_time(current_date, fgs, spath, false);
end
end

%% Helper function
function process_single_time(current_date, fgs, output_path, is_ADCIRC)
% Load data
date_str = datestr(floor(current_date), 'mmdd');
hour_str = datestr(current_date, 'HH');
find_file = [date_str, '.nc'];
current_hour = str2double(hour_str) + 1;

lon = ncread(find_file, 'lon');
lat = ncread(find_file, 'lat');
u = double(ncread(find_file, 'u'));
v = double(ncread(find_file, 'v'));
[x_mat, y_mat] = meshgrid(lon, lat);
x_mat = double(x_mat); y_mat = double(y_mat);

% Interpolate data
u_interp = griddata(x_mat, y_mat, u(:, :, current_hour)', fgs.x, fgs.y, 'linear');
v_interp = griddata(x_mat, y_mat, v(:, :, current_hour)', fgs.x, fgs.y, 'linear');

if is_ADCIRC
    press = ncread(find_file, 'psea') / fac; % Convert hPa to Pa
    press_interp = griddata(x_mat, y_mat, press(:, :, current_hour)', fgs.x, fgs.y, 'linear');
    
    % Handle NaNs
    [u_interp, v_interp, press_interp] = handle_nans(u_interp, v_interp, press_interp, fgs);
    output_data = [(1:length(fgs.x))', u_interp, v_interp, press_interp];
else
    % Handle NaNs
    u_interp(isnan(u_interp)) = 0;
    v_interp(isnan(v_interp)) = 0;
    output_data = [u_interp; v_interp];
end

% Write data to file
output_file = fullfile(output_path, [datestr(current_date, 'yyyy-mm-dd_HH'), '.dat']);
dlmwrite(output_file, output_data, 'delimiter', ' ', 'precision', '%.5f');
end

%% Helper function
function [u, v, press] = handle_nans(u, v, press, fgs)
    % Replace NaN values with nearest neighbor
    nan_mask = isnan(press);
    for id = find(nan_mask)'
        dist = sqrt((fgs.x(id) - fgs.x(~nan_mask)).^2 + (fgs.y(id) - fgs.y(~nan_mask)).^2);
        [~, nearest_idx] = min(dist);
        press(id) = press(nearest_idx);
    end
    u(isnan(u)) = 0;
    v(isnan(v)) = 0;
end
