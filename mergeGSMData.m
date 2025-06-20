function mergeGSMData(tg_tc, tg_NPP, opath, rpath, ppath, spath)
% merge_nc_data Merges NetCDF fields from JMA-MSM and WRF GSM files.
%
%   merge_nc_data(tg_tc, opath) reads the NetCDF files located in the
%   following subdirectories relative to opath:
%
%       [opath '/JMA-MSM-P/' tg_tc '/']
%       [opath '/JMA-MSM-S/' tg_tc '/']
%       [opath '/WRF/' tg_tc '/04_METGRID/']
%
%   It then performs interpolation and blending of fields from the 
%   various datasets and writes new merged NetCDF files (prefixed with 
%   'nc_uv_merge_').
%
%   INPUTS:
%       tg_tc  - (string) Target tropical cyclone code (e.g., '0314_MAEMI')
%       tg_NPP - (string) Target Nuclear Power Plant (e.g., 'SAEUL')
%       opath  - (string) The path to the original directory
%       rpath  - (string) The path to raw datasets
%       ppath  - (string) The path to processed datasets
%       spath  - (string) The path to saving datasets
%
%   Example:
%       merge_nc_data('0314_MAEMI', 'SAEUL', '/home/user_006/01_WORK/2025/NPP/05_DATA/raw/')
%
%   NOTE: This function requires the ETC_DATA.mat file (with fields
%         pres, lon, lat) to be present in the same folder as the 
%         JMA-MSM-P NetCDF files.

% Set default inputs if not provided
if nargin < 1, tg_tc  = '2211_HINNAMNOR'; end
if nargin < 2, tg_NPP = 'SAEUL'; end
if nargin < 3, opath  = '/home/user_006/01_WORK/2025/NPP/05_DATA/'; end
if nargin < 4, rpath  = fullfile(opath, 'raw'); end
if nargin < 5, ppath  = fullfile(opath, 'processed'); end
if nargin < 6, spath  = fullfile(ppath, tg_NPP, tg_tc, '07_GMSM'); end

% Add path for additional MATLAB libraries (if needed)
addpath(genpath('/home/user_006/08_MATLIB'));

%% Target year
yearVal = extractYear(tg_tc);
from_ncep = yearVal < 2004;

%% Target dir
gsmList  = dir(fullfile(ppath, tg_NPP, tg_tc, '04_METGRID', 'met_em*'));
msmpList = dir(fullfile(ppath, tg_NPP, tg_tc, '05_MSM-P', '*.nc'));
msmsList = dir(fullfile(ppath, tg_NPP, tg_tc, '06_MSM-S', '*.nc'));
raw_msmpList  = dir(fullfile(rpath, 'JMA-MSM-P', tg_tc, '*.nc'));

%% Load coordinate fields from MSM-P dataset
tgt_raw_msmpfile = fullfile(raw_msmpList(1).folder,raw_msmpList(1).name);

plevel_p = ncread(tgt_raw_msmpfile,'p');
lon_p  = ncread(tgt_raw_msmpfile,'lon');
lat_p  = ncread(tgt_raw_msmpfile,'lat');

%% Read coordinate fields from MSM-S dataset
tgt_raw_msmsFile = fullfile(msmsList(1).folder, msmsList(1).name);
lon_s = double(ncread(tgt_raw_msmsFile, 'lon'));
lat_s = double(ncread(tgt_raw_msmsFile, 'lat'));

%% Read coordinate fields from GSM dataset
tgt_prc_gsmFile = fullfile(gsmList(1).folder, gsmList(1).name);
lon_gsm    = double(ncread(tgt_prc_gsmFile, 'XLONG_M'));
lat_gsm    = double(ncread(tgt_prc_gsmFile, 'XLAT_M'));
plevel_gsm = double(ncread(tgt_prc_gsmFile, 'PRES'));

%% Compute GSM pressure levels from the minimum pressure at each level
prs_gsm = squeeze(min(min(plevel_gsm,[],1),[],2))' / 100;
% SIZE_GP = size(plevel_gsm);
% prs_gsm = zeros(1, SIZE_GP(3));
% for p_id = 1:SIZE_GP(3)
%     prs_gsm(p_id) = min(min(plevel_gsm(:,:,p_id))) ./ 100;
% end

