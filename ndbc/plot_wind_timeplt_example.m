close all
clear all

buoy.name='42040';
buoy.year=2010:1:2010;

%load DATA_42040

DATA(:,1)=datenum(2013,10,1):1/24:datenum(2013,10,8);
DATA(:,2)=135*ones(169,1);
DATA(:,3)=10*ones(169,1);

% %% read in the wind data
% [DATA]=ndbc_nc(buoy);
% 
%% convert wind direction FROM to TOWARD before passing to compass2uv
DATA(:,2)=angle360(DATA(:,2),180);

%% convert the magnitude and direction to u and v
[u,v]=compass2uv(DATA(:,2),DATA(:,3));

%% convention: store velocity time series as complex vector:
w=u+1i*v;

%% Convert the matlab time to columns of [yyyy mm dd hh mi sc]
buoy.datevec=datevec(DATA(:,1));

%% convert the [yyyy mm dd hh mi sc] to julian date time
buoy.jd=julian(buoy.datevec);    %Gregorian start [yyyy mm dd hh mi sc]

conf.start_date2=datenum(2013,10,1);
conf.end_date2=datenum(2013,10,8);

ind=find(DATA(:,1)>conf.start_date2 & DATA(:,1)<conf.end_date2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 1
figure(1)

% h=timeplt(buoy.jd,[u v abs(w) w],[1 1 2 3]);
% title('2012 Five Minute Wind Record from WeatherFlow Station 37558')
%h=timeplt(buoy.jd(ind),[u(ind) v(ind) abs(w(ind)) w(ind)],[1 1 2 3]);
h=timeplt(buoy.jd(ind),[u(ind) abs(w(ind)) w(ind)],[1 2 3]);
title(['2010 Hourly Wind Record from NDBC Buoy ' buoy.name])

%% use STACKLBL to label each stack plot panel with title and units:

stacklbl(h(1),'East + North velocity','m/s');
stacklbl(h(2),'Speed','m/s');
stacklbl(h(3),'Velocity Sticks','m/s');

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_wind_timeplt.m')
%print('-dpng','-r200',['Wind_timeplt_5min_Sept' buoy.name '.png'])
print('-dpng','-r200',['Wind_timeplt_Hourly_' buoy.name '.png'])


