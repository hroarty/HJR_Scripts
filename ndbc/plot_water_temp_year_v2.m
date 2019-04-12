clear all
close all

tic

yr_start=2009;
yr_end=2011;
yr_vec=(yr_start:yr_end)';
yr_str=num2str(yr_vec);

start_date=datenum(yr_start,01,1);
end_date=datenum(yr_end,12,31);
x_interval=365;


%% read in the data
ndbc_data='/Users/hroarty/data/NDBC/ACYN4';
[Data]=NDBC_monthly_readin_func(ndbc_data,'txt');

%% convert celsius to farenheit
Data.WTMP=9*Data.WTMP/5+32;


time_vec=datevec(Data.time);

figure(1)
hold on

%% define the colormap for the data
range_color=(jet(length(yr_vec)));

%water_temp=nan(365,length(yr_vec));
water_temp=nan(12,length(yr_vec));

for ii=yr_start:yr_end

ind_summer=find( time_vec(:,1)==ii);
%h2=plot(((1:length(ind_summer))/24),smooth(Data.WTMP(ind_summer),30),'color',range_color(ii-2004,:),'LineWidth',1.5);
%h2=plot(Data.time(ind_summer)-datenum(ii-1,12,31),Data.WTMP(ind_summer),'color',range_color(ii-2008,:),'LineWidth',1.5);

% figure(2)
 MATRIX=[Data.time(ind_summer) Data.WTMP(ind_summer)];
 
 %% bin into daily data
 %binned=binner_std(MATRIX,1,1);
 
 %% bin into monthly data
  binned=binner_std(MATRIX,1,30);
  
  errorbar(0:30:365,binned(:,2),binned(:,3),'color',range_color(ii-2008,:),'LineWidth',2)
% plot(binned(:,1),binned(:,2),'r')
% hold on
Y1=interp1(MATRIX(:,1),MATRIX(:,2),datenum(ii,1,15):30:datenum(ii,12,15));
Y1=Y1';
% plot(datenum(ii,1,1):1:datenum(ii,12,31),Y1,'go')
% 
 water_temp(:,ii-2008)=Y1;
clear ind_summer
disp(ii)
end

legend(yr_str,'Location','NorthEast');

wtt=nanmean(water_temp,2);
%plot(smooth(wtt,15),'g','LineWidth',2)

water_temp_std=[];

for ii=1:length(water_temp)
    water_temp_std(ii)=nanstd(water_temp(ii,:));
end




%% plot the NDBC data
%subplot(2,1,1)
%h2=plot(Data.time,Data.WTMP,'g.-');



%legend('SPRK CODAR Data','44009 NDBC Data')
%legend('Wave Height','Average Wave Period')


ymin=30;
%ymax=30;
ymax=90;
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

figure(1)
%plot(15:30:365,wtt,'k','LineWidth',2)

errorbar(15:30:365,wtt,water_temp_std,'k','LineWidth',2) 

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_water_temp_year.m')

toc