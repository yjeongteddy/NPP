function DuplicateMergedNcFile(tg_tc, tg_NPP, opath)


if nargin < 1, tg_tc  = '0314_MAEMI'; end
if nargin < 2, tg_NPP = 'SAEUL'; end
if nargin < 3, opath  = '/home/user_006/01_WORK/2025/NPP/05_DATA/processed'; end

% Add path for additional MATLAB libraries (if needed)
addpath(genpath('/home/user_006/08_MATLIB'));

% Target folder
cd(fullfile(opath, tg_NPP, tg_tc, '07_GMSM'))

% Target files
tlist = dir('nc_uv_merge*00.nc');

parpool(48)
% Do the work
parfor i = 1:length(tlist)
    Depature = tlist(i).name;
    [~, tgt_fname, ~] = fileparts(Depature);
    
    Destination_env       = [tgt_fname '.env.nc'];
    Destination_basic     = [tgt_fname '.basic.nc'];
    Destination_vortex    = [tgt_fname '.vortex.nc'];
    Destination_vortex_ax = [tgt_fname '.vortex_ax.nc'];
    Destination_vortex_as = [tgt_fname '.vortex_as.nc'];
    
    copyfile(Depature,Destination_env)
    copyfile(Depature,Destination_basic)
    copyfile(Depature,Destination_vortex)
    copyfile(Depature,Destination_vortex_ax)
    copyfile(Depature,Destination_vortex_as)
end
end