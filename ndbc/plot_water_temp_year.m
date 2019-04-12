clear all
close all

tic

yr_start=2004;
yr_end=2017;
yr_vec=(yr_start:yr_end)';
yr_str=num2str(yr_vec);
yr_range=yr_end-yr_start;

start_date=datenum(yr_start,01,1);
end_date=datenum(yr_end,12,31);
x_interval=365;

% %% read in data from the thredds server
% buoy.name='acyn4';
% buoy.year=2004:1:2016;
% % buoy.year=2013;
% 
% %% read in the wind data
% [Data]=ndbc_nc(buoy);

%% read in data from the text files downloaded to my computer
% buoy.name='SDHN4';

buoy.name='acyn4';
buoy.dyr=2007;
% buoy.name='bzbm3';
buoy.year=9999;


ndbc_data=['/Users/hroarty/data/NDBC/' buoy.name];
[Data]=NDBC_monthly_readin_func(ndbc_data,'txt',buoy.dyr);

time_vec=datevec(Data.time);


%% read in the most recent year from the Thredds server
% buoy.name='sdhn4';


%% read in the wind data
[DATA]=ndbc_nc(buoy);

figure(1)
hold on

%% define the colormap for the data
% range_color=(jet(length(yr_vec)));
% range_color=(lines(length(yr_vec)));
colormap19;
range_color=jet(yr_range);
% range_color=winter(yr_range);

water_temp=[];

for ii=yr_start:yr_end-1

ind=time_vec(:,1)==ii;

year_day=Data.time(ind)-datenum(ii-1,12,31);

%h2=plot(((1:length(ind_summer))/24),smooth(Data.WTMP(ind_summer),30),'color',range_color(ii-2004,:),'LineWidth',1.5);
h2=plot(year_day,Data.WTMP(ind)*1.8 + 32,'color',range_color(ii-(yr_start-1),:),'LineWidth',1.5);
pause
% figure(2)
% MATRIX=[Data.time(ind_summer) Data.WTMP(ind_summer)];
% binned=binner(MATRIX,1,1);
% plot(binned(:,1),binned(:,2),'r')
% hold on
% Y1=interp1(MATRIX(:,1),MATRIX(:,2),datenum(ii,1,1):1:datenum(ii,12,31));
% Y1=Y1';
% plot(datenum(ii,1,1):1:datenum(ii,12,31),Y1,'go')
% 
% water_temp=[water_temp ;Y1];
clear ind_summer
disp(ii)
end

%% Plot the current year
year_day2=DATA(:,1)-datenum(2016,12,31);

h2=plot(year_day2,DATA(:,11)*1.8 + 32,'color','k','LineWidth',3);

legend(yr_str,'Location','NorthEast');


%% plot the NDBC data
%subplot(2,1,1)
%h2=plot(Data.time,Data.WTMP,'g.-');



%legend('SPRK CODAR Data','44009 NDBC Data')
%legend('Wave Height','Average Wave Period')

% Celsius Scale
% ymin=0;
% ymax=30;
% y_interval=10;

% Celsius Scale
ymin=30;
ymax=90;
y_interval=10;

date_format='mm/dd/yy';

%AX2=gca;
%format_axis(AX2,start_date,end_date,x_interval,date_format,ymin,ymax,y_interval)

xlabel('Year Day')
ylabel('Water Temp (deg F)')
title(['Data from NDBC Station ' buoy.name ])
% title('Data from NDBC Station SDHN4 Sandy Hook, NJ')
axis([0 365 ymin ymax])

set(gca,'XTick',[1 32 61 92 122 153 183 214 245 275 306 336])
set(gca,'XTickLabel',{'Jan', 'Feb', 'Mar', 'Apr','May', 'Jun', 'Jul', 'Aug','Sep','Oct', 'Nov', 'Dec'})


box on
grid on



timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_water_temp_year.m')

print(1,'-dpng','-r400',['Water_Temp_' buoy.name '_' num2str(yr_start) '_' num2str(yr_end) '_v3.png'])
toc