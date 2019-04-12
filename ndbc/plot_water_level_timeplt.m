close all
clear all

buoy.name='acyn4';
%buoy.year=2009:1:2013;
buoy.year=9999;

%load DATA_42040

%% read in the wind data
[DATA]=ndbc_nc(buoy);

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

conf.start_date2=datenum(2017,6,17);
conf.end_date2=datenum(2017,6,21);

conf.sdstr=datestr(conf.start_date2,'yyyymmdd');
conf.edstr=datestr(conf.end_date2,'yyyymmdd');

ind=find(DATA(:,1)>conf.start_date2 & DATA(:,1)<conf.end_date2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 1
figure(1)

% h=timeplt(buoy.jd,[u v abs(w) w],[1 1 2 3]);
% title('2012 Five Minute Wind Record from WeatherFlow Station 37558')
h=timeplt(buoy.jd(ind),[u(ind)  v(ind) abs(w(ind)) w(ind)],[1 1 2 3]);
%h=timeplt(buoy.jd(ind),[ abs(w(ind)) DATA(ind,2) DATA(ind,9)],[ 1 2 3]);
title(['2015 Hourly Atmospheric Data from NDBC Station ' buoy.name])

%% use STACKLBL to label each stack plot panel with title and units:

stacklbl(h(1),'East + North velocity','N(g) E(b) (m/s)');
stacklbl(h(2),'Speed','Speed (m/s)');
stacklbl(h(3),'Velocity Sticks','Vel (m/s)');

% stacklbl(h(1),'Wind Speed','Wind Speed (m/s)');
% stacklbl(h(2),'Wind Direction',{'Wind Direction'; '(deg CWN)'});
% stacklbl(h(3),'Atmospheric Pressure',{'Atmospheric'; 'Pressure (mb)'});

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_wind_timeplt.m')
print(1,'-dpng','-r200',['Wind_timeplt_Hourly_' buoy.name '_' conf.sdstr '_' conf.edstr '.png'])

%% FIGURE 2

figure(2)
%h1=timeplt(buoy.jd(ind),[ DATA(ind,9)],[1]);
%h1=plot(DATA(ind,1),DATA(ind,9),'b-');
h1=timeplt(buoy.jd(ind),[DATA(ind,9)],[1]);
stacklbl(h1(1),'East + North velocity','Air Pressure (mb)');

%format_axis(gca,conf.start_date2,conf.end_date2,1,3/24,'mmm dd',1010,1018,2)
ylabel('Air Pressure (mb)')
timestamp(2,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_wind_timeplt.m')
print(2,'-dpng','-r200',['Pressure_timeplt_Hourly_' buoy.name '_' conf.sdstr '_' conf.edstr '.png'])

% %% FIGURE 3 WATER LEVEL
figure(3)
h1=timeplt(buoy.jd(ind),[ DATA(ind,14)],[1]);
h1=plot(DATA(ind,1),DATA(ind,9),'b-');
format_axis(gca,conf.start_date2,conf.end_date2,1,24/24,'mmm dd',-2,2,1)
ylabel('Water Level (m)')

timestamp(2,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_wind_timeplt.m')
print(3,'-dpng','-r200',['WaterLevel_timeplt_Hourly_' buoy.name '_' conf.sdstr '_' conf.edstr '.png'])

% %% FIGURE 4 WAVE HEIGHT
figure(4)
h4=timeplt(buoy.jd(ind),[ DATA(ind,5)],[1]);
stacklbl(h4(1),'East + North velocity','Wave Height (m)');

% h1=plot(DATA(ind,1),DATA(ind,9),'b-');
% format_axis(gca,conf.start_date2,conf.end_date2,1,24/24,'mmm dd',-2,2,1)
% ylabel('Wave Height (m)')

timestamp(2,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_wind_timeplt.m')
print(4,'-dpng','-r200',['WaveHeight_timeplt_Hourly_' buoy.name '_' conf.sdstr '_' conf.edstr '.png'])


%% calculate the daily mean
dtime=datevec(DATA(:,1));

for ii=1:30
    ind2=find(dtime(:,2)==9 & dtime(:,3)==ii);
    daily_mean=nanmean(DATA(ind2,5));
    
    %% print to the screen the #, site name, mmsi, time start, time end, total time in minutes
    string=sprintf('%s, %0.2f', datestr(dtime(ind2(1),:),'mm/dd/yy'),daily_mean );
    disp(string)
end


