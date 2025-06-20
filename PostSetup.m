function PostSetup(tgt_tc, tgt_NPP, intensity, int_inc, rpath)

addpath(genpath('/home/user_006/08_MATLIB'))

%% Set default parameters
if nargin < 1, tgt_tc    = '0314_MAEMI'; end
if nargin < 2, tgt_NPP   = 'SAEUL'; end
if nargin < 3, intensity = '2.03-10'; end
if nargin < 4, int_inc   = '0%'; end
if nargin < 5, rpath     = '/home/user_006/01_WORK/2025/NPP'; end

subdir = 'MAX';
opath = fullfile(rpath, '05_DATA', 'processed');
dpath = fullfile(opath, tgt_NPP);
wpath = fullfile(dpath, tgt_tc, '13_SETUP', subdir, intensity);
fpath = fullfile(rpath, '04_FIGURE');
spath = fullfile(fpath, tgt_NPP, tgt_tc, 'SETUP', subdir, intensity);
if ~exist(spath, 'dir'), mkdir(spath); end

%% Do the work
% dirNames = {dir(fullfile(wpath, '*')).name};
% dirNames = dirNames(cellfun(@(n) ~ismember(n, {'.', '..'}), dirNames));

% load coastline data
COAST = load('/home/user_006/03_DATA/NEW_KR_Coastline_230206.mat').NEW_KR;
% blon = 129.309; ulon = 129.323; blat = 35.327; ulat = 35.34;
blon = 129.29; ulon = 129.35; blat = 35.31; ulat = 35.36;

toRemove = arrayfun(@(c) any(c.X > blon & c.X < ulon & c.Y > blat & c.Y < ulat) && (length(c.X) < 200), COAST);
N_C = COAST(~toRemove);

cd(wpath)
sFile = dir('*_SETUP.mat');
result = load(fullfile(sFile.folder, sFile.name));
fname = fieldnames(result);
setup = result.(fname{1});

[~, INPUT] = system('grep -n CGRID INPUT');

% suffix of translation speed
if contains(intensity,'+10')
    tc_vel = '+10%';
elseif contains(intensity,'-10')
    tc_vel = '-10%';
else
    tc_vel = '0%';
end

lines = strsplit(INPUT, '\n');
for j = 1:length(lines)
    line = lines{j};
    if contains(line, 'CGRID')
        tokens = split(line);
        vals = str2double(tokens);
        xs = vals(2);
        ys = vals(3);
        lx = vals(5);
        ly = vals(6);
        nx = vals(7);
        ny = vals(8);
    end
end

[slat, slon] = utm2ll(xs, ys, 52);
[elat, elon] = utm2ll(xs+lx, ys+ly, 52);
xVecOrg = linspace(slon, elon, nx+1);
yVecOrg = linspace(slat, elat, ny+1);

[xMatOrg, yMatOrg] = meshgrid(xVecOrg, yVecOrg);

% create target mesh grid
xVecItp = blon:0.0001:ulon;
yVecItp = blat:0.0001:ulat;
[xMatItp, yMatItp] = meshgrid(xVecItp, yVecItp);

% interpolate HS values
SETUP_INTP = griddata(xMatOrg(~isnan(setup)),yMatOrg(~isnan(setup)), ...
    double(setup(~isnan(setup))),xMatItp,yMatItp,'linear');

% plot it
clf;hold on;set(gcf,'position',[310 -3 1376 993]);
p = pcolor(xMatItp, yMatItp, SETUP_INTP*100); set(p, 'EdgeColor', 'None'); axis equal;
caxis([0 50]); xlim([blon ulon]); ylim([blat ulat]);

% fill colors on land
for c_id = 1:length(N_C)
    fill(N_C(c_id).X,N_C(c_id).Y,[239 220 185]/255);
end

