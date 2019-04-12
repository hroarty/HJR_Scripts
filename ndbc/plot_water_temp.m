clear all
close all

tic

yr_start=2005;
yr_end=2011;
yr_vec=(yr_start:yr_end)';
yr_str=num2str(yr_vec);

start_date=datenum(yr_start,01,1);
end_date=datenum(yr_end,12,31);
x_interval=365;



ndbc_data='/Users/hroarty/data/NDBC/ACYN4';
[Data]=NDBC_monthly_readin_func(ndbc_data,'txt');

time_vec=datevec(Data.time);

figure(1)
hold on

%% define the colormap for the data
range_color=(jet(length(yr_vec)));

for ii=yr_start:yr_end

ind_summer=find(time_vec(:,2)>=5 & time_vec(:,2)<=9 & time_vec(:,1)==ii);
%h2=plot(((1:length(ind_summer))/24),smooth(Data.WTMP(ind_summer),30),'color',range_color(ii-2004,:),'LineWidth',1.5);
h2=plot(Data.time(ind_summer)-datenum(ii-1,12,31),smooth(Data.WTMP(ind_summer),30),'color',range_color(ii-2004,:),'LineWidth',1.5);
clear ind_summer
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

box on
grid on



timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_water_temp.m')

toc