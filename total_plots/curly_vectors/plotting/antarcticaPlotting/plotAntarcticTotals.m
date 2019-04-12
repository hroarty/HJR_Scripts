clear all
close all
clc

% fileDir = '/'; %Location of files
saveDir = '/Users/michaesm/Documents/'; % where to save images

% filePrefix = 'OI_PLDP_'; %prefix of totals in nc format
% 
% t0 = datenum(2014, 11, 18, 0, 0, 0);
% t1 = datenum(2014, 11, 18, 4, 0, 0);
% 
% if isempty(t1)
%     dTimes = t0;
% else
%     dTimes = [t0:1/24:t1];
% end
% 
% % tNow = floor(epoch2datenum(java.lang.System.currentTimeMillis*.001));
% % tStart = tNow - 1;
% % dTimes = [tNow:-1/24:tStart];
% % 
% for r = 1:length(dTimes)
%     fNames{r} = [filePrefix datestr(dTimes(r), 'yyyy_mm_dd_HH00')];
%     fLocs{r} = [fileDir fNames{r} '.totals.nc'];
% end

fLocs = {'/Users/michaesm/Documents/RU_25MHz_PLDP_20150101T00-20150228T23-mean.nc'};
for p= 1:length(fLocs)
    yy = fLocs{p};
    
    if ~exist(yy, 'file');
        disp('File does not exist yet. Continuing...');
        continue
    end
    
    lon = ncread(yy, 'lon'); %grab lons
    lat = ncread(yy, 'lat'); %grab lats
    u = ncread(yy, 'u_detided'); %grab raw u
    v = ncread(yy, 'v_detided'); %grab raw v
%     div = ncread(yy, 'div'); %grab divergence
%     u_err = ncread(yy, 'u_err');
%     v_err = ncread(yy, 'v_err');
    
    [X,Y] = meshgrid(lon, lat); %create grid from lons lats
    X = X'; %rotate grid
    Y = Y'; %rotate grid

    %% find -999 and turn into NaN
    u(u == -999) = NaN; v(v == -999) = NaN;
    X(isnan(u)) = NaN; Y(isnan(u)) = NaN;
%     
%     %% Find errors for u + v greater than 0.6 and filter out
%     indUErr = find(u_err > 0.6); % find u errors greater than 0.6
%     indVErr = find(v_err > 0.6); % find v errors greater than 0.6
%    
%     u(indUErr) = NaN; v(indUErr) = NaN; 
%     u(indVErr) = NaN; v(indVErr) = NaN;
 
    %% Make sure the grid has nans in place of actual numbers (for plotting purposes)
    X(isnan(u)) = NaN; Y(isnan(u)) = NaN;
    
    mag = sqrt(u.^2 + v.^2); % current year magnitude
    
    %% plot pcolor map of chosen variable
    t = pcolor(X,Y,mag);
    hold on
    shading flat
%     shading interp
    load('parula-mod.mat');
    cmap = colormap(cmap);
    c = colorbar;
    caxis([0 13])
    c.Label.String = 'Current Speed (cm/s)';
    c.Label.FontSize = 18;   
 
    %% plot antarctic bathymetry    
	bathy=load ('antarctic_bathy_2.mat');
	ind2= bathy.depthi==99999;
	bathy.depthi(ind2)=[];
	bathylines1=0:-10:-100;
	bathylines2=0:-200:-1400;
	bathylines=[bathylines2];
	
	[cs, h1] = contour(bathy.loni,bathy.lati, bathy.depthi,bathylines, 'linewidth', .25);
	clabel(cs,h1,'fontsize',6);
	set(h1,'LineColor','black')
	hold on
    
    streakarrow(X,Y, u, v, 1.5, 1, 4);
    hold on

    tanLand = [240,230,140]./255;
    S1 = shaperead('/Users/michaesm/Documents/MATLAB/mapping/coastlines/antarctica_shape/cst00_polygon_wgs84.shp');
    mapshow([S1.X], [S1.Y], 'DisplayType', 'polygon', 'facecolor', tanLand)
    hold on
    
    s(1) = plot(-64.0554167, -64.7741833, 'g^',...
        'markersize', 12,...
        'markerfacecolor', 'green',...
        'markeredgecolor', 'black');
    s(2) = plot(-64.3604167, -64.7871667, 'gs',...
        'markersize', 12,...
        'markerfacecolor', 'green',...
        'markeredgecolor', 'black');
    s(3) = plot(-64.0446333, -64.9183167, 'gd',...
        'markersize', 12,...
        'markerfacecolor', 'green',...
        'markeredgecolor', 'black');
   
    ylim([-65.05 -64.7])
    xlim([-64.5 -63.95])
%     a=narrow(-63.692838483136/6,-64.683125,.3); % place north facing arrow on upper right corner of map
    l = legend(s, 'Palmer Station', 'Wauwermans Islands', 'Joubin Islands', 'Location', 'SouthEast');

    project_mercator;
%     ind = find(yy == '/');
%     file = yy(ind(end)+1:end);
%     indA = find(file == '_');
%     indB = find(file == '.');
%     fileStr = file(indA(2)+1:indB(1)-1);
%     
%     yearStr = fileStr(1:4); %year
%     monthStr = fileStr(6:7);%month
%     dayStr = fileStr(1:10);%year_month_day
% %     hourStr = fileStr(12:13);%hour
%     
%     dirListing = [saveDir yearStr '_' monthStr '/']; 
%     
%     if ~exist(dirListing, 'dir')
%         mkdir(dirListing)
%     end

    fileStr = {'Project Converge Detided Totals';...
        '0.5km Grid Spacing - Measured Pattern';...
        'January 1, 2015 through February 28, 2015'};
    title(fileStr);
    
    set(gcf, 'paperposition', [0 0 11 8.5]);
    savefig('jan-feb-avg-stdev.fig')
%     set(gcf, 'paperorientation', 'landscape');
%     print('-fig', ['jan-feb-avg-detided.fig'], '-r300')


    close all

end