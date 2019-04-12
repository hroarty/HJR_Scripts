close all
clear all


%% read in the weatherflow data
%% path for the script  /Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data
read_weatherflow_data
buoy.name='37558';
yyyy0=2012;

%% read in the hourly data
hourly=load('tuckertonwind.mat');


t1=datenum(2012,01,01);
t2=datenum(2012,1,31);
x_interval=5;
date_format='mm/dd';
ymin=0;
ymax=360;
y_interval=60;

datestr1=datestr(t1,'yyyymmdd');
datestr2=datestr(t2,'yyyymmdd');


[u,v]=compass2uv(buoy.wfdir,buoy.wspd);
[uhr,vhr]=compass2uv(hourly.hourlywinddir,hourly.hourlywindspd);

%% FIGURE 1
figure(1)
h1=plot(hourly.hourlytime,hourly.hourlywinddir,'r.');


format_axis(gca,t1,t2,x_interval,date_format,ymin,ymax,y_interval)

ylabel('Wind Direction (deg CWN)')
xlabel('Date mm/dd')
title('2012 Wind Record from WeatherFlow Station 37558')

timestamp(1,'/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/plot_wind_dir_time_series.m')
print('-dpng','-r200',['Wind_dir_ts_' buoy.name '_' datestr1 '_' datestr2 '.png'])




