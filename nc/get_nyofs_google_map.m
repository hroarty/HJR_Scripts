
conf.file.prefix='/Users/hroarty/data/NYOFS/nos.nyofs.fields.nowcast.';
conf.file.suffix='.nc';

dtime2=datenum(2017,12,11,1,0,0):1/24:datenum(2017,12,11,23,0,0);

% file='http://opendap.co-ops.nos.noaa.gov/thredds/dodsC/NOAA/NYOFS/MODELS/201712/nos.nyofs_fg.stations.nowcast.20171208.t20z.nc';

% file='/Users/hroarty/data/NYOFS/nos.nyofs.fields.nowcast.20171211.t15z.nc';
% file='/Users/hroarty/data/NYOFS/nos.nyofs_fg.stations.nowcast.20171211.t13z.nc';
% file='/Users/hroarty/data/NYOFS/nyofs_vdatums.nc';
% file='http://opendap.co-ops.nos.noaa.gov/thredds/dodsC/NYOFS/fmrc/Aggregated_7_day_NYOFS_Fields_Forecast_best.ncd';

for ii=1:length(dtime2)
    
file=[conf.file.prefix datestr(dtime2(ii),'yyyymmdd.tHHz') conf.file.suffix];

% ncdisp(file)

lon=ncread(file,'lon');
lat=ncread(file,'lat');
mask=ncread(file,'mask');
zeta=ncread(file,'zeta');

ind=zeta==-99999;
zeta(ind)=NaN;

% determine the start time of the model
timeAtt = ncreadatt(file, 'time', 'units');
timeStr = timeAtt(end-24:end-15);
% datestr(datenum(timeStr, 'yyyy-mm-ddTHH:MM:SS'))
timeNYH = datenum(timeStr, 'yyyy-mm-dd');
datestr(timeNYH);

%% load in the time variable of the model
dtime = ncread(file, 'time');
dtime=double(dtime);

%% convert the model time to matlab time
% days since 2008-01-01  0:00:00 00:00
dtime1=dtime+timeNYH;

mask=logical(mask);

LON=lon(mask);
LAT=lat(mask);
ZETA=zeta(mask);

% convert ZETA from meters to feet
ZETA = distdim(ZETA, 'meters', 'ft');


%% NYH
% conf.HourPlot.axisLims= [-74-20/60 -73-48/60 40+24/60 40+51/60];% All of NYH
conf.HourPlot.axisLims= [-74-18/60 -73-54/60 40+24/60 40+35/60];% Lower Bay
% conf.HourPlot.axisLims= [-74-15/60 -74-6/60 40+35/60 40+40/60];% Lower Newark Bay & Arthur Kill
% conf.HourPlot.axisLims= [-74-12/60 -74-6/60 40+38/60 40+40/60];% Lower Newark Bay & Arthur Kill
conf.HourPlot.region='NYH';
conf.HourPlot.Mask='/Users/hroarty/data/mask_files/25MHz_Mask.txt';
conf.HourPlot.bathylines=[ -10  -20 -50];
conf.HourPlot.CoastFile='/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.HourPlot.Bathy='/Users/hroarty/data/bathymetry/marcoos_15second_ngdc.mat';

%% Plot the base map for the radial file
% plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.HourPlot.CoastFile,'Mercator','patch',[1 .69412 0.39216],'edgecolor','k')

% m_proj('Mercator','lat',conf.HourPlot.axisLims(3:4),'long', conf.HourPlot.axisLims(1:2));
% m_gshhs_f('patch',[1 .69412 0.39216]);
% m_grid('box','fancy','tickdir','out');

hold on


%% plot_bathymetry
%m_plot_bathymetry2('mac',[-25 -50 -100 -500])%% plot the bathymetry
%bathy=load ('/Users/hroarty/data/bathymetry/marcoos_15second_ngdc.mat');
bathy=load (conf.HourPlot.Bathy);
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
%bathylines=[-20 -50 -80 -200];

% convert the bathymetry from m to feet
bathy.depth_ft = distdim(bathy.depthi, 'meters', 'ft');

% [cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depth_ft,conf.HourPlot.bathylines);
% clabel(cs,h1,'fontsize',8);
% set(h1,'LineColor','k')

% interpolate the bathymetry data onto the NYOFS grid
DEPTH=interp2(bathy.loni,bathy.lati,bathy.depth_ft,LON,LAT);

% total water level = depth + zeta
TWL=abs(DEPTH)+ZETA;

ind=TWL<10;

% Plot the location of the stations 
% m_plot(lon,lat,'b.','MarkerSize',12)

% m_plot(lon(mask),lat(mask),'b.')

% colormap(jet(6))
% colormap(summer)
% caxis([-3 3])
% m_scatter(LON(~ind),LAT(~ind),10,ZETA(~ind),'filled')
% colorbar
scatter(LON(ind),LAT(ind),10,'r','filled')

xlim = [conf.HourPlot.axisLims(1), conf.HourPlot.axisLims(2)];
ylim = [conf.HourPlot.axisLims(3), conf.HourPlot.axisLims(4)];

xtick = (floor(xlim(1)) :0.1: ceil(xlim(end))); 
ytick = (floor(ylim(1)) :0.05: ceil(ylim(end))); 
mlr = pi*mean(ylim)/180;

   set(gca,'xlim',xlim,'ylim',ylim, ...
          'xtick',xtick,'ytick',ytick,...
	  'xticklabel',-xtick,'yticklabel',ytick,...
	  'tickdir','out','fontsize',10,'dataaspectratio',[1/cos(mlr) 1 1]);

plot_google_map('maptype','satellite','alpha',1,'AutoAxis',0);
%  plot_google_map
  pos = [.8, .6, .015 .2];
  


title(['NYOFS Water Level ' datestr(dtime2(ii),'mmmm dd, yyyy HH:MM UTC')])

 conf.Plot.filename=['NYOFS_Field_Zeta_Newark_Bay_' datestr(dtime2(ii),30) '.png']; 
 conf.Plot.script='get_nyofs_v2.m';
 conf.Plot.print_path ='/Users/hroarty/data/NYOFS/TWL/';
 
 
 timestamp(1,[conf.Plot.filename ' / ' conf.Plot.script])
 print(1,'-dpng','-r200',[conf.Plot.print_path  conf.Plot.filename])
 
%  figure(2)
%  hist(ZETA)
 
close all

end
