function CreateBogusTc(opath, tgt_NPP, tgt_TC, intensifier, numWorkers)
%% Set default values
if nargin < 1, opath       = '/home/user_006/01_WORK/2025/NPP/05_DATA/processed'; end
if nargin < 2, tgt_NPP     = 'SAEUL'; end
if nargin < 3, tgt_TC      = '0314_MAEMI'; end
if nargin < 4, intensifier = 2.03; end
if nargin < 5, numWorkers  = 96; end

%% Setup directories
inputDir  = fullfile(opath, tgt_NPP, tgt_TC, '07_GMSM');

% List target files (assumes filenames end with '00.nc')
mfList = dir(fullfile(inputDir, '*00.nc'));

%% Load RSMC Best Track Data
rs_path = '/data/2.DATA/DATA_SHARE/DATA/RSMC_BEST_TRACK';
bstFile = fullfile(rs_path, 'bst_all.txt');
TRACK = read_RSMC_track_all(bstFile);

%% Find target TC in TRACK (match before underscore)
tc_id = extractBefore(tgt_TC, '_');
find_id = find(arrayfun(@(x) strcmp(x.INT_NUMID, tc_id), TRACK), 1);
if isempty(find_id)
    error('TC with id %s not found in the best track data.', tc_id);
end
TC = TRACK(find_id);

%% Interpolate best track variables on hourly time scale
start_date   = TC.TIME(1);
end_date     = TC.TIME(end);
base_timeVec = TC.TIME;
timeVec      = start_date:1/24:end_date;

INTERP_VALUE.TIME = timeVec;
INTERP_VALUE.MSLP = interp1(base_timeVec, TC.MSLP, timeVec);
INTERP_VALUE.LON  = interp1(base_timeVec, TC.LONGITUDE, timeVec);
INTERP_VALUE.LAT  = interp1(base_timeVec, TC.LATITUDE, timeVec);
INTERP_VALUE.VMAX = interp1(base_timeVec, TC.VMAX_MPS, timeVec);
INTERP_VALUE.R30  = interp1(base_timeVec, TC.R30L, timeVec);
INTERP_VALUE.R50  = interp1(base_timeVec, TC.R50L, timeVec);

% Identify times when the track is within a specified geographic box
x_id = (INTERP_VALUE.LON > 127) & (INTERP_VALUE.LON < 129.5);
y_id = (INTERP_VALUE.LAT > 33.5) & (INTERP_VALUE.LAT < 35.5);
in_id = x_id & y_id;
inc_id = find(in_id);

% Pressure factor sweep values
p_factor = intensifier;

%% Start parallel pool if needed
parpool(numWorkers);

