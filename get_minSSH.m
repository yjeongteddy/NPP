function get_minSSH(tg_tc, tg_NPP, intensity, SeaLevel)

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

% dlist = dir('*');
% dlist = dlist(~ismember({dlist.name}, {'.', '..'}));

% parpool(6)
% for i  = 1:length(dlist)
%     cd(fullfile(dlist(i).folder, dlist(i).name))
raw_surge = read_adcirc_fort63('fort.63'); % Strom surge height at all time step
minSSH_all = raw_surge.zeta;
minSSH = min(minSSH_all,[],2);

if any(isnan(minSSH)) % check if maxSSH contains nan value
    val_indices = find(~isnan(minSSH));
    non_indices = find(isnan(minSSH));
    if any(find(isnan(minSSH)) == 1) % if nan value be in 1st
        if length(find(isnan(minSSH))) == 1 % if it's the only nan value
            minSSH(1) = val_indices(1); % replace with first non-nan value
        else
            minSSH(1) = val_indices(1); % replace with first non-nan value and then ..
            minSSH(non_indices) = interp1(val_indices, minSSH(val_indices), non_indices, 'linear'); % interp on rest
        end
    elseif any(find(isnan(minSSH)) == length(minSSH)) % if nan value be in last
        if length(find(isnan(minSSH))) == 1 % if it's the only nan value
            minSSH(length(minSSH)) = val_indices(end);
        else
            minSSH(length(minSSH)) = val_indices(end);
            minSSH(non_indices) = interp1(val_indices, minSSH(val_indices), non_indices, 'linear');
        end
    else
        minSSH(non_indices) = interp1(val_indices, minSSH(val_indices), non_indices, 'linear');
    end
end
% parsave('minSSH.mat', minSSH);
save('minSSH.mat', 'minSSH');
% disp(['Completed for ' dlist(i).name])
% end
end



