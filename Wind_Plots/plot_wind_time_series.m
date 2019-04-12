close all
clear all


% %% read in the weatherflow data
% %% path for the script  /Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data
% buoy=read_weatherflow_data('/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/weatherflow/oceancitywind.csv');
% buoy.name='44025';
% yyyy0=2012;
% 
% %% read in the hourly data
% hourly=load('/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/weatherflow/tuckertonwind.mat');


start_date=datenum(2009,09,1);
end_date=datenum(2009,12,1);
remoteflag = 0;
buoy.name='44025';
buoydata = [];

buoy = load_buoy(start_date,end_date,buoy.name,buoydata,remoteflag);
x_interval=30;
x_minor_interval=10;
date_format='mm/dd';
ymin=-20;
ymax=20;
y_interval=10;

start_str=datestr(start_date,'yyyymmdd');
end_str=datestr(end_date,'yyyymmdd');

[u,v]=compass2uv(buoy.wfdir,buoy.wspd);
% [uhr,vhr]=compass2uv(hourly.hourlywinddir,hourly.hourlywindspd);

%% FIGURE 1
figure(1)
h1=plot(buoy.time,u,'r-');
hold on
h2=plot(buoy.time,v,'b-');
format_axis(gca,start_date,end_date,x_interval,x_minor_interval,date_format,ymin,ymax,y_interval)
ylabel('Wind Speed (m/s)')
xlabel('Date mm/dd')
title(' Wind Record from WeatherFlow Station ')
legend('Zonal','Meridional')
timestamp(1,'/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/plot_wind_time_series.m')
print('-dpng','-r200',['Wind_ts_' start_str '_' end_str '_' buoy.name '.png'])

%% FIGURE 2
figure(2)
subplot 211
h1=plot(buoy.time,u,'ro');
hold on
h2=plot(hourly.hourlytime,uhr,'g-');
format_axis(gca,start_date,end_date,x_interval,x_minor_interval,date_format,ymin,ymax,y_interval)
ylabel('U Wind Speed (m/s)')
xlabel('Date mm/dd')
title('2012 Wind Record from WeatherFlow Station 37558')
legend('5 Minute', 'Hourly')


subplot 212
h2=plot(buoy.t,v,'bo');
hold on
h2=plot(hourly.hourlytime,vhr,'g-');
format_axis(gca,start_date,end_date,x_interval,x_minor_interval,date_format,ymin,ymax,y_interval)
ylabel('V Wind Speed (m/s)')
xlabel('Date mm/dd')
legend('5 Minute', 'Hourly')
timestamp(2,'/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/plot_wind_time_series.m')
print('-dpng','-r200',['Wind_ts_components_' start_str '_' end_str '_' buoy.name '.png'])

%% FIGURE 3
figure(3)
h1=feather(u,v);%'r-');
h1 = quiver(hourly.hourlytime, zeros(1,length(hourly.hourlytime)), uhr, vhr, 0, 'k');
axis([0 10 -10 10])
set(gca,'DataAspectRatio',[1 1 1]);
h1=feather(uhr+sqrt(-1)*vhr,hourly.hourlytime);
%format_axis(gca,start_date,end_date,x_interval,x_minor_interval,date_format,ymin,ymax,y_interval)

ylabel('Wind Speed (m/s)')
xlabel('Date mm/dd')
title('2012 Wind Record from WeatherFlow Station 37558')
grid on
box on
timestamp(3,'/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/plot_wind_time_series.m')
print('-dpng','-r200',['Wind_quiver_' start_str '_' end_str '_' buoy.name '.png'])

%% FIGURE 4
figure(4)
figure(4)
subplot 211
h1=plot(buoy.t,buoy.wspd,'r-');

ind=buoy.wspd>10;
hold on
h2=plot(buoy.t(ind),buoy.wspd(ind),'go');
ylabel('Wind Speed (m/s)')
% xlabel('Date mm/dd')
title('2012 Wind Record from WeatherFlow Station 37558')
format_axis(gca,start_date,end_date,x_interval,x_minor_interval,date_format,0,ymax,y_interval)

subplot 212
h3=plot(buoy.t,buoy.wfdir,'b.');
format_axis(gca,start_date,end_date,x_interval,x_minor_interval,date_format,0,360,60)
ylabel('Wind Speed (deg CWN)')
xlabel('Date mm/dd')


timestamp(4,'/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/plot_wind_time_series.m')
print('-dpng','-r200',['Wind_Spd_Dir_ts_' start_str '_' end_str '_' buoy.name '.png'])


