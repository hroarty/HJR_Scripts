tic

clear all
close all
clc

fileDir = '/Volumes/home/michaesm/codar/codar_means/yearly_means/'; %Location of files
saveDir = '/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/curly_vectors/plotting/'; % where to save images
% eventType = 'Year (2007-2012) Mean';
% eventName = 'Montauk';


fNames = {'/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/RU_5MHz_7yearcomposite_2007_01_01_0000.nc'};
for p= 1:length(fNames)
    yy = fNames{p};
    
    if ~exist(yy, 'file');
        disp('File does not exist yet. Continuing...');
        continue
    end
    
    lon = ncread(yy, 'lon'); %grab lons
    lat = ncread(yy, 'lat'); %grab lats
    u = ncread(yy, 'u'); %grab raw u
    v = ncread(yy, 'v'); %grab raw v
    var = ncread(yy, 'uv_std');
    
    [X,Y] = meshgrid(lon, lat); %create grid from lons lats
    X = X'; %rotate grid
    Y = Y'; %rotate grid

    %% find -999 and turn into NaN
    u(u == -999) = NaN; v(v == -999) = NaN;
    X(isnan(u)) = NaN; Y(isnan(u)) = NaN;
    
    %% Make sure the grid has nans in place of actual numbers (for plotting purposes)
    X(isnan(u)) = NaN; Y(isnan(u)) = NaN;
    var(isnan(u)) = NaN;
    
    mag = sqrt(u.^2 + v.^2); % current year magnitude

    t = pcolor(X,Y,var);
    hold on
%     shading flat
    shading interp
    load('parula-mod');
    cmap = colormap(cmap);
    c = colorbar;
    caxis([0 50])
    c.Label.String = 'Standard Deviation (cm/s)';
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

    streakarrow(X,Y, u, v, 2, 1, 3);
    hold on
   
    xlim([-76 -68.5]);
    ylim([34 42.8]);
    box on
    
%     load('neStateLines.mat');
%     sl = plot(lon, lat, 'k.', 'markersize', 1);
    
%     ind = find(yy == '/');
%     file = yy(ind(end)+1:end);
    
%     yearStr = file(9:12);

    fileStr = {['MARACOOS Surface Currents']; ['Eight Year (2007-2014) Mean']};
    
    grid on
    xlabel('Longitude', 'fontsize', 12)
    ylabel('Latitude', 'fontsize', 12)
    project_mercator;

    title(fileStr);
    dirListing = [saveDir]; 
    
    if ~exist(dirListing, 'dir')
        mkdir(dirListing)
    end

    set(gcf, 'paperposition', [0 0 11 8.5]);
%     set(gcf, 'paperorientation', 'landscape');
    print('-dpng', [dirListing  'sevenYearMean--uvstd-compositeSurfaceCurrents.png'], '-r200')

    close gcf

end

toc