clear all;close all;
% file='http://tds.marine.rutgers.edu:8080/thredds/dodsC/roms/espresso/2013_da/his_Best/ESPRESSO_Real-Time_v2_History_Best_Available_best.ncd';

file='/Users/roarty/data/espresso/espresso_his_20130808_0000_0003.nc';
% file='/Volumes/om/dods-data/thredds/roms/espresso/2013_da/his/espresso_his_20130610_0000_0002.nc';
% ncdisp(file);


[z]=depths(file, file, 1, 0, 1);

time=ncread(file,'ocean_time'); % seconds since 2006-01-01 00:00:00
datetime=(time./(60*60*24))+datenum(datevec('2006-01-01 00:00:00'));

%ncread(filename,parameter,start indices, count indices);
% temp=ncread(file,'temp',[1 1 1 1000],[Inf Inf Inf 1]); % Type help ncread
T=ncread(file,'temp');
T1=T(:,:,:,1);
T3=T1;
lat=ncread(file,'lat_rho');
lon=ncread(file,'lon_rho');
h=ncread(file,'h');
h=-h;
% test=squeeze(double(temp(:,:,:,1)));
% pcolor(lon,lat,T1(:,:,1));

LON=repmat(lon,1,1,36);
LAT=repmat(lat,1,1,36);



%% load the fig file
hgload('/Users/roarty/data/fig/kerfoot/marcoos_15second_3d.fig')

hold on

% surf(lon,lat,T1)
% [r,c]=size(h);
% G(1,1,:)=[0.8 0.8 0.8];
% 
% B=repmat(G,r,c);
% % s=surf(lon,lat,h,B);
% s=surf(lon,lat,h,h);
% colormap copper

%% Tan land 
% tanLand = [240,230,140]./255; %rgb value for tan
% coast = load('/Users/roarty/data/coast_files/MARA_coast.mat');
% coast = coast.ncst;
% %     e = plot(coast(:,1), coast(:,2), 'k', 'linewidth', 1);
% mapshow(coast(:,1), coast(:,2), 'DisplayType', 'polygon', 'facecolor', tanLand)



%% load and plot the coastline file
coast=load('/Users/roarty/data/coast_files/MARA_coast.mat');
t=zeros(length(coast.ncst(:,1)),1);
plot3(coast.ncst(:,1),coast.ncst(:,2),t,'LineWidth',0.5,'Color','w')


conf.Plot.boundaries=load('/Users/roarty/data/political_boundaries/WDB2_global_political_boundaries.dat');
t1=10*ones(length(conf.Plot.boundaries),1);
hdls.boundaries=plot3(conf.Plot.boundaries(:,1),conf.Plot.boundaries(:,2),t1,'-w','linewidth',1);



% replace values above 10 degrees w NaNs
T1(T1>10)=NaN;

LON2=LON(:);
LAT2=LAT(:);
T2=T1(:);
Z2=z(:);

% S=ones(r,c,36);
% S=1;

% colormap(winter)
% scatter3(LON2,LAT2,Z2,S,T2)
% c = colorbar;
% c.Label.String = 'Temperature (deg C)';

% make data points in water depths greater than 100 m Nan
ind=h<-100;
ind2=repmat(ind,1,1,36);
T3(ind2)=NaN;

% remove data points south of latitude 
% ind3=LAT<37.5;
% T3(ind3)=NaN;

threshold=12;
fv =patch(isosurface(LON,LAT,z,T3,threshold));
% isonormals(LON,LAT,z,T3,fv)
fv.FaceColor = 'cyan';
fv.EdgeColor = 'none';
% daspect([1 1 1])
% view(3); 
% axis tight
camlight 
lighting gouraud

% set(s, 'edgecolor','none')

xlim([-76.5 -69.75])
ylim([35.5 42.5])
zlim([-100 50])

az = 30;
el =45;
view(az, el);

% box off
grid off
% set(gca,'visible','off')

% xlabel('Longitude')
% ylabel('Latitude')
% zlabel('Depth')
title(['ESPRESSO Cold Pool ' num2str(threshold) char(176) ' C on ' datestr(datetime(1),'mmm dd, yyyy HH:MM') ' UTC'])

conf.Plot.script='Espresso_plot_cold_pool_surface.m';
% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20160923_FOL_Inspection/20170810_Inspection/';
conf.Plot.PrintPath='/Users/roarty/data/espresso/';
conf.Plot.Filename=[ 'ESPRESSO_Model_Temperature_' num2str(threshold) '_' datestr(datetime(1),'yyyymmdd_HHMM') '_v14.png'];


timestamp(1, [conf.Plot.Filename ' / ' conf.Plot.script])

print(1,'-dpng','-r300',[conf.Plot.PrintPath conf.Plot.Filename ])

% figure(2)
% colormap winter
% colorbar
% fv =patch(isosurface(LON,LAT,z,T3,10));
% % isonormals(LON,LAT,z,T3,fv)
% fv.FaceColor = 'blue';
% fv.EdgeColor = 'none';
% % daspect([1 1 1])
% view(3); 
% axis tight
% camlight 
% lighting gouraud
% box on
% grid on