%% Read additional GSM grid coordinates for U and V
lon_gu = double(ncread(tgt_prc_gsmFile, 'XLONG_U'));
lat_gu = double(ncread(tgt_prc_gsmFile, 'XLAT_U'));
lon_gv = double(ncread(tgt_prc_gsmFile, 'XLONG_V'));
lat_gv = double(ncread(tgt_prc_gsmFile, 'XLAT_V'));

%% Pre-compute interpolation grids and blending weights (constants over time)
jma_xs = min(lon_p) + 0.5;
jma_xe = max(lon_p) - 0.5;
jma_ys = min(lat_p) + 0.5;
jma_ye = max(lat_p) - 0.5;
[p_lon_mat, p_lat_mat] = meshgrid(lon_p', lat_p');
[s_lon_mat, s_lat_mat] = meshgrid(lon_s', lat_s');

B_length = 3;
B_left   = tanh((lon_gsm - jma_xs - B_length/2)  * pi/(B_length/2)) / 2 + 0.5;
B_right  = tanh(-(lon_gsm - jma_xe + B_length/2) * pi/(B_length/2)) / 2 + 0.5;
B_bottom = tanh((lat_gsm - jma_ys - B_length/2)  * pi/(B_length/2)) / 2 + 0.5;
B_top    = tanh(-(lat_gsm - jma_ye + B_length/2) * pi/(B_length/2)) / 2 + 0.5;
B = min(min(B_left, B_right), min(B_bottom, B_top));

% Blending weights for U component (on GU grid)
Bu_left   = tanh((lon_gu - jma_xs - B_length/2)  * pi/(B_length/2)) / 2 + 0.5;
Bu_right  = tanh(-(lon_gu - jma_xe + B_length/2) * pi/(B_length/2)) / 2 + 0.5;
Bu_bottom = tanh((lat_gu - jma_ys - B_length/2)  * pi/(B_length/2)) / 2 + 0.5;
Bu_top    = tanh(-(lat_gu - jma_ye + B_length/2) * pi/(B_length/2)) / 2 + 0.5;
B_u = min(min(Bu_left, Bu_right), min(Bu_bottom, Bu_top));

% Blending weights for V component (on GV grid)
Bv_left   = tanh((lon_gv - jma_xs - B_length/2)  * pi/(B_length/2)) / 2 + 0.5;
Bv_right  = tanh(-(lon_gv - jma_xe + B_length/2) * pi/(B_length/2)) / 2 + 0.5;
Bv_bottom = tanh((lat_gv - jma_ys - B_length/2)  * pi/(B_length/2)) / 2 + 0.5;
Bv_top    = tanh(-(lat_gv - jma_ye + B_length/2) * pi/(B_length/2)) / 2 + 0.5;
B_v = min(min(Bv_left, Bv_right), min(Bv_bottom, Bv_top));

%% Change directory to GSM folder and set analysis hours
cd(gsmList(1).folder);

%% Start parallel pool if not already running
parpool(96);

