clear all;
current_path = pwd;
cd('/data/2.DATA/DATA_SHARE/DATA/RSMC_BEST_TRACK')
RSMC = read_RSMC_track_all('bst_all.txt');
load('/home/user_003/DATA/TC/TC_INFO_1.mat')
cd(current_path)
TC_id = '0711';
count = 1;
for i= 1:length(RSMC)
    for tc_id = 1
        temp_num = RSMC(i).INT_NUMID;
        if length(temp_num) < 1
            continue;end
        check_name = str2num(temp_num) == str2num(TC_id);
        if sum(check_name) > 0
            find_id(count) = i
            count = count+1;
        end
    end
end
    check_id = strcmp(TC_INFO(:,1),num2str(str2num(TC_id)));
    date_temp = str2mat(TC_INFO(check_id,3));
    start_date(i) = datenum(date_temp(1:8),'yymmddHH');
    end_date(i) = datenum(date_temp(end-7:end),'yymmddHH');

%%
for id = 1
    
    % start_id = find(RSMC(find_id(i)).TIME == start_date(i));end_id = find(RSMC(find_id(i)).TIME == end_date(i));
    INTERP_VALUE(id).TIME = [];INTERP_VALUE(id).R30 = [];INTERP_VALUE(id).R50 = [];INTERP_VALUE(id).LON = [];INTERP_VALUE(id).LAT = [];
    INTERP_VALUE(id).VMAX = [];INTERP_VALUE(id).MSLP = [];
    
    for i= 1:length(RSMC(find_id(id)).TIME) -1
        TIME_INTERP = (RSMC(find_id(id)).TIME(i):1/24:RSMC(find_id(id)).TIME(i+1) - 1/24)';
        R30_INTERP = interp1([RSMC(find_id(id)).TIME(i) RSMC(find_id(id)).TIME(i+1)],[RSMC(find_id(id)).R30L(i) RSMC(find_id(id)).R30L(i+1)],TIME_INTERP) ;
        R50_INTERP = interp1([RSMC(find_id(id)).TIME(i) RSMC(find_id(id)).TIME(i+1)],[RSMC(find_id(id)).R50L(i) RSMC(find_id(id)).R50L(i+1)],TIME_INTERP) ;
        LON_INTERP = interp1([RSMC(find_id(id)).TIME(i) RSMC(find_id(id)).TIME(i+1)],[RSMC(find_id(id)).LONGITUDE(i) RSMC(find_id(id)).LONGITUDE(i+1)],TIME_INTERP) ;
        LAT_INTERP = interp1([RSMC(find_id(id)).TIME(i) RSMC(find_id(id)).TIME(i+1)],[RSMC(find_id(id)).LATITUDE(i) RSMC(find_id(id)).LATITUDE(i+1)],TIME_INTERP) ;
        VMAX_INTERP = interp1([RSMC(find_id(id)).TIME(i) RSMC(find_id(id)).TIME(i+1)],[RSMC(find_id(id)).VMAX_KNOT(i) RSMC(find_id(id)).VMAX_KNOT(i+1)],TIME_INTERP) ;
        MSLP_INTERP = interp1([RSMC(find_id(id)).TIME(i) RSMC(find_id(id)).TIME(i+1)],[RSMC(find_id(id)).MSLP(i) RSMC(find_id(id)).MSLP(i+1)],TIME_INTERP) ;
        INTERP_VALUE(id).TIME = [INTERP_VALUE(id).TIME; TIME_INTERP];
        INTERP_VALUE(id).R30 = [INTERP_VALUE(id).R30; R30_INTERP];
        INTERP_VALUE(id).R50 = [INTERP_VALUE(id).R50; R50_INTERP];
        INTERP_VALUE(id).LON = [INTERP_VALUE(id).LON; LON_INTERP];
        INTERP_VALUE(id).LAT = [INTERP_VALUE(id).LAT; LAT_INTERP];
        INTERP_VALUE(id).VMAX = [INTERP_VALUE(id).VMAX; VMAX_INTERP];
        INTERP_VALUE(id).MSLP = [INTERP_VALUE(id).MSLP; MSLP_INTERP];
    end
