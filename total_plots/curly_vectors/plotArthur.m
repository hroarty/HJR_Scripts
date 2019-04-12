clear all
close all
clc

% seasons = {'Winter', 'Autumn', 'Spring', 'Summer'};
% years={'2013','2012','2011','2010','2009','2008','2007'};

% years = {'Autumn_2007'};%,...
%     'Spring_2007',...
%     'Summer_2007',...
%     'Winter_2007'};

% years2 = {'Fall: September 1 - December 1'};%,...
%     'Spring: March 1 - June 1',...
%     'Summer: June 1 - September 1',...
%     'Winter: December 1 - March 1'};

fileDir = '/Volumes/home/michaesm/arthur/';

dirStruct = dir([fileDir '*.nc']);

fileNames = dir2cell(dirStruct, fileDir);

for p= 1:length(fileNames)
    yy = fileNames{p};
    
    lon = ncread(yy, 'lon');
    lat = ncread(yy, 'lat');
    u = ncread(yy, 'u');
    v = ncread(yy, 'v');
    
    [X,Y] = meshgrid(lon, lat); % for plotting totals

    X = X';
    Y = Y';

    ind = isnan(u);

    X(ind) = NaN;
    Y(ind) = NaN;

    u(u == -999) = NaN;
    v(v == -999) = NaN;

    X(isnan(u)) = NaN;
    Y(isnan(u)) = NaN;
    
    mag = sqrt(u.^2 + v.^2); % current year magnitude
        
    t = pcolor(X,Y,mag);
    hold on
    shading flat
    shading interp
    caxis([0 60]);
%     cmap = autumn(8);
%     cmap = cmap(end:-1:1,:);
%     cmap = colormap(cmap);


% f = [255,247,236
% 254,232,200
% 253,212,158
% 253,187,132
% 252,141,89
% 239,101,72
% 215,48,31
% 179,0,0
% 127,0,0];
% 
% cmap = colormap(f/255);

    load('parula-mod');

% cmap = parula(64);
% cmap = cmap(4:1:end,:);
    cmap = colormap(cmap);
    colorbar

% cmap = cmap(end:-1:1,:);
% cmap = colormap(cmap);
% 
%     cmap = colormap(ice);

    
    coast = load('/Users/hroarty/data/coast_files/MARA_Coast.mat');
    coast = coast.ncst;
    e = plot(coast(:,1), coast(:,2), 'k', 'linewidth', 1);
    hold on
%     plot_bathymetry;
%     hold on
    
%     
%     indNaN = isnan(u+v);
%     u(indNaN) = [];
%     v(indNaN) = [];
%     Lon(indNaN) = [];
%     Lat(indNaN) = [];

%     L = sqrt(u.^2 + v.^2); % vector length
%     L = L(1:6:end);
%     i = quivers(Lon(1:6:end), Lat(1:6:end), u(1:6:end), v(1:6:end),2, 4, 'cm/s', 'k');
    
%     L = sqrt(u.^2 + v.^2); % vector length
%     L = L(1:6:end);
%     i = quivers(Lon(1:6:end), Lat(1:6:end), u(1:6:end)./L, v(1:6:end)./L,.5, 4, 'cm/s', 'k');

    streakarrow(X,Y, u, v, 1.5, 1, 3);
%     curvvec(X,Y,u,v, 'color', 'k', 'minmag', 0, 'maxmag', 30, 'numpoints', 30, 'thin', 4, 'linewidth', 1.25);
%     curvvec(X,Y,u,v, 'color', 'k', 'minmag', .1, 'maxmag', 30, 'numpoints', 20, 'thin', 3, 'linewidth', .5);
    hold on
   
    mapxlim = [-76 -68.5];
    mapylim = [34 42.8];

    xlim(mapxlim);
    ylim(mapylim);
%     daspect([4 3 1])
    project_mercator;
    grid on
    ind = find(yy == '/');
    file = yy(ind(end)+1:end);
    indA = find(file == '_');
    indB = find(file == '.');
    fileStr = file(indA(2)+1:indB(1)-1);
    fileStr = datestr(datenum(fileStr, 'yyyy_mm_dd_HH00'), 31);
    title(fileStr);
    
    set(gcf, 'paperposition', [0 0 11 8.5]);
    set(gcf, 'paperorientation', 'landscape');
    print('-dpsc2', [yy '-totals-magnitude.ps'])


    close all

end