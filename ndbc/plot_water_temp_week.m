clear all
close all

tic

yr_start=2012;
yr_end=2012;
yr_vec=(yr_start:yr_end)';
yr_str=num2str(yr_vec);

start_date=datenum(yr_start,09,8);
end_date=datenum(yr_end,09,15);
x_interval=1;



ndbc_data='/Users/hroarty/data/NDBC/ACYN4';
[Data]=NDBC_monthly_readin_func(ndbc_data,'txt');

time_vec=datevec(Data.time);

figure(1)
hold on

%% define the colormap for the data
range_color=(jet(length(yr_vec)));



ind=find(Data.time>=start_date & Data.time<end_date);

%h2=plot(Data.time(ind),smooth(Data.WTMP(ind),.5),'color','r','LineWidth',1.5);
h2=plot(Data.time(ind),Data.WTMP(ind),'color','r','LineWidth',1.5);

legend(yr_str,'Location','NorthEast');


%% plot the NDBC data
%subplot(2,1,1)
%h2=plot(Data.time,Data.WTMP,'g.-');



%legend('SPRK CODAR Data','44009 NDBC Data')
%legend('Wave Height','Average Wave Period')


ymin=floor(nanmin(Data.WTMP(ind))*0.95);
ymax=ceil(nanmax(Data.WTMP(ind))*1.05);
y_interval=1;

date_format='mm/dd/yy';

AX2=gca;
format_axis(AX2,start_date,end_date,x_interval,date_format,ymin,ymax,y_interval)

xlabel('Year Day')
ylabel('Water Temp (deg C)')
title('Data from NDBC Station ACYN4 Atlantic City, NJ')

box on
grid on



timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_water_temp_week.m')

toc