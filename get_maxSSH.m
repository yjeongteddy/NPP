function get_maxSSH(tg_tc, tg_NPP, intensity, SeaLevel)

addpath(genpath('/home/user_006/08_MATLIB'))

%% Set default inputs
if nargin < 1, tg_tc     = '1215_BOLAVEN'; end
if nargin < 2, tg_NPP    = 'HANBIT'; end
if nargin < 3, intensity = '1.40'; end
if nargin < 4, SeaLevel  = '10exL'; end

switch SeaLevel
    case '10exH+SLR'
        subdir = 'MAX';
    case '10exL'
        subdir = 'MIN';
    case 'AHHL'
        subdir = '';
end

rpath  = '/home/user_006/01_WORK/2025/NPP';
spath  = fullfile(rpath, '02_SCRIPT');
opath  = fullfile(rpath, '05_DATA/processed');
dpath  = fullfile(opath, tg_NPP);
wpath  = fullfile(dpath, tg_tc, '12_ADCIRC', subdir, intensity); 
tc_num = extractBefore(tg_tc, '_');

%% Get depth info
fgs = grd_to_opnml(fullfile(dpath, SeaLevel, 'fort.14'));

%% Create MaxSSH dataset
cd(wpath)

if exist('maxele.63','file') == 2
    disp('Found maxele.63!')
    raw_maxSSH = read_adcirc_fort('maxele.63'); % Max storm surge height over all time step
    maxSSH = raw_maxSSH.zeta;
else
    disp('cannot find maxele.63!')
    raw_surge = read_adcirc_fort63('fort.63'); % Strom surge height at all time step
    maxSSH_all = raw_surge.zeta;
    maxSSH = max(maxSSH_all,[],2);
end

if any(isnan(maxSSH)) % check if maxSSH contains nan value
    val_indices = find(~isnan(maxSSH));
    non_indices = find(isnan(maxSSH));
    if any(find(isnan(maxSSH)) == 1) % if nan value be in 1st
        if length(find(isnan(maxSSH))) == 1 % if it's the only nan value
            maxSSH(1) = val_indices(1); % replace with first non-nan value
        else
            maxSSH(1) = val_indices(1); % replace with first non-nan value and then ..
            maxSSH(non_indices) = interp1(val_indices, maxSSH(val_indices), non_indices, 'linear'); % interp on rest
        end
    elseif any(find(isnan(maxSSH)) == length(maxSSH)) % if nan value be in last
        if length(find(isnan(maxSSH))) == 1 % if it's the only nan value
            maxSSH(length(maxSSH)) = val_indices(end);
        else
            maxSSH(length(maxSSH)) = val_indices(end);
            maxSSH(non_indices) = interp1(val_indices, maxSSH(val_indices), non_indices, 'linear');
        end
    else
        maxSSH(non_indices) = interp1(val_indices, maxSSH(val_indices), non_indices, 'linear');
    end
end
save('maxSSH.mat','maxSSH');

end

