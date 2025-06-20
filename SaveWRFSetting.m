function SaveWRFSetting(tgt_tc, tgt_NPP, opath, intensity, modelName, tgt_SL)

% Set default inputs if not provided
if nargin < 1, tgt_tc    = '1215_BOLAVEN'; end
if nargin < 2, tgt_NPP   = 'HANBIT'; end
if nargin < 3, opath     = '/home/user_006/01_WORK/2025/NPP/05_DATA/processed'; end
if nargin < 4, intensity = '1.40'; end
if nargin < 5, modelName = 'ADCIRC'; end
if nargin < 6, tgt_SL    = '10exL'; end

% Set params
setting.ORG_PATH   = fullfile(opath, tgt_NPP);
setting.TGT_PATH   = fullfile(opath, tgt_NPP, tgt_tc, '09_WRF', intensity);
setting.MODEL_NAME = modelName;
setting.TGT_SL     = tgt_SL;

switch setting.TGT_SL
    case '10exH+SLR'
        subdir = 'MAX';
    case '10exL'
        subdir = 'MIN';
    case 'AHHL'
        subdir = '';
end

switch setting.MODEL_NAME
    case 'ADCIRC'
        setting.OUT_PATH = fullfile(opath, tgt_NPP, tgt_tc, '12_ADCIRC', subdir, intensity);
    case 'SWAN'
        setting.OUT_PATH = fullfile(opath, tgt_NPP, tgt_tc, '10_SWAN', subdir, intensity);
end

setting.TC_NAME    = tgt_tc;
setting.numWorkers = 96;

if ~exist(setting.OUT_PATH, 'dir')
    mkdir(setting.OUT_PATH);
end

save(fullfile(setting.OUT_PATH, 'settings.mat'), 'setting');
end