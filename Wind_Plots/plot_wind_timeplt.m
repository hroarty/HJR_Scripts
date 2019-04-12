close all
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5 Minute Data

%% read in the weatherflow data
%% path for the script  /Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data

%% read in the weather flow data
% file='/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/weatherflow/tuckertonwind2012.csv';
% file='/Users/hroarty/COOL/01_CODAR/Waves/20170601_Jaden_Summer/20170821_CAPE_analysis/WeatherFlow_CapeMay_v2.csv';
% buoy.name='37558';
% yyyy0=2017;

file='/Users/hroarty/COOL/GRACE/WeatherFlow_Cape_May_mps.csv';
buoy.name='42348';
yyyy0=2014;


buoy=read_weatherflow_data(file);


%% convert the magnitude and direction to u and v
buoy.wtdir=angle360(buoy.wfdir,180);
[u,v]=compass2uv(buoy.wtdir,buoy.wspd);

%% convention: store velocity time series as complex vector:
w=u+1i*v;

%% Convert the matlab time to columns of [yyyy mm dd hh mi sc]
buoy.datevec=datevec(buoy.t);

%% converth the [yyyy mm dd hh mi sc] to julian date time
buoy.jd=julian(buoy.datevec);    %Gregorian start [yyyy mm dd hh mi sc]

conf.start_date2=datenum(2012,05,01);
conf.end_date2=datenum(2012,9,30);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1 Hour Data

%% read in the hourly data
hourly=load('/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/weatherflow/tuckertonwind.mat');


%% convert the magnitude and direction to u and v
hourly.hourlywinddir=angle360(hourly.hourlywinddir,180);
[uhr,vhr]=compass2uv(hourly.hourlywinddir,hourly.hourlywindspd);

%% convert the row vectors of uhr and vhr to column vectors.  column vectors 
%% required as input to timeplt
uhr=uhr';
vhr=vhr';

%% Convert the matlab time to columns of [yyyy mm dd hh mi sc]
buoy_time=datevec(hourly.hourlytime);

ind=find(hourly.hourlytime>conf.start_date2 & hourly.hourlytime<conf.end_date2);

%% convert the [yyyy mm dd hh mi sc] to julian date time
jdhr=julian(buoy_time);    %Gregorian start [yyyy mm dd hh mi sc]
jdhr=jdhr';

%% convention: store velocity time series as complex vector:
whr=uhr+1i*vhr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 1
figure(1)

%h=timeplt(buoy.jd,[u v abs(w) w],[1 1 2 3]);
h=timeplt(buoy.jd,[u v buoy.wfdir abs(w) w],[1 1 2 3 4]);
% title('2012 Five Minute Wind Record from WeatherFlow Station 37558')
% h=timeplt(jdhr(ind),[uhr(ind) vhr(ind) abs(whr(ind)) whr(ind)],[1 1 2 3]);
title(['5 Minute Wind Data from WeatherFlow Station Cape May ' num2str(buoy.name(1))])

%% use STACKLBL to label each stack plot panel with title and units:

% stacklbl(h(1),'East + North velocity','m/s');
% stacklbl(h(2),'Speed','m/s');
% stacklbl(h(3),'Velocity Sticks','m/s');

stacklbl(h(1),'East(b) + North(r) velocity','m/s');
stacklbl(h(2),'Wind Direction From','Deg');
stacklbl(h(3),'Speed','m/s');
stacklbl(h(4),'Velocity Sticks','m/s');

set(h(4),'YLim',[-20 15])

for ii=1:4
    set(h(ii),'XGrid','on','YGrid','on')
end

conf.Plot.Path='/Users/hroarty/COOL/GRACE/';


timestamp(1,'plot_wind_timeplt.m')
%print('-dpng','-r200',['Wind_timeplt_5min_Sept' buoy.name '.png'])
print('-dpng','-r200',[conf.Plot.Path 'Wind_timeplt_Hourly_' num2str(buoy.name(1)) '.png'])


