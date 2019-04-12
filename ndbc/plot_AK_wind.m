clear all
close all

ndbc_data='/Users/hroarty/data/NDBC/48213';
[Data_48213]=NDBC_monthly_readin_func(ndbc_data,'txt');

ndbc_data2='/Users/hroarty/data/NDBC/48214';
[Data_48214]=NDBC_monthly_readin_func(ndbc_data2,'txt');

plot(Data_48213.time,Data_48213.WVHT,'b','LineWidth',2)
hold on
plot(Data_48214.time,Data_48214.WVHT,'r--','LineWidth',2)

legend('Station 48213','Station 48214')
xlabel('Date (mm/dd)')
ylabel('Wave Height (m)')
%ylabel('Wind Speed (m/s)')

% box on
% grid on
% xlim([min(Data_48214.time)-1,max(Data_48214.time)+1])
% datetick('x','mm/dd')

format_axis(gca,datenum(2012,9,1),datenum(2012,10,13),24*7/24,24/24,'mm/dd',0,5,1)

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_AK_wind.m')

print('-dpng','-r200','2012_AK_Wave_Data.png')