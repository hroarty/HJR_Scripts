close all
clear all

%% data downloaded from NDBC thredds server located in /Users/hroarty/data/NDBC/44009
load buoy_44009.mat

plot(DATA(:,1),DATA(:,5))

ymin=0;
ymax=10;
y_interval=1;

start_date=datenum(1984,01,01);
end_date=datenum(2014,10,31);
x_interval=365*3;


%date_format='mm/dd';
date_format='yyyy';

AX2=gca;
format_axis(AX2,start_date,end_date,x_interval,date_format,ymin,ymax,y_interval)

xlabel('Year')
ylabel('Wave Height (m)')
title('Data from NDBC Station 44009')
%axis([0 365 ymin ymax])

% box on
% grid on

timestamp(1,'/Users/hroarty/data/NDBC/44009/plot_wave_height_v2.m')

print(1,'-dpng','-r400','Wave_Height_ts_44009_1984_2012.png')



