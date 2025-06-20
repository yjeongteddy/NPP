function PostSWAN(tgt_tc, tgt_NPP, intensity, SeaLevel, tc_int, rpath)

addpath(genpath('/home/user_006/08_MATLIB'))

%% Parameters
if nargin < 1, tgt_tc    = '0314_MAEMI'; end
if nargin < 2, tgt_NPP   = 'SAEUL'; end
if nargin < 3, intensity = '2.03-10'; end
if nargin < 4, SeaLevel  = '10exH+SLR'; end
if nargin < 5, tc_int    = '29%'; end
if nargin < 6, rpath     = '/home/user_006/01_WORK/2025/NPP'; end

switch SeaLevel
    case '10exH+SLR'
        subdir = 'MAX';
    case '10exL'
        subdir = 'MIN';
    case 'AHHL'
        subdir = '';
end

opath = fullfile(rpath, '05_DATA/processed');
dpath = fullfile(opath, tgt_NPP);
wpath = fullfile(dpath, tgt_tc, '10_SWAN', subdir, intensity);
fpath = fullfile(rpath, '04_FIGURE');
spath = fullfile(fpath, tgt_NPP, tgt_tc, 'HS', subdir, intensity);
if ~exist(spath, 'dir'), mkdir(spath); end

%% Load universal params
% depth
fgs = grd_to_opnml(fullfile(dpath, SeaLevel, 'fort.14'));

% output file
cd(wpath)
load('RESULT.mat')
MaxHs = RESULT.MAX_HS;

% suffix of translation speed
if contains(intensity,'+10')
    tc_vel = '+10%';
elseif contains(intensity,'-10')
    tc_vel = '-10%';
else
    tc_vel = '0%';
end

%% Do the work (Large area)
xs = 120; xe = 140; ys = 25; ye = 45; % Large area

clf;hold on;set(gcf,'position',[275 -3 1429 993]);
colormesh2d(fgs,MaxHs); axis equal; c = colorbar(); colormap(jet); clim([0 15]); ax = gca;
xlabel('Longitude (^oE)');
ylabel('Latitude (^oN)');
xlim([xs xe]); ylim([ys ye]);
set(gca,'FontSize',25);
set(gca,'Box','on');
set(gca,'LineWidth',3);
set(gcf,'Color','w');
set(gca,'Color',[239 220 185]/255);
set(gcf, 'InvertHardcopy', 'off');

print(gcf, fullfile(spath, 'HS_Large.png'), '-dpng', '-r300');

%% Do the work (Small area)
% load coastline data
COAST = load('/home/user_006/03_DATA/NEW_KR_Coastline_230206.mat').NEW_KR;
xs = 129.29; xe = 129.36; ys = 35.29; ye = 35.36;
toRemove = arrayfun(@(c) any(c.X > xs & c.X < xe & c.Y > ys & c.Y < ye) && (length(c.X) < 200), COAST);
N_C = COAST(~toRemove);

% create target mesh grid
x_vec = xs:0.0001:xe;
y_vec = ys:0.0001:ye;
[x_mat,y_mat] = meshgrid(x_vec, y_vec);

% interpolate HS values
HS_INTP = griddata(fgs.x(~isnan(MaxHs)),fgs.y(~isnan(MaxHs)), ...
    double(MaxHs(~isnan(MaxHs))),x_mat,y_mat,'linear');

% interpolate PDIR values
D_TEMP = RESULT.MAX_PDIR;
u_mat = cosd(D_TEMP);
v_mat = sind(D_TEMP);
u_interp = griddata(fgs.x,fgs.y,double(u_mat),x_mat,y_mat);
v_interp = griddata(fgs.x,fgs.y,double(v_mat),x_mat,y_mat);

% plot them
clf;hold on;set(gcf,'position',[310 -3 1376 993]);
h = pcolor(x_mat, y_mat, HS_INTP);
caxis([0 12])
[C, h_c] = contour(x_mat, y_mat, HS_INTP, 0:1:12, 'Color', 'k');
clabel(C,h_c,'LabelSpacing',500,'Color','k','FontWeight','b','FontSize',18);
set(h,'EdgeColor','None');
intv = 18;
norm_fac = 1000;
h_q = quivers(x_mat(1:intv:end,1:intv:end), y_mat(1:intv:end,1:intv:end), ...
    u_interp(1:intv:end,1:intv:end)/norm_fac, v_interp(1:intv:end,1:intv:end)/norm_fac,0.8,0, ...
    'm/s','k',0);

% fill colors on land
for c_id = 1:length(N_C)
    fill(N_C(c_id).X,N_C(c_id).Y,[239 220 185]/255);
end

axis equal;
colorbar();
colormap(jet);
xlabel('Longitude (\circE)');
ylabel('Latitude (\circN)');
xtickformat('%.2f')
ytickformat('%.2f')
xlim([min(x_mat(:)) max(x_mat(:))]);
ylim([min(y_mat(:)) max(y_mat(:))]);
set(gca,'FontSize',25);        
set(gca,'Box','on');
set(gca,'LineWidth',3);        
set(gcf,'Color','w');

rectangle('Position',[x_vec(6) y_vec(end-6)-0.0145 0.026 0.0145],'EdgeColor','k','FaceColor','w','LineWidth',2)
x_s = 129.291; y_s  = 35.358;
text(x_s,35.3588,'[Specifications]','FontWeight','bold','VerticalAlignment','top','FontSize',20);
text(x_s+0.0003,y_s-0.0025,['TC Name' ' : ' strrep(tgt_tc,'_',' ')],'VerticalAlignment','top','FontSize',18);
text(x_s+0.0003,y_s-0.0050,['Intensity increment' ' : ' tc_int],'VerticalAlignment','top','FontSize',18);
text(x_s+0.0003,y_s-0.0078,['Translation increment' ' : ' tc_vel],'VerticalAlignment','top','FontSize',18);
text(x_s+0.0003,y_s-0.0106,['Unit' ' : ' 'm'],'VerticalAlignment','top','FontSize',18);

print('-vector', fullfile(spath, 'HS_Small.png'), '-dpng', '-r300')









