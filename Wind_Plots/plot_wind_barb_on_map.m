
close all
clear all


%% read in the hourly data
hourly=load('/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/weatherflow/tuckertonwind.mat');

%% Define some configuration parameters
config.start_date=datenum(2012,01,01);
config.end_date=datenum(2012,12,31);
config.x_interval=30;
config.date_format='mm/dd';
config.ymin=-40;
config.ymax=40;
config.y_interval=10;

hourly.hourlywinddirTO=angle360(hourly.hourlywinddir,180);
[hourly.uhr,hourly.vhr]=compass2uv(hourly.hourlywinddirTO,hourly.hourlywindspd);

%% config axis parameters for the plotBasemap function
p.HourPlot.axisLims=[-75-20/60 -73 38.0 41];

%% Create the filename for the coastline file
coastline_file='/Users/hroarty/data/coast_files/BPU3_coast.mat';


%% Plot the base map for the radial file
plotBasemap( p.HourPlot.axisLims(1:2),p.HourPlot.axisLims(3:4),coastline_file,'Mercator','patch',[.5 .9 .5],'edgecolor','k')
hold on

ind=find(hourly.hourlytime >= datenum(2012,5,1,0,0,0) & hourly.hourlytime <= datenum(2012,5,1,23,0,0));



s=0.1;
s2=10;
wind_mean.u=nanmean(hourly.uhr(ind));
wind_mean.v=nanmean(hourly.vhr(ind));
wind_mean.mag=sqrt(wind_mean.u.^2+wind_mean.v.^2);
wind_mean.mag_str=num2str(round2(wind_mean.mag,0.1));

%m_quiver(-74.5,40,wind_mean.u,wind_mean.v,s)
[HP, HT]=m_vec(s2,-74.5,40,wind_mean.u,wind_mean.v);

m_text(-74.75,39.75,[wind_mean.mag_str ' m/s'])