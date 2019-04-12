close all
clear all

buoy.name='44025';
%buoy.year=2009:1:2013;
buoy.year=2017;

%load DATA_42040

%% read in the wind data
[DATA]=ndbc_nc2(buoy);

%% convert wind direction FROM to TOWARD before passing to compass2uv
WIND_TWD=angle360(DATA(:,2),180);

%% convert the magnitude and direction to u and v
[u,v]=compass2uv(WIND_TWD,DATA(:,3));

%% convention: store velocity time series as complex vector:
w=u+1i*v;

%% Convert the matlab time to columns of [yyyy mm dd hh mi sc]
buoy.datevec=datevec(DATA(:,1));

%% convert the [yyyy mm dd hh mi sc] to julian date time
buoy.jd=julian(buoy.datevec);    %Gregorian start [yyyy mm dd hh mi sc]

% conf.start_date2=datenum(2012,8,11);
% conf.end_date2=datenum(2012,8,15);
% conf.start_date2=datenum(buoy.year,6,15);
% conf.end_date2=datenum(buoy.year,6,20);
conf.start_date2=datenum(2017,3,1);
conf.end_date2=datenum(2017,4,1);

conf.sdstr=datestr(conf.start_date2,'yyyymmdd');
conf.edstr=datestr(conf.end_date2,'yyyymmdd');

ind=find(DATA(:,1)>conf.start_date2 & DATA(:,1)<conf.end_date2);

%% Set the along shelf angle 
region='region4';
[~,~,rot]=fn_region_geometry(region);
%% rotate the u and v into a cross shelf ur and along shelf vr wind
[ur, vr] = dg_rotate_refframe(u,v,rot);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE 1
figure(5)

  % h=timeplt(buoy.jd,[u v abs(w) w],[1 1 2 3]);
  % title('2012 Five Minute Wind Record from WeatherFlow Station 37558')
h=timeplt(buoy.jd(ind),[u(ind)  v(ind) abs(w(ind)) w(ind)],[1 1 2 3]);
  % h=timeplt(buoy.jd(ind),[ abs(w(ind)) DATA(ind,2) DATA(ind,9)],[ 1 2 3]);
stacklbl(h(1),'East (blue) + North (red) velocity','Wind Velocity (m/s)');
grid on
stacklbl(h(2),'Speed','Wind Speed (m/s)');
grid on
stacklbl(h(3),'Velocity Sticks','Vel (m/s)');
grid on
title(['Hourly Wind Data from NDBC Station ' buoy.name])
timestamp(5,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_wind_timeplt.m')
print(5,'-dpng','-r200',['Wind_timeplt_Hourly_' buoy.name '_' conf.sdstr '_' conf.edstr '.png'])

figure(1)
subplot(311)
% quiver(DATA(ind,1), zeros(size(u(ind))), u(ind), v(ind));
% sticks(DATA(ind,1),DATA(ind,3),DATA(ind,2))
plot(DATA(ind,1),DATA(ind,2))
format_axis(gca,conf.start_date2,conf.end_date2,7,1,'mm/dd',0,360,60)
ylabel('Direction (deg CWN)')
%set(gca,'YTickLabel',[]);
title(['Hourly Wind Data from NDBC Station ' buoy.name])
textbp('wind direction from')

subplot(312)
plot(DATA(ind,1),abs(w(ind)))
format_axis(gca,conf.start_date2,conf.end_date2,7,1,'mm/dd',0,ceil(max(abs(w(ind)))),2)
ylabel('WInd Speed (m/s)')

% %% plot the East u and North v wind speed 
% subplot(313)
% plot(DATA(ind,1),u(ind),'g')
% hold on
% plot(DATA(ind,1),v(ind),'r')
% min_test=[min(u(ind)) min(v(ind))];
% format_axis(gca,conf.start_date2,conf.end_date2,1,0.5,'mm/dd',floor(min(min_test)),ceil(max(abs(w(ind)))),2)
% ylabel('N(r) E(g) (m/s)')

%% plot the East u and North v wind speed
% subplot(313)
% plot(DATA(ind,1),ur(ind),'g')
% hold on
% plot(DATA(ind,1),vr(ind),'r')
% min_test=[min(u(ind)) min(v(ind))];
% format_axis(gca,conf.start_date2,conf.end_date2,1,0.5,'mm/dd',floor(min(min_test)),ceil(max(abs(w(ind)))),2)
% ylabel('Along(r) Cross(g) (m/s)')

subplot(313)
plot(DATA(ind,1),ur(ind),'g')
hold on
plot(DATA(ind,1),vr(ind),'Color',[0.797 0 0.797])
min_test=[min(u(ind)) min(v(ind))];
format_axis(gca,conf.start_date2,conf.end_date2,7,1,'mm/dd',floor(min(min_test)),ceil(max(abs(w(ind)))),4)
ylabel('Wind Velocity (m/s)')
textbp('Alongshore (magenta) Cross Shore (green)')

%% use STACKLBL to label each stack plot panel with title and units:



% stacklbl(h(1),'Wind Speed','Wind Speed (m/s)');
% stacklbl(h(2),'Wind Direction',{'Wind Direction'; '(deg CWN)'});
% stacklbl(h(3),'Atmospheric Pressure',{'Atmospheric'; 'Pressure (mb)'});

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_wind_timeplt.m')
print(1,'-dpng','-r200',['Wind_subplt_Hourly_' buoy.name '_' conf.sdstr '_' conf.edstr '.png'])

%% FIGURE 2

figure(2)
%h1=timeplt(buoy.jd(ind),[ DATA(ind,9)],[1]);
%h1=plot(DATA(ind,1),DATA(ind,9),'b-');
h1=timeplt(buoy.jd(ind),[DATA(ind,9)],[1]);
grid on
stacklbl(h1(1),'','Air Pressure (mb)');

%format_axis(gca,conf.start_date2,conf.end_date2,1,3/24,'mmm dd',1010,1018,2)
ylabel('Air Pressure (mb)')
title(['Hourly Atmospheric Data from NDBC Station ' buoy.name])
timestamp(2,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_wind_timeplt.m')
print(2,'-dpng','-r200',['Pressure_timeplt_Hourly_' buoy.name '_' conf.sdstr '_' conf.edstr '.png'])

% %% FIGURE 3 WATER LEVEL
% figure(3)
% h1=timeplt(buoy.jd(ind),[ DATA(ind,14)],[1]);
% h1=plot(DATA(ind,1),DATA(ind,9),'b-');
% format_axis(gca,conf.start_date2,conf.end_date2,1,24/24,'mmm dd',-2,2,1)
% ylabel('Water Level (m)')
% 
% timestamp(2,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_wind_timeplt.m')
% print(3,'-dpng','-r200',['WaterLevel_timeplt_Hourly_' buoy.name '_' conf.sdstr '_' conf.edstr '.png'])

%% FIGURE 4 WAVE HEIGHT
figure(4)
h4=timeplt(buoy.jd(ind),[ DATA(ind,5)],[1]);
stacklbl(h4(1),'','Wave Height (m)');
grid on
% h1=plot(DATA(ind,1),DATA(ind,9),'b-');
% format_axis(gca,conf.start_date2,conf.end_date2,1,24/24,'mmm dd',-2,2,1)
ylabel('Wave Height (m)')
title(['Hourly Atmospheric Data from NDBC Station ' buoy.name])
timestamp(4,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_wind_timeplt.m')
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