%% Loop over each GSM file (each analysis time)
parfor met_id = 1:length(gsmList)
    tgt_prc_gsmFile = fullfile(gsmList(met_id).folder, gsmList(met_id).name);
    pattern = 'met_em\.d01\.(\d{4}-\d{2}-\d{2}_\d{2}:\d{2}:\d{2})';
    met_time = datenum(string(regexp(tgt_prc_gsmFile, pattern, 'tokens')));
    
    % Construct corresponding file names for the other datasets
    tgt_raw_msmpFile = fullfile(msmpList(1).folder, [datestr(met_time, 'mmdd')       '.nc']);
    tgt_prc_msmpFile = fullfile(msmpList(1).folder, [datestr(met_time, 'yyyymmddHH') '.nc']);
    tgt_raw_msmsFile = fullfile(msmsList(1).folder, [datestr(met_time, 'mmdd')       '.nc']);
    s_hour = str2double(datestr(met_time, 'HH')) + 1;
    
    % Read variables from the NetCDF files
    NC_ph_rh  = double(ncread(tgt_prc_msmpFile, 'rh'));
    NC_p_rh   = double(ncread(tgt_raw_msmpFile, 'rh'));
    NC_s_rh   = double(ncread(tgt_raw_msmsFile, 'rh'));
    GSM_rh    = double(ncread(tgt_prc_gsmFile, 'RH'));
    
    NC_ph_ght = double(ncread(tgt_prc_msmpFile, 'ght'));
    NC_p_ght  = double(ncread(tgt_raw_msmpFile, 'z'));
    GSM_ght   = double(ncread(tgt_prc_gsmFile, 'GHT'));
    
    if from_ncep
        NC_ph_tt  = double(ncread(tgt_prc_msmpFile, 'tt'))   + 273.15;
        NC_p_tt   = double(ncread(tgt_raw_msmpFile, 'temp')) + 273.15;
        NC_s_tt   = double(ncread(tgt_raw_msmsFile, 'temp')) + 273.15;
        GSM_tt    = double(ncread(tgt_prc_gsmFile, 'TT'));
    else
        NC_ph_tt  = double(ncread(tgt_prc_msmpFile, 'tt'));
        NC_p_tt   = double(ncread(tgt_raw_msmpFile, 'temp'));
        NC_s_tt   = double(ncread(tgt_raw_msmsFile, 'temp'));
        GSM_tt    = double(ncread(tgt_prc_gsmFile, 'TT'));
    end
    
    NC_ph_u   = double(ncread(tgt_prc_msmpFile, 'u'));
    NC_p_u    = double(ncread(tgt_raw_msmpFile, 'u'));
    NC_s_u    = double(ncread(tgt_raw_msmsFile, 'u'));
    GSM_u     = double(ncread(tgt_prc_gsmFile, 'UU'));
    
    NC_ph_v   = double(ncread(tgt_prc_msmpFile, 'v'));
    NC_p_v    = double(ncread(tgt_raw_msmpFile, 'v'));
    NC_s_v    = double(ncread(tgt_raw_msmsFile, 'v'));
    GSM_v     = double(ncread(tgt_prc_gsmFile, 'VV'));
    
    if from_ncep
        NC_pmsl  = double(ncread(tgt_raw_msmsFile, 'psea')).*100;
    else
        NC_pmsl  = double(ncread(tgt_raw_msmsFile, 'psea'));
        NC_psfc  = double(ncread(tgt_raw_msmsFile, 'sp'));
    end
    GSM_pmsl = double(ncread(tgt_prc_gsmFile, 'PMSL'));
    GSM_psfc = double(ncread(tgt_prc_gsmFile, 'PSFC'));
    
    % Interpolate pmsl and psfc from the surface data and blend with GSM
    intp_pmsl = griddata(double(s_lon_mat), double(s_lat_mat), NC_pmsl(:,:,s_hour)', lon_gsm, lat_gsm);
    intp_pmsl(isnan(intp_pmsl)) = 0;
    NS_GSM_pmsl = B .* intp_pmsl + (1 - B) .* GSM_pmsl;
    
    if from_ncep
        NS_GSM_psfc = GSM_psfc;
    else
        intp_psfc = griddata(double(s_lon_mat), double(s_lat_mat), NC_psfc(:,:,s_hour)', lon_gsm, lat_gsm);
        intp_psfc(isnan(intp_psfc)) = 0;
        NS_GSM_psfc = B .* intp_psfc + (1 - B) .* GSM_psfc;
    end
    
    if from_ncep
        prs_surf = 1;
        
        intp_su = griddata(s_lon_mat,s_lat_mat,NC_s_u(:,:,s_hour)',lon_gu,lat_gu);
        nan_id = isnan(intp_su);
        intp_su(nan_id) = 0;
        NS_GSM_su = B_u.*(intp_su)+(1-B_u).*GSM_u(:,:,1);
        
        intp_sv = griddata(s_lon_mat,s_lat_mat,NC_s_v(:,:,s_hour)',lon_gv,lat_gv);
        nan_id = isnan(intp_sv);
        intp_sv(nan_id) = 0;
        NS_GSM_sv = B_v.*(intp_sv)+(1-B_v).*GSM_v(:,:,1);
        
        intp_srh = griddata(s_lon_mat,s_lat_mat,NC_s_rh(:,:,s_hour)',lon_gsm,lat_gsm);
        nan_id = isnan(intp_srh);
        intp_srh(nan_id) = 0;
        NS_GSM_srh = B.*(intp_srh)+(1-B).*GSM_rh(:,:,1);
        
        intp_stt = griddata(s_lon_mat,s_lat_mat,NC_s_tt(:,:,s_hour)',lon_gsm,lat_gsm);
        nan_id = isnan(intp_stt);
        intp_stt(nan_id) = 0;
        NS_GSM_stt = B.*(intp_stt)+(1-B).*GSM_tt(:,:,1);
        
        GSM_u(:,:,prs_surf) =  NS_GSM_su;
        GSM_v(:,:,prs_surf) =  NS_GSM_sv;
        GSM_rh(:,:,prs_surf) = NS_GSM_srh;
        GSM_tt(:,:,prs_surf) = NS_GSM_stt;
        
        GSM_u(:,:,prs_surf+1) =  NS_GSM_su;
        GSM_v(:,:,prs_surf+1) =  NS_GSM_sv;
        GSM_rh(:,:,prs_surf+1) = NS_GSM_srh;
        GSM_tt(:,:,prs_surf+1) = NS_GSM_stt;
        
        for idx_prs = prs_surf+2:length(plevel_p)-1
            tgt_prs = prs_gsm(idx_prs);
            [~, idx_closest] = min(abs(tgt_prs - plevel_p));
            if plevel_p(idx_closest) == tgt_prs
                u_final   = NC_ph_u(:,:,idx_closest);
                v_final   = NC_ph_v(:,:,idx_closest);
                rh_final  = NC_ph_rh(:,:,idx_closest);
                ght_final = NC_ph_ght(:,:,idx_closest);
                tt_final  = NC_ph_tt(:,:,idx_closest);

            elseif plevel_p(idx_closest) > tgt_prs
                before_p    = plevel_p(idx_closest);
                after_p     = plevel_p(idx_closest + 1);
                before_id   = find(plevel_p == before_p);
                after_id    = find(plevel_p == after_p);
                after_rate  = (tgt_prs - before_p) / (after_p - before_p);
                before_rate = 1 - after_rate;
                
                U1 = NC_ph_u(:,:,before_id);
                U2 = NC_ph_u(:,:,after_id);
                V1 = NC_ph_v(:,:,before_id);
                V2 = NC_ph_v(:,:,after_id);
                RH1 = NC_ph_rh(:,:,before_id);
                RH2 = NC_ph_rh(:,:,after_id);
                GHT1 = NC_ph_ght(:,:,before_id);
                GHT2 = NC_ph_ght(:,:,after_id);
                TT1 = NC_ph_tt(:,:,before_id);
                TT2 = NC_ph_tt(:,:,after_id);

                u_final = U1.*before_rate + U2.*after_rate;
                v_final = V1.*before_rate + V2.*after_rate;
                rh_final = RH1.*before_rate + RH2.*after_rate;
                ght_final = GHT1.*before_rate + GHT2.*after_rate;
                tt_final = TT1.*before_rate + TT2.*after_rate;

            else  % plevel_p(idx_closest) < tgt_prs
                before_p    = plevel_p(idx_closest);
                after_p     = plevel_p(idx_closest - 1);
                before_id   = find(plevel_p == before_p);
                after_id    = find(plevel_p == after_p);
                after_rate  = (tgt_prs - before_p) / (after_p - before_p);
                before_rate = 1 - after_rate;
                
                U1 = NC_ph_u(:,:,before_id);
                U2 = NC_ph_u(:,:,after_id);
                V1 = NC_ph_v(:,:,before_id);
                V2 = NC_ph_v(:,:,after_id);
                RH1 = NC_ph_rh(:,:,before_id);
                RH2 = NC_ph_rh(:,:,after_id);
                GHT1 = NC_ph_ght(:,:,before_id);
                GHT2 = NC_ph_ght(:,:,after_id);
                TT1 = NC_ph_tt(:,:,before_id);
                TT2 = NC_ph_tt(:,:,after_id);

                u_final = U1.*before_rate + U2.*after_rate;
                v_final = V1.*before_rate + V2.*after_rate;
                rh_final = RH1.*before_rate + RH2.*after_rate;
                ght_final = GHT1.*before_rate + GHT2.*after_rate;
                tt_final = TT1.*before_rate + TT2.*after_rate;
            end
            
            intp_u = griddata(double(p_lon_mat),double(p_lat_mat),double(u_final)',lon_gu,lat_gu);
            nan_id = isnan(intp_u);
            intp_u(nan_id) = 0;
            intp_v = griddata(double(p_lon_mat),double(p_lat_mat),double(v_final)',lon_gv,lat_gv);
            nan_id = isnan(intp_v);
            intp_v(nan_id) = 0;
            intp_tt = griddata(double(p_lon_mat),double(p_lat_mat),double(tt_final)',lon_gsm,lat_gsm);
            nan_id = isnan(intp_tt);
            intp_tt(nan_id) = 0;
            intp_ght = griddata(double(p_lon_mat),double(p_lat_mat),double(ght_final)',lon_gsm,lat_gsm);
            nan_id = isnan(intp_ght);
            intp_ght(nan_id) = 0;
            intp_rh = griddata(double(p_lon_mat),double(p_lat_mat),double(rh_final)',lon_gsm,lat_gsm);
            nan_id = isnan(intp_rh);
            intp_rh(nan_id) = 0;
            
            NS_GSM_u = B_u.*(intp_u)+(1-B_u).*GSM_u(:,:,idx_prs);
            nan_id = isnan(NS_GSM_u);
            NS_GSM_u(nan_id) = 0;

            NS_GSM_v = B_v.*(intp_v)+(1-B_v).*GSM_v(:,:,idx_prs);
            nan_id = isnan(NS_GSM_v);
            NS_GSM_v(nan_id) = 0;
            
            if mode(mode(gradient(rh_final))) == 0
                NS_GSM_rh = GSM_rh(:,:,idx_prs);
            else
                NS_GSM_rh = B.*(intp_rh)+(1-B).*GSM_rh(:,:,idx_prs);
            end
            nan_id = isnan(NS_GSM_rh);
            NS_GSM_rh(nan_id) = 0;
            
            NS_GSM_ght = B.*(intp_ght)+(1-B).*GSM_ght(:,:,idx_prs);
            nan_id = isnan(NS_GSM_ght);
            NS_GSM_ght(nan_id) = 0;
            
            NS_GSM_tt = B.*(intp_tt)+(1-B).*GSM_tt(:,:,idx_prs);
            nan_id = isnan(NS_GSM_tt);
            NS_GSM_tt(nan_id) = 0;
            
            GSM_u(:,:,idx_prs) =  NS_GSM_u;
            GSM_v(:,:,idx_prs) =  NS_GSM_v;
            GSM_rh(:,:,idx_prs) = NS_GSM_rh;
            GSM_tt(:,:,idx_prs) = NS_GSM_tt;
            GSM_ght(:,:,idx_prs) = NS_GSM_ght;
        end
    else % GSM from JMA
        % Loop over pressure levels
        for idx_prs = 1:length(plevel_p)
            tgt_prs = plevel_p(idx_prs);
            idx_closest = find(tgt_prs == prs_gsm);
            if idx_prs == 1
                % First level: blend surface (S) data with GSM fields
                intp_su = griddata(s_lon_mat, s_lat_mat, NC_s_u(:,:,s_hour)', lon_gu, lat_gu);
                intp_su(isnan(intp_su)) = 0;
                NS_GSM_su = B_u .* intp_su + (1 - B_u) .* GSM_u(:,:,idx_prs);
                
                intp_sv = griddata(s_lon_mat, s_lat_mat, NC_s_v(:,:,s_hour)', lon_gv, lat_gv);
                intp_sv(isnan(intp_sv)) = 0;
                NS_GSM_sv = B_v .* intp_sv + (1 - B_v) .* GSM_v(:,:,idx_prs);
                
                intp_srh = griddata(s_lon_mat, s_lat_mat, NC_s_rh(:,:,s_hour)', lon_gsm, lat_gsm);
                intp_srh(isnan(intp_srh)) = 0;
                NS_GSM_srh = B .* intp_srh + (1 - B) .* GSM_rh(:,:,idx_prs);
                
                intp_stt = griddata(s_lon_mat, s_lat_mat, NC_s_tt(:,:,s_hour)', lon_gsm, lat_gsm);
                intp_stt(isnan(intp_stt)) = 0;
                NS_GSM_stt = B .* intp_stt + (1 - B) .* GSM_tt(:,:,idx_prs);
                
                GSM_u(:,:,idx_prs)  = NS_GSM_su;
                GSM_v(:,:,idx_prs)  = NS_GSM_sv;
                GSM_rh(:,:,idx_prs) = NS_GSM_srh;
                GSM_tt(:,:,idx_prs) = NS_GSM_stt;
            
            % If the found level index has two elements, use an alternate blending
            elseif numel(idx_closest) == 2
                intp_u = intp_su;
                intp_v = intp_sv;
                clf; p = pcolor(NC_p_rh(:,:,12,1)); set(p,'EdgeColor','None'); colorbar()
                intp_tt = griddata(double(p_lon_mat), double(p_lat_mat), NC_ph_tt(:,:,idx_prs)', lon_gsm, lat_gsm);
                intp_tt(isnan(intp_tt)) = 0;
                intp_ght = griddata(double(p_lon_mat), double(p_lat_mat), NC_ph_ght(:,:,idx_prs)', lon_gsm, lat_gsm);
                intp_ght(isnan(intp_ght)) = 0;
                intp_rh = griddata(double(p_lon_mat), double(p_lat_mat), NC_ph_rh(:,:,idx_prs)', lon_gsm, lat_gsm);
                intp_rh(isnan(intp_rh)) = 0;
                
                NS_GSM_u = B_u .* intp_u + (1 - B_u) .* GSM_u(:,:,idx_closest);
                NS_GSM_u(isnan(NS_GSM_u)) = 0;
                
                NS_GSM_v = B_v .* intp_v + (1 - B_v) .* GSM_v(:,:,idx_closest);
                NS_GSM_v(isnan(NS_GSM_v)) = 0;
                
                NS_GSM_rh = B .* intp_rh + (1 - B) .* GSM_rh(:,:,idx_closest);
                NS_GSM_rh(isnan(NS_GSM_rh)) = 0;
                
                NS_GSM_ght = B .* intp_ght + (1 - B) .* GSM_ght(:,:,idx_closest);
                NS_GSM_ght(isnan(NS_GSM_ght)) = 0;
                
                NS_GSM_tt = B .* intp_tt + (1 - B) .* GSM_tt(:,:,idx_closest);
                NS_GSM_tt(isnan(NS_GSM_tt)) = 0;
                
                GSM_u(:,:,idx_closest)   = NS_GSM_u;
                GSM_v(:,:,idx_closest)   = NS_GSM_v;
                GSM_rh(:,:,idx_closest)  = NS_GSM_rh;
                GSM_tt(:,:,idx_closest)  = NS_GSM_tt;
                GSM_ght(:,:,idx_closest) = NS_GSM_ght;
            
            else % Otherwise, use the standard blending for this level
                intp_u   = griddata(double(p_lon_mat), double(p_lat_mat), NC_ph_u(:,:,idx_prs)',   lon_gu, lat_gu);
                intp_u(isnan(intp_u))     = 0;
                intp_v   = griddata(double(p_lon_mat), double(p_lat_mat), NC_ph_v(:,:,idx_prs)',   lon_gv, lat_gv);
                intp_v(isnan(intp_v))     = 0;
                intp_tt  = griddata(double(p_lon_mat), double(p_lat_mat), NC_ph_tt(:,:,idx_prs)',  lon_gsm, lat_gsm);
                intp_tt(isnan(intp_tt))   = 0;
                intp_ght = griddata(double(p_lon_mat), double(p_lat_mat), NC_ph_ght(:,:,idx_prs)', lon_gsm, lat_gsm);
                intp_ght(isnan(intp_ght)) = 0;
                intp_rh  = griddata(double(p_lon_mat), double(p_lat_mat), NC_ph_rh(:,:,idx_prs)',  lon_gsm, lat_gsm);
                intp_rh(isnan(intp_rh))   = 0;
                
                NS_GSM_u = B_u .* intp_u + (1 - B_u) .* GSM_u(:,:,idx_closest);
                NS_GSM_u(isnan(NS_GSM_u)) = 0;
                
                NS_GSM_v = B_v .* intp_v + (1 - B_v) .* GSM_v(:,:,idx_closest);
                NS_GSM_v(isnan(NS_GSM_v)) = 0;
                
                NS_GSM_rh = B .* intp_rh + (1 - B) .* GSM_rh(:,:,idx_closest);
                NS_GSM_rh(isnan(NS_GSM_rh)) = 0;
                
                NS_GSM_ght = B .* intp_ght + (1 - B) .* GSM_ght(:,:,idx_closest);
                NS_GSM_ght(isnan(NS_GSM_ght)) = 0;
                
                NS_GSM_tt = B .* intp_tt + (1 - B) .* GSM_tt(:,:,idx_closest);
                NS_GSM_tt(isnan(NS_GSM_tt)) = 0;
                
                GSM_u(:,:,idx_closest)   = NS_GSM_u;
                GSM_v(:,:,idx_closest)   = NS_GSM_v;
                GSM_rh(:,:,idx_closest)  = NS_GSM_rh;
                GSM_tt(:,:,idx_closest)  = NS_GSM_tt;
                GSM_ght(:,:,idx_closest) = NS_GSM_ght;
            end
        end
    end
    
    % Create the new merged NetCDF file by copying the original file
    new_name = fullfile(spath, ['nc_uv_merge_' gsmList(met_id).name]);
    copyfile(which(gsmList(met_id).name), new_name);
    fileattrib(new_name, '+w');
    ncid = netcdf.open(new_name, 'WRITE');
    varid = netcdf.inqVarID(ncid, 'PMSL');
    netcdf.putVar(ncid, varid, NS_GSM_pmsl);
    if ~ from_ncep
        varid = netcdf.inqVarID(ncid, 'PSFC');
        netcdf.putVar(ncid, varid, NS_GSM_psfc);
    end
    varid = netcdf.inqVarID(ncid, 'UU');
    netcdf.putVar(ncid, varid, GSM_u);
    varid = netcdf.inqVarID(ncid, 'VV');
    netcdf.putVar(ncid, varid, GSM_v);
    varid = netcdf.inqVarID(ncid, 'TT');
    netcdf.putVar(ncid, varid, GSM_tt);
    varid = netcdf.inqVarID(ncid, 'GHT');
    netcdf.putVar(ncid, varid, GSM_ght);
    varid = netcdf.inqVarID(ncid, 'RH');
    netcdf.putVar(ncid, varid, GSM_rh);
    varid = netcdf.inqVarID(ncid, 'PRES');
    netcdf.putVar(ncid, varid, plevel_gsm);
    
    netcdf.close(ncid);
end
end

%% Helper Function: Extract Year from target case string
function yearVal = extractYear(tg_tc)
% Extracts a year from the target case string. This version first looks for 
% any numeric substring. (Adjust this logic as needed.)
tc_num = extractBefore(tg_tc, '_');
raw_year = str2double(tc_num(1:2));
if raw_year < 50
    yearVal = raw_year + 2000;
else
    yearVal = raw_year + 1900;
end
end

%% Dummy
% if i_level == 1
%     % Determine the closest hour for the p-level data interpolation
%     [~, idx] = min(abs(str2double(datestr(met_time, 'HH')) - p_hour));
%     find_hour = idx;
%     
%     ap_u = griddata(double(p_lon_mat), double(p_lat_mat), NC_p_u(:,:,i_level,find_hour)', lon_gu, lat_gu);
%     ap_u(isnan(ap_u)) = 0;
%     ap_v = griddata(double(p_lon_mat), double(p_lat_mat), NC_p_v(:,:,i_level,find_hour)', lon_gv, lat_gv);
%     ap_v(isnan(ap_v)) = 0;
%     ap_tt = griddata(double(p_lon_mat), double(p_lat_mat), NC_p_tt(:,:,find_hour)', lon_gsm, lat_gsm);
%     ap_tt(isnan(ap_tt)) = 0;
%     ap_ght = griddata(double(p_lon_mat), double(p_lat_mat), NC_p_ght(:,:,i_level,find_hour)', lon_gsm, lat_gsm);
%     ap_ght(isnan(ap_ght)) = 0;
%     ap_rh = griddata(double(p_lon_mat), double(p_lat_mat), NC_p_rh(:,:,i_level,find_hour)', lon_gsm, lat_gsm);
%     ap_rh(isnan(ap_rh)) = 0;
% end
