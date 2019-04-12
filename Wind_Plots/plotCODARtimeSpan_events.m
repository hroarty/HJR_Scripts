%% received this code from Laura Palamara

clear all
close all
clc

fileDir = '/Volumes/codaradm/data/totals/maracoos/oi/nc/5MHz/'; %Location of files
saveDir = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20150206_Storm_Animations/'; % where to save images
eventType = 'Hurricane';
eventName = 'Sandy';

filePrefix = 'RU_5MHz_'; %prefix of totals in nc format

t0 = datenum(2012, 10, 27, 0, 0, 0);
t1 = datenum(2012, 10, 30, 0, 0, 0);

if isempty(t1)
    dTimes = t0;
else
    dTimes = [t0:1/24:t1];
end
 
for r = 1:length(dTimes)
    fNames{r} = [filePrefix datestr(dTimes(r), 'yyyy_mm_dd_HH00')];
    fLocs{r} = [fileDir fNames{r} '.totals.nc'];
end

for p= 1:length(fLocs)
    yy = fLocs{p};
    
    if ~exist(yy, 'file');
        disp('File does not exist yet. Continuing...');
        continue
    end
    
    lon = ncread(yy, 'lon'); %grab lons
    lat = ncread(yy, 'lat'); %grab lats
    u = ncread(yy, 'u'); %grab raw u
    v = ncread(yy, 'v'); %grab raw v
%     div = ncread(yy, 'div'); %grab divergence
    u_err = ncread(yy, 'u_err');
    v_err = ncread(yy, 'v_err');
    
    [X,Y] = meshgrid(lon, lat); %create grid from lons lats
    X = X'; %rotate grid
    Y = Y'; %rotate grid

    %% find -999 and turn into NaN
    u(u == -999) = NaN; v(v == -999) = NaN;
    X(isnan(u)) = NaN; Y(isnan(u)) = NaN;
    
    %% Find errors for u + v greater than 0.6 and filter out
    indUErr = find(u_err > 0.6); % find u errors greater than 0.6
    indVErr = find(v_err > 0.6); % find v errors greater than 0.6
   
    u(indUErr) = NaN; v(indUErr) = NaN; 
    u(indVErr) = NaN; v(indVErr) = NaN;
 
    %% Make sure the grid has nans in place of actual numbers (for plotting purposes)
    X(isnan(u)) = NaN; Y(isnan(u)) = NaN;
    
    mag = sqrt(u.^2 + v.^2); % current year magnitude

    t = pcolor(X,Y,mag);
    hold on
    shading flat
%     shading interp
    load('parula-mod');
    cmap = colormap(cmap);
    c = colorbar;
    caxis([0 120])
    c.Label.String = 'Current Speed (cm/s)';
    c.Label.FontSize = 12;
    
    bathy=load ('/Users/hroarty/data/bathymetry/eastcoast_4min.mat');
    ind2= bathy.depthi==99999;
    bathy.depthi(ind2)=NaN;
    bathylines=[-20 -200];

    [cs, h1] = contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
    clabel(cs,h1,'fontsize',8);
    set(h1,'Color', [96,96,96]./255, 'linewidth', .25)

    tanLand = [240,230,140]./255; %rgb value for tan
    
    coast = load('/Users/hroarty/data/coast_files/MARA_coast.mat');
    coast = coast.ncst;
%     e = plot(coast(:,1), coast(:,2), 'k', 'linewidth', 1);
    mapshow(coast(:,1), coast(:,2), 'DisplayType', 'polygon', 'facecolor', tanLand)
    hold on

    streakarrow(X,Y, u, v, 1.75, 1, 3);
    hold on
   
    xlim([-76 -68.5]);
    ylim([34 42.8]);
    box on
    
    load('neStateLines.mat');
    sl = plot(lon, lat, 'k.', 'markersize', 1);
    
    ind = find(yy == '/');
    file = yy(ind(end)+1:end);
    indA = find(file == '_');
    indB = find(file == '.');
    fileStr = file(indA(2)+1:indB(1)-1);
    
    yearStr = fileStr(1:4); %year
    monthStr = fileStr(6:7);%month
    dayStr = fileStr(1:10);%year_month_day
    hourStr = fileStr(12:13);%hour
    fileStr = {[eventType ' ' eventName ' Totals'];...
        datestr(datenum([dayStr ' ' hourStr], 'yyyy_mm_dd HH'), 31)};
    
    grid on
    xlabel('Longitude', 'fontsize', 12)
    ylabel('Latitude', 'fontsize', 12)
    project_mercator;
%     ylabel(c, 'Speed (cm/s)', 'fontsize', 12);

    title(fileStr);
    dirListing = [saveDir eventType '-' eventName '/' yearStr '_' monthStr '/']; 
    
    if ~exist(dirListing, 'dir')
        mkdir(dirListing)
    end

    set(gcf, 'paperposition', [0 0 11 8.5]);
    set(gcf, 'paperorientation', 'landscape');
    print('-dpng', [saveDir eventName '-' fNames{p} '.png'], '-r200')

    close gcf

end