end

%%
list = dir('nc_uv_*met_em*00.nc');
circ_id = 20;
LON = ncread(list(1).name,'XLONG_M');
LAT = ncread(list(1).name,'XLAT_M');
%%
count = 1;
for s_id = 1:ceil(length(list)./circ_id)
fid = fopen(['run_decomp_' num2str(s_id,'%02d') '.sh'],'w')
fprintf(fid,'#!/bin/bash\n');

for i= count:count+20
    str_id = findstr(list(i).name,'.');
    met_time = datenum(list(i).name(str_id(2)+1:str_id(3)-1),'yyyy-mm-dd_HH:MM:SS');
    time_id = find(abs(INTERP_VALUE.TIME - met_time) == min(abs(INTERP_VALUE.TIME - met_time)));
    R30 = INTERP_VALUE.R30(time_id).*1.852;
    if R30 < 1
        R30 = 300;
    end

    PMSL = ncread(list(i).name,'PMSL');
    track_lon = INTERP_VALUE.LON(time_id);
    track_lat = INTERP_VALUE.LAT(time_id);
    x_id = and(LON >track_lon - 5,LON < track_lon + 5);
    y_id = and(LAT >track_lat - 5,LAT < track_lat + 5);
    in_id = and(x_id,y_id);
    FIND_MIN_PMSL = PMSL;
    FIND_MIN_PMSL(~in_id) = 9*10^10;
    MINP  = min(min(FIND_MIN_PMSL(in_id)));
    [I,J] = find(FIND_MIN_PMSL == MINP);
    TC_X = LON(I,J);
    TC_Y = LAT(I,J);
    fprintf(fid,'export file_name=%s\n',list(i).name);
    fprintf(fid,'export filter_name=%s\n',['filter_' datestr(met_time,'yymmddHH') '.ncl']);
%     
%     system(['cp ' list(i).name ' ' list(i).name(1:end-3) '.vortex.nc &']);
%     system(['cp ' list(i).name ' ' list(i).name(1:end-3) '.env.nc &']);
%     system(['cp ' list(i).name ' ' list(i).name(1:end-3) '.basic.nc &']);
%     system(['cp ' list(i).name ' ' list(i).name(1:end-3) '.vortex_as.nc &']);
%     system(['cp ' list(i).name ' ' list(i).name(1:end-3) '.vortex_ax.nc &']);

    fprintf(fid,'export file_name_vortex=%s\n',[list(i).name(1:end-3) '.vortex.nc']);
    fprintf(fid,'export file_name_env=%s\n',[list(i).name(1:end-3) '.env.nc']);
    fprintf(fid,'export file_name_basic=%s\n',[list(i).name(1:end-3) '.basic.nc']);
    fprintf(fid,'export file_name_vortex_as=%s\n',[list(i).name(1:end-3) '.vortex_as.nc']);
    fprintf(fid,'export file_name_vortex_ax=%s\n',[list(i).name(1:end-3) '.vortex_ax.nc']);

    
    fprintf(fid,'export TC_i=%d\n',I);
    fprintf(fid,'export TC_j=%d\n',J);
    fprintf(fid,'export TC_lat=%.4f\n',TC_Y);
    fprintf(fid,'export TC_lon=%.4f\n',TC_X);
    fprintf(fid,'export R0=%d\n',R30*1000);
    system(['cp filter.ncl ' 'filter_' datestr(met_time,'yymmddHH') '.ncl'])

    fprintf(fid,'csh ./filter_csh2.csh\n');
    fprintf(fid,['ncl ' 'filter_' datestr(met_time,'yymmddHH') '.ncl &\n']);
    count = count+1;
    if i == 20
        disp('NEXT_SCRIPT.\n')
        break;end;
end
fclose all;
end

