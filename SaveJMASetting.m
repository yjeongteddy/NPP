function SaveJMASetting(tgt_tc, tgt_NPP, opath, modelName, tgt_SL)

% Set default inputs if not provided
if nargin < 1, tgt_tc    = '2211_HINNAMNOR'; end
if nargin < 2, tgt_NPP   = 'SAEUL'; end
if nargin < 3, opath     = '/home/user_006/01_WORK/2025/NPP/05_DATA/processed'; end
if nargin < 4, modelName = 'SWAN'; end
if nargin < 5, tgt_SL    = 'AHHL'; end

% Set params
setting.ORG_PATH   = fullfile(opath, tgt_NPP);
setting.TGT_PATH   = fullfile(opath, tgt_NPP, tgt_tc, '06_MSM-S');
setting.MODEL_NAME = modelName;
setting.OUT_PATH   = fullfile(opath, tgt_NPP, tgt_tc, '11_JMA');
setting.TC_NAME    = tgt_tc;
setting.numWorkers = 96;
setting.TGT_SL     = tgt_SL;

if ~exist(setting.OUT_PATH, 'dir')
    mkdir(setting.OUT_PATH);
end

save(fullfile(setting.OUT_PATH, 'settings.mat'), 'setting');
end