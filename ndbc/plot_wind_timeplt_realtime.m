close all
clear all

buoy.name='44065';
buoy.year=2013:1:2013;

NDBC_Dir ='/Users/hroarty/COOL/01_CODAR/DHS/131119_NYH_Experiment/20131125_Analysis';
NDBC_Files = dir([NDBC_Dir '/*.txt']);

[DATA]=NDBC_monthly_readin_func(NDBC_Dir,'txt');

%% convert wind direction FROM to TOWARD before passing to compass2uv
DATA.MWID=angle360(DATA.MWID,180);

%% convert the magnitude and direction to u and v
[u,v]=compass2uv(DATA.MWID,DATA.WSPD);

%% convention: store velocity time series as complex vector:
w=u+1i*v;

%% Convert the matlab time to columns of [yyyy mm dd hh mi sc]
buoy.datevec=datevec(DATA.time);

%% convert the [yyyy mm dd hh mi sc] to julian date time
buoy.jd=julian(buoy.datevec);    %Gregorian start [yyyy mm dd hh mi sc]

conf.start_date2=datenum(2013,11,22);
conf.end_date2=datenum(2013,11,25);

conf.sdstr=datestr(conf.start_date2,'yyyymmdd');
conf.edstr=datestr(conf.end_date2,'yyyymmdd');

ind=find(DATA.time>conf.start_date2 & DATA.time<conf.end_date2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 1
figure(1)

% h=timeplt(buoy.jd,[u v abs(w) w],[1 1 2 3]);
% title('2012 Five Minute Wind Record from WeatherFlow Station 37558')
h=timeplt(buoy.jd(ind),[u(ind)  v(ind) abs(w(ind)) w(ind)],[1 1 2 3]);
title(['2013 Hourly Wind Record from NDBC Buoy ' buoy.name])

%% use STACKLBL to label each stack plot panel with title and units:

stacklbl(h(1),'East + North velocity','N(g) E(b) (m/s)');
stacklbl(h(2),'Speed','Speed (m/s)');
stacklbl(h(3),'Velocity Sticks','Vel (m/s)');

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_wind_timeplt_realtime.m')
%print('-dpng','-r200',['Wind_timeplt_5min_Sept' buoy.name '.png'])
print('-dpng','-r200',['Wind_timeplt_Hourly_' buoy.name '_' conf.sdstr '_' conf.edstr '.png'])