colorbar();
colormap(jet);
xlabel('Longitude (\circE)');
ylabel('Latitude (\circN)');
xtickformat('%.2f')
ytickformat('%.2f')
xmin = min(xMatItp(:)); ymin = min(yMatItp(:));
xmax = max(xMatItp(:)); ymax = max(yMatItp(:));
xticks(xmin:0.01:xmax);
yticks(ymin:0.01:ymax);
set(gca,'FontSize',25);        
set(gca,'Box','on');
set(gca,'LineWidth',3);        
set(gcf,'Color','w');

rectangle('Position',[xVecItp(6) yVecItp(end-6)-0.0145 0.026 0.0145],'EdgeColor','k','FaceColor','w','LineWidth',2)
x_s = 129.291; y_s  = 35.358;
text(x_s,35.3588,'[Specifications]','FontWeight','bold','VerticalAlignment','top','FontSize',25);
text(x_s+0.0003,y_s-0.0025,['TC Name' ' : ' strrep(tgt_tc,'_',' ')],'VerticalAlignment','top','FontSize',23);
text(x_s+0.0003,y_s-0.0050,['Intensity increment' ' : ' int_inc],'VerticalAlignment','top','FontSize',23);
text(x_s+0.0003,y_s-0.0078,['Translation increment' ' : ' tc_vel],'VerticalAlignment','top','FontSize',23);
text(x_s+0.0003,y_s-0.0106,['Unit' ' : ' 'm'],'VerticalAlignment','top','FontSize',23);
print('-vector', fullfile(spath, ['SETUP_' intensity '.png']), '-dpng', '-r300');
end






%% dummy
%     tgt_dg = load(fullfile(dpath, "dgrid.mat"));
%     dgrid = tgt_dg.dgrid;


    % CGRID vs. DGRID
%     clf;hold on;set(gcf,'position',[310 -3 1376 993]);
%     for c_id = 1:length(N_C)
%         fill(N_C(c_id).X,N_C(c_id).Y,[239 220 185]/255);
%     end
%     plot([x_vec(1), x_vec(1)], [y_vec(1), y_vec(end)], '-k'); 
%     plot([x_vec(1), x_vec(end)], [y_vec(end), y_vec(end)], '-k');
%     plot([x_vec(end), x_vec(end)], [y_vec(end), y_vec(1)], '-k');
%     plot([x_vec(end), x_vec(1)], [y_vec(1), y_vec(1)], '-k');
%     
%     [dgrid.utm_xs, dgrid.utm_ys] = ll2utm(dgrid.ys, dgrid.xs, 52);
%     [dgrid.utm_xe, dgrid.utm_ye] = ll2utm(dgrid.ye, dgrid.xe, 52);
%     
%     plot([dgrid.xs, dgrid.xs], [dgrid.ys, dgrid.ye], '-r');
%     plot([dgrid.xs, dgrid.xe], [dgrid.ye, dgrid.ye], '-r');
%     plot([dgrid.xe, dgrid.xe], [dgrid.ye, dgrid.ys], '-r');
%     plot([dgrid.xe, dgrid.xs], [dgrid.ys, dgrid.ys], '-r');
%     
%     plot([ngrid.xs, ngrid.xs], [ngrid.ys, ngrid.ys+ngrid.ly], '-b');
%     plot([ngrid.xs, ngrid.xs+ngrid.lx], [ngrid.ys+ngrid.ly, ngrid.ys+ngrid.ly], '-b');
%     plot([ngrid.xs+ngrid.lx, ngrid.xs+ngrid.lx], [ngrid.ys+ngrid.ly, ngrid.ys], '-b');
%     plot([ngrid.xs+ngrid.lx, ngrid.xs], [ngrid.ys, ngrid.ys], '-b');    
    
    % plot depth
%     load('DEPTH_SETUP.dat')
%     clf;hold on;set(gcf,'position',[310 -3 1376 993]);
%     p = pcolor(dgrid.mx, dgrid.my, DEPTH_SETUP); set(p, 'EdgeColor', 'None');
%     caxis([0 150]);







