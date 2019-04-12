clear all
close all

tic

yr_start=2004;
yr_end=2015;
yr_vec=(yr_start:yr_end)';
yr_str=num2str(yr_vec);

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
station='ACYN4';
ndbc_data='/Users/hroarty/data/NDBC/';
[Data]=NDBC_monthly_readin_func(ndbc_data,'txt');

time_vec=datevec(Data.time);

figure(1)
hold on

%% define the colormap for the data
% range_color=(jet(length(yr_vec)));
range_color=(lines(length(yr_vec)));

water_temp=[];

for ii=yr_start:yr_end

ind_summer=find( time_vec(:,1)==ii);
%h2=plot(((1:length(ind_summer))/24),smooth(Data.WTMP(ind_summer),30),'color',range_color(ii-2004,:),'LineWidth',1.5);
h2=plot(Data.time(ind_summer)-datenum(ii-1,12,31),Data.WTMP(ind_summer),'color',range_color(ii-2004,:),'LineWidth',1.5);

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

legend(yr_str,'Location','NorthEast');


%% plot the NDBC data
%subplot(2,1,1)
%h2=plot(Data.time,Data.WTMP,'g.-');



%legend('SPRK CODAR Data','44009 NDBC Data')
%legend('Wave Height','Average Wave Period')


ymin=0;
ymax=30;
y_interval=10;

date_format='mm/dd/yy';

%AX2=gca;
%format_axis(AX2,start_date,end_date,x_interval,date_format,ymin,ymax,y_interval)

xlabel('Year Day')
ylabel('Water Temp (deg C)')
title('Data from NDBC Station ACYN4 Atlantic City, NJ')
axis([0 365 ymin ymax])


box on
grid on



timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_water_temp_year.m')

print(1,'-dpng','-r400','Water_Temp_.png')
toc