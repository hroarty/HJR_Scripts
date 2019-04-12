clear all
close all
clc

file = 'http://ecowatch.ncddc.noaa.gov/thredds/dodsC/hycom/hycom_reg1_agg/HYCOM_Region_1_Aggregation_best.ncd';
% july 24 2013 - fisherman fell off
dtimes = datenum(2016,3,28,0,0,0):3/24:datenum(2016,3,29,0,0,0);
saveDir = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20140116_Montauk_SAR_Case/20150410_HYCOM_Plots/';

timeAtt = ncreadatt(file, 'time', 'units');
timeStr = timeAtt(end-19:end-1);
% datestr(datenum(timeStr, 'yyyy-mm-ddTHH:MM:SS'))
hycomTS = datenum(timeStr, 'yyyy-mm-ddTHH:MM:SS');
datestr(hycomTS)

time = ncread(file, 'time');
lon = ncread(file, 'lon');
lat = ncread(file, 'lat');

I = find(lon >= 283 & lon <= 293); % lon in degrees east
J = find(lat >= 34 & lat <= 43); % lat
lons = lon(I); lons = lons-360;
lats = lat(J);
[X,Y] = meshgrid(lons, lats);
X = X';
Y = Y';

t0=time/24+hycomTS; % convert index times to matlab times

for w = 1:length(dtimes)
    % difference between now and t0
    tDiff = abs(t0 - dtimes(w));
    [~,tlen] = min(tDiff);
    time_index=tlen;%example of last day;cd

    curTime=t0(time_index);% Snapshot;
    disp(['The hour/day you choose is ' datestr(curTime) ]);
    u=ncread(file, 'water_u', [I(1) J(1) 1 time_index], [I(end)-I(1)+1 J(end)-J(1)+1 1 1]);
    v=ncread(file, 'water_v', [I(1) J(1) 1 time_index], [I(end)-I(1)+1 J(end)-J(1)+1 1 1]);
    u = double(u);
    v = double(v);
    
    X(isnan(u)) = NaN; Y(isnan(u)) = NaN;
    X(isnan(v)) = NaN; Y(isnan(v)) = NaN;

    mag = sqrt(u.^2 + v.^2)*100; % current year magnitude
   
    t = pcolor(X,Y,mag);
    hold on
    shading interp
    addpath /Users/hroarty/Documents/MATLAB/HJR_Scripts/Antarctic/functions/
    load('parula-mod');
    cmap = colormap(cmap);
    c = colorbar;
    caxis([0 60])
    c.Label.String = 'Current Speed (cm/s)';
    c.Label.FontSize = 12;

    bathy=load ('/Users/hroarty/data/bathymetry/eastcoast_4min.mat');
    ind2= bathy.depthi==99999;
    bathy.depthi(ind2)=NaN;
    bathylines=[-20 -60 -100];

    [cs, h1] = contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
    clabel(cs,h1,'fontsize',8);
    set(h1,'Color', [96,96,96]./255, 'linewidth', .25)

    tanLand = [240,230,140]./255; %rgb value for tan

    coast = load('/Users/hroarty/data/coast_files/MARA_coast.mat');
    coast = coast.ncst;
    %     e = plot(coast(:,1), coast(:,2), 'k', 'linewidth', 1);
    mapshow(coast(:,1), coast(:,2), 'DisplayType', 'polygon', 'facecolor', tanLand)
    hold on

    streakarrow(X,Y, u, v, 2, 1, 2,'k');
    hold on

    xlim([-76 -68.5]);
    ylim([34 42.8]);
    box on

%     load('neStateLines.mat');
%     sl = plot(lon, lat, 'k.', 'markersize', 1);

    %    
    title({'NCEP HYCOM Surface Currents'; datestr(curTime, 31)})
    %     
    grid on
    xlabel('Longitude', 'fontsize', 12)
    ylabel('Latitude', 'fontsize', 12)
    project_mercator;
    
%     set(gcf,'PaperPositionMode','manual')
%     set(gcf,'Units','Pixels')
%     set(gcf,'PaperSize',[751 750]);
%     set(gcf,'Units','Inches')
    set(gcf, 'paperposition', [0 0 11 8.5]);
    
    fileName = [saveDir 'HYCOM-' datestr(curTime,30) '.png'];
    
    print('-dpng', fileName, '-r200')
%     export_fig(sprintf('%s', fileName), '-m4')
    %     print('-dpng', '-r300', [saveDir 'HYCOM-' datestr(curTime,30) '.png'])

    close(gcf)
end



