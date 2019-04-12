clear all
close all
clc

ncFile = 'RU_5MHz_7yearMean_Autumn_2007.nc';

u = ncread(ncFile, 'u');
v = ncread(ncFile, 'v');
lon = ncread(ncFile, 'lon');
lat = ncread(ncFile, 'lat');

% lon2 = nc_varget(ncFile, 'lon');
% lat2 = nc_varget(ncFile, 'lat');
% [Lon,Lat] = meshgrid(lon, lat); % for plotting totals
% 
% u2 = nc_varget(ncFile, 'u');
% v2 = nc_varget(ncFile, 'v');

% u_err = ncread(ncFile, 'u_err');
% v_err = ncread(ncFile, 'v_err');

% uLim = find(u_err > 0.7);
% vLim = find(v_err > 0.7);

% u(uLim) = NaN;
% v(uLim) = NaN;
% 
% u(vLim) = NaN;
% v(vLim) = NaN;

[X,Y] = meshgrid(lon, lat);

X = X';
Y = Y';

ind = isnan(u);

X(ind) = NaN;
Y(ind) = NaN;

u(u == -999) = NaN;
v(v == -999) = NaN;

X(isnan(u)) = NaN;
Y(isnan(u)) = NaN;

curvvec(X,Y,u,v, 'color', 'k', 'minmag',0, 'maxmag', 30, 'numpoints',40, 'thin', 2, 'linewidth', 1.25);


 
% vectors = load('OI_MARA_2014_10_29_0100');
% 
% x = vectors(:,1);
% y = vectors(:,2);
% u = vectors(:,3);
% v = vectors(:,4);
% 
% idxu= find(u==-999); 
% u(idxu) = [];
% v(idxu) = [];
% x(idxu) = [];
% y(idxu) = [];
% 
% idxv= find(v==-999);
% u(idxv) = [];
% v(idxv) = [];
% x(idxv) = [];
% y(idxv) = [];
