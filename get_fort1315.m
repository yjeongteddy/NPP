function get_fort1315(tg_tc, tg_NPP, intensity, SeaLevel, nNum, rpath)

addpath(genpath('/home/user_006/08_MATLIB'));

%% Set default inputs
if nargin < 1, tg_tc     = '1215_BOLAVEN'; end
if nargin < 2, tg_NPP    = 'HANBIT'; end
if nargin < 3, intensity = '1.40'; end
if nargin < 4, SeaLevel  = '10exL'; end
if nargin < 5, nNum      = '4'; end
if nargin < 6, rpath     = '/home/user_006/01_WORK/2025/NPP'; end

switch SeaLevel
    case '10exH+SLR'
        subdir = 'MAX';
    case '10exL'
        subdir = 'MIN';
    case 'AHHL'
        subdir = '';
end

spath  = fullfile(rpath, '02_SCRIPT');
opath  = fullfile(rpath, '05_DATA/processed');
dpath  = fullfile(opath, tg_NPP);
wpath  = fullfile(dpath, tg_tc, '12_ADCIRC', subdir, intensity); 
tc_num = extractBefore(tg_tc, '_');

%% Create fort.13
fgs = grd_to_opnml(fullfile(dpath, SeaLevel, 'fort.14'));

cd(wpath)

system(['head -n ' num2str(length(fgs.x)) ' fort.22' ...
    ' > ' 'fort.22_first']);

fort22 = load('fort.22_first');

lth = length(fgs.z);

id_jump = 1;
id_start = lth*(id_jump-1)+1;
id_end   = lth*(id_jump);
target  = fort22(id_start:id_end,4)'*100;

base = 1033; % base: environment pressure
ele = -(target - base)/100;

fid = fopen('fort.13','w');
fprintf(fid, 'Spatial attributes description\n');
fprintf(fid, '%d\n',lth);
fprintf(fid, '%d\n',1);
fprintf(fid, 'sea_surface_height_above_geoid\n');
fprintf(fid, 'm\n');
fprintf(fid, '%d\n',1);
fprintf(fid, '%f\n',0.000000);
fprintf(fid, 'sea_surface_height_above_geoid\n');
fprintf(fid, '%d\n',lth);

for k = 1:lth
    fprintf(fid,'%d %10.6f\n',k,ele(k));
end

fclose(fid);

%% Create a job submit automation script
f_id = 1;
fid(f_id) = fopen(['run_script_' num2str(f_id, '%02i') '.sh'],'w');
fprintf(fid(f_id),'#!/bin/bash\n');

datelist = dir('*.dat');

sdate = datenum(datelist(1).name(1:end-4),'yyyy-mm-dd_HH');
edate = datenum(datelist(end).name(1:end-4),'yyyy-mm-dd_HH');

fprintf(fid,'export TC_INFO=%s_%s_%s\n',tc_num,datestr(sdate,'mmdd'),datestr(edate,'mmdd'));
fprintf(fid,'export RNDAY=%2.4f\n',edate-sdate);
fprintf(fid,'csh ./fort.15.csh\n');
fprintf(fid,['export JOB_NAME=' tc_num '_SSH\n']);
fprintf(fid,['export TC_NUM=' tc_num '\n']);
fprintf(fid,'export NPROCS=96\n');
fprintf(fid,'export ADCIRC_PATH=/home/user_006/06_MODEL\n');
fprintf(fid,['export nNum=' nNum '\n']);
fprintf(fid,['export TGT_TC=' tg_tc '\n']);
fprintf(fid,['export TGT_NPP=' tg_NPP '\n']);
fprintf(fid,['export INTENSITY=' intensity '\n']);
fprintf(fid,['export TGT_SL=' SeaLevel '\n']);
fprintf(fid,['export subdir=' subdir '\n']);
fprintf(fid,['export OPATH=' opath '\n']);
fprintf(fid,'csh spark_adcirc_swan.csh\n');
% fprintf(fid,'sbatch job.sh\n');

fclose all;

%% Create running script
% system(['ln -sf ' fullfile(dpath, SeaLevel, 'fort.14') ' ./']);
% system(['ln -sf ' fullfile(spath, 'fort.15.csh')]);
% system(['ln -sf ' fullfile(spath, 'job_adcirc.csh')]);

system('chmod u+x run_script*');
system('./run_script_01.sh');

end