%% Loop over pressure factors and process each file in parallel
for p_id = 1:length(p_factor)
    curr_factor = p_factor(p_id);
    
    outputDir = fullfile(opath, tgt_NPP, tgt_TC, '08_BOGUS', num2str(curr_factor, '%.1f'));
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    parfor m_id = 1:length(mfList)
        % Get full file path for current file
        tgtFile = mfList(m_id).name;
        mf_absPath = fullfile(inputDir, tgtFile);
        
        % Parse base file name (up to last dot) and build related file names
        idx_dot  = strfind(tgtFile, '.');
        baseName = tgtFile(1:idx_dot(end));
        
        orgFile      = fullfile(inputDir, [baseName 'nc']);
        envFile      = fullfile(inputDir, [baseName 'env.nc']);
        vortexASFile = fullfile(inputDir, [baseName 'vortex_as.nc']);
        vortexAXFile = fullfile(inputDir, [baseName 'vortex_ax.nc']);
        vortexFile   = fullfile(inputDir, [baseName 'vortex.nc']);
        
        % Create output file name using identifier from the original name
        tgt_string = char(extractBetween(tgtFile, 'nc_uv_', '.nc'));
        bogusOutFile = fullfile(outputDir, [tgt_string '.nc']);
        
        %% Set parameters from file name and interpolated track data
        dateStr = char(extractBetween(tgtFile, 'd01.', '.nc'));
        met_time = datenum(dateStr, 'yyyy-mm-dd_HH:MM:SS');
        
        % Find closest time index
        [~, time_id] = min(abs(INTERP_VALUE.TIME - met_time));
        
        % Read fields from the original file
        PMSL = ncread(mf_absPath, 'PMSL');
        inside_radius = INTERP_VALUE.R30(time_id) * 1.852 * 1000; % in meters
        TRACK_MINSLP = min(PMSL(:)) / 100;
        TRACK_MAXVEL = INTERP_VALUE.VMAX(time_id) * 0.5144;
        
        % Get latitude and longitude grids
        LON = ncread(mf_absPath, 'XLONG_M');
        LAT = ncread(mf_absPath, 'XLAT_M');
        
        r0 = INTERP_VALUE.R30(time_id) * 1.852 * 1000;
        [mx, my] = find(PMSL == min(PMSL(:)), 1);
        TRACK_LAT = LAT(mx, my);
        TRACK_LON = LON(mx, my);
        
        %% Read additional grid parameters and fields for relocation
        DX = double(ncreadatt(mf_absPath, '/', 'DX'));
        DY = double(ncreadatt(mf_absPath, '/', 'DY'));
        XLAT_M  = ncread(mf_absPath, 'XLAT_M');
        XLONG_M = ncread(mf_absPath, 'XLONG_M');
        PMSL    = ncread(mf_absPath, 'PMSL');
        PMSL_AX = ncread(vortexAXFile, 'PMSL');
        
        % Compute distance and a mask based on a 5.0 threshold
        dist_track = sqrt((XLAT_M - TRACK_LAT).^2 + (XLONG_M - TRACK_LON).^2);
        PMSL_CHECK = (dist_track < 5.0) .* PMSL_AX + (dist_track >= 5.0) * 9999999999;
        
        % Read pressure fields from environment and vortex files
        P_env    = ncread(envFile, 'PMSL') * 0.01;
        P_vortex = ncread(vortexFile, 'PMSL') * 0.01;
        % [row_idx, col_idx] = find(PMSL_CHECK == min(PMSL_CHECK(:)), 1);
        
        % In the original code, the minimum index was set from PMSL itself
        row_idx = mx;
        col_idx = my;
        
        % Calculate pressure factor (then overwrite with sweep factor)
        fac_pres_calc = (TRACK_MINSLP - P_env(row_idx, col_idx)) / P_vortex(row_idx, col_idx);
        fac_pres = curr_factor;
        fac_vel = 1.5;  % Constant factor for velocity
        
        %% Build relocation grid
        [x_meter, y_meter] = meshgrid( -(col_idx-1)*DX:DX:(-col_idx*DX + (size(PMSL,2)+1)*DX), ...
                                       -(row_idx-1)*DY:DY:(-row_idx*DY + (size(PMSL,1)+1)*DY) );
        % Trim grids to match PMSL size
        x_meter = x_meter(1:size(PMSL,1), 1:size(PMSL,2));
        y_meter = y_meter(1:size(PMSL,1), 1:size(PMSL,2));
        dist_center = sqrt(x_meter.^2 + y_meter.^2);
        
        % Find grid point closest to the track location
        TRACK_dist_center = sqrt((TRACK_LAT - XLAT_M).^2 + (TRACK_LON - XLONG_M).^2);
        [center_i, center_j] = find(TRACK_dist_center == min(TRACK_dist_center(:)), 1);
        
        move_i = center_i - row_idx;
        move_j = center_j - col_idx;
        
        %% Load data fields from the original, environment, and vortex files
        ORIGINAL_GHT   = ncread(orgFile, 'GHT');
        ORIGINAL_HGT_M = ncread(orgFile, 'HGT_M');
        ORIGINAL_PSFC  = ncread(orgFile, 'PSFC');
        ORIGINAL_RH    = ncread(orgFile, 'RH');
        ORIGINAL_TT    = ncread(orgFile, 'TT');
        
        ENV_UU   = ncread(envFile, 'UU');
        ENV_VV   = ncread(envFile, 'VV');
        ENV_GHT  = ncread(envFile, 'GHT');
        ENV_RH   = ncread(envFile, 'RH');
        ENV_TT   = ncread(envFile, 'TT');
        ENV_PMSL = ncread(envFile, 'PMSL');
        ENV_PSFC = ncread(envFile, 'PSFC');
        
        VORTEX_UU   = ncread(vortexFile, 'UU');
        VORTEX_VV   = ncread(vortexFile, 'VV');
        VORTEX_GHT  = ncread(vortexFile, 'GHT');
        VORTEX_RH   = ncread(vortexFile, 'RH');
        VORTEX_TT   = ncread(vortexFile, 'TT');
        VORTEX_PMSL = ncread(vortexFile, 'PMSL');
        VORTEX_PSFC = ncread(vortexFile, 'PSFC');
        
        %% Adjust vortex fields with the current pressure factor
        VORTEX_NEW_UU   = VORTEX_UU   * fac_pres;
        VORTEX_NEW_VV   = VORTEX_VV   * fac_pres;
        VORTEX_NEW_GHT  = VORTEX_GHT  * fac_pres;
        VORTEX_NEW_RH   = VORTEX_RH   * fac_pres;
        VORTEX_NEW_TT   = VORTEX_TT   * fac_pres;
        VORTEX_NEW_PMSL = VORTEX_PMSL * fac_pres^2;
        VORTEX_NEW_PSFC = VORTEX_PSFC * fac_pres^2;
        
        %% Initialize bogus fields (starting with environmental fields)
        BOGUS_UU   = ENV_UU;
        BOGUS_VV   = ENV_VV;
        BOGUS_GHT  = ENV_GHT;
        BOGUS_RH   = ENV_RH;
        BOGUS_TT   = ENV_TT;
        BOGUS_PMSL = ENV_PMSL;
        BOGUS_PSFC = ENV_PSFC;
        
        %% Compute relocation weight and apply relocation corrections
        w = exp(- (2*(dist_center - r0)/(0.4*r0)).^2);
        w(dist_center <= (r0/2)) = 0;
        
        [nRows, nCols, ~] = size(VORTEX_NEW_UU);
        for ii = 1:nRows-1
            for jj = 1:nCols-1
                i_move = ii - move_i;
                j_move = jj - move_j;
                if dist_center(ii,jj) > r0, continue; end
                if i_move < 1 || i_move > nRows, continue; end
                if j_move < 1 || j_move > nCols, continue; end
                BOGUS_UU(ii,jj,:)  = ENV_UU(ii,jj,:) + (1 - w(ii,jj)) * VORTEX_NEW_UU(i_move,j_move,:) + w(ii,jj) * VORTEX_UU(i_move,j_move,:);
                BOGUS_VV(ii,jj,:)  = ENV_VV(ii,jj,:) + (1 - w(ii,jj)) * VORTEX_NEW_VV(i_move,j_move,:) + w(ii,jj) * VORTEX_VV(i_move,j_move,:);
                BOGUS_GHT(ii,jj,1) = ORIGINAL_GHT(ii,jj,1);
                BOGUS_GHT(ii,jj,2:end) = ENV_GHT(ii,jj,2:end) + (1 - w(ii,jj)) * VORTEX_NEW_GHT(i_move,j_move,2:end) + w(ii,jj) * VORTEX_GHT(i_move,j_move,2:end);
                BOGUS_TT(ii,jj,:)  = ENV_TT(ii,jj,:) + (1 - w(ii,jj)) * VORTEX_NEW_TT(i_move,j_move,:) + w(ii,jj) * VORTEX_TT(i_move,j_move,:);
                BOGUS_RH(ii,jj,:)  = ENV_RH(ii,jj,:) + (1 - w(ii,jj)) * VORTEX_NEW_RH(i_move,j_move,:) + w(ii,jj) * VORTEX_RH(i_move,j_move,:);
                BOGUS_PMSL(ii,jj)  = ENV_PMSL(ii,jj) + (1 - w(ii,jj)) * VORTEX_NEW_PMSL(i_move,j_move) + w(ii,jj) * VORTEX_PMSL(i_move,j_move);
                BOGUS_PSFC(ii,jj)  = ENV_PSFC(ii,jj) + (1 - w(ii,jj)) * VORTEX_NEW_PSFC(i_move,j_move) + w(ii,jj) * VORTEX_PSFC(i_move,j_move);
            end
        end
        
        %% Write output: copy original file then update fields
        copyfile(mf_absPath, bogusOutFile);
        fileattrib(bogusOutFile, '+w');
        ncid = netcdf.open(bogusOutFile, 'WRITE');
        varid = netcdf.inqVarID(ncid, 'PMSL');
        netcdf.putVar(ncid, varid, BOGUS_PMSL);
        varid = netcdf.inqVarID(ncid, 'PSFC');
        netcdf.putVar(ncid, varid, BOGUS_PSFC);
        varid = netcdf.inqVarID(ncid, 'UU');
        netcdf.putVar(ncid, varid, BOGUS_UU);
        varid = netcdf.inqVarID(ncid, 'VV');
        netcdf.putVar(ncid, varid, BOGUS_VV);
        varid = netcdf.inqVarID(ncid, 'TT');
        netcdf.putVar(ncid, varid, BOGUS_TT);
        varid = netcdf.inqVarID(ncid, 'GHT');
        netcdf.putVar(ncid, varid, BOGUS_GHT);
        varid = netcdf.inqVarID(ncid, 'RH');
        netcdf.putVar(ncid, varid, BOGUS_RH);
        netcdf.close(ncid);
    end
end
end
