%% This m script was written to extract time series data from the grid points 
%% that are closest to the virtual meterological towers for the BPU project
close all
clear all

tic

%% determine which computer you are running the script on
compType = computer;

if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes';
else
     root = '/home';
end

conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20151216_RPS_Request/';

%% Configuration Parameters

file='http://hfrnet.ucsd.edu/thredds/dodsC/HFR/USEGC/6km/hourly/RTV/HFRADAR,_US_East_and_Gulf_Coast,_6km_Resolution,_Hourly_RTV_best.ncd';
        
conf.Totals.DomainName='MARA';
conf.Totals.BaseDir=[root '/codaradm/data/totals/maracoos/oi/mat/5MHz/'];
conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix='.mat';
conf.Totals.MonthFlag=1;
conf.HourPlot.Type='Totals';
%% MAB point
%point=[-74-42/60-37/3600,38+47/60+9.3/3600];%% off NJ
point=[-75-15/60-00/3600,36+00/60+00/3600];%% off NC



radial_type='measured';

% conf.Totals.DomainName='CARA';
% conf.OI.BaseDir=[root '/codaradm/data/totals/caracoos/oi/mat/13MHz/' radial_type '/'];
% conf.OI.FilePrefix=strcat('tuv_OI_',conf.Totals.DomainName,'_');
% conf.OI.FileSuffix='.mat';
% conf.OI.MonthFlag=true;
% conf.HourPlot.Type='OI';
%%% Mona Passage Point
%point=[-67-30/60,18+10/60];

%% determine the start time of the model
timeAtt = ncreadatt(file, 'time', 'units');
timeStr = timeAtt(end-19:end-1);
% datestr(datenum(timeStr, 'yyyy-mm-ddTHH:MM:SS'))
timeHFR = datenum(timeStr, 'yyyy-mm-ddTHH:MM:SS');
datestr(timeHFR)

%% load in the time variable of the model
time = ncread(file, 'time');

%% convert the model time to matlab time
time1=time/24+timeHFR;


dtime=datenum(2015,11,1,0,0,2):1/24:datenum(2015,12,1,0,0,0);
tick.major=7;
tick.minor=1;

%% create strings to use in the map filename
timestr_sd=datestr(dtime(1),'yyyymmdd');
timestr_ed=datestr(dtime(end),'yyyymmdd');


lat=ncread(file,'lat');
lon=ncread(file,'lon');

diff1=abs(point(1)-lon);
diff2=abs(point(2)-lat);

%% find the closest grid point
[Y1,I1] = min(diff1);%% find index of closest longitude point
[Y2,I2] = min(diff2);%% find index of closest latitude point

%% find the index of the times we want
tDiff = abs(min(dtime) - time1);

[~,time_index] = min(tDiff);


U=ncread(file,'u',[I1 I2 time_index],[1 1 length(dtime)]);
V=ncread(file,'v',[I1 I2 time_index],[1 1 length(dtime)]);

%% reduce the dimensions of the variables and convert to cm/s from m/s
U=squeeze(U)*100;
V=squeeze(V)*100;

dtime2=dtime;


%% calculate the low pass filtered time series
%% Get the lowpass filtered data
per=32;
om=2*pi/per;
ns=64;

%% Start script from here if you already have the data

%% load NJ_currents_2013

% region='region4';
% [wp,wp2,rot]=fn_region_geometry(region);

rot=360;

%% rotate the u and v into a cross shelf and along shelf current
[ur, vr] = dg_rotate_refframe(U,V,rot);

%% calculate the low pass of the data    
[tlow_ur,harbor_low_ur,harbor_hi_ur]=lowpassbob(dtime2,ur,om,ns);
[tlow_vr,harbor_low_vr,harbor_hi_vr]=lowpassbob(dtime2,vr,om,ns);

%% calculate the magnitude of the surface current
mag=sqrt(ur.^2 + vr.^2);

%% Figure 1  Magnitude
figure(1)
plot(dtime2,mag)
format_axis(gca,min(dtime2),max(dtime2),24*tick.major/24,24*tick.minor/24,'mm/dd',0,100,20)
ylabel('Radial Velocity Magnitude (cm/s)')
timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_05.m')
print(1,'-dpng','-r400',[ conf.Plot.PrintPath conf.Totals.DomainName ...
    '_MAG_ts_' timestr_sd '_' timestr_ed '_ts_index_LON_' num2str(I1) '_LAT_' num2str(I2) '_4.png'])



time_interval=24*30;%24 for a daily mean since it is hourly data
                    %24*30 for monthly mean

% %% calculate the time interval mean
% ur_ti_mean=nanmean(reshape(ur,time_interval,[]));
% vr_ti_mean=nanmean(reshape(vr,time_interval,[]));
% dtime2_ti_mean=nanmean(reshape(dtime2,time_interval,[]));
% 
% %% calculate the number of data points in each mean
% ur_data_pts=sum(reshape(~isnan(ur),time_interval,[]));
% vr_data_pts=sum(reshape(~isnan(vr),time_interval,[]));
% 
% %% calculate the time interval standard deviation
% ur_ti_std=nanstd(reshape(ur,time_interval,[]));
% vr_ti_std=nanstd(reshape(vr,time_interval,[]));

dtime3=datevec(dtime2);

%% loop to calculate the monthly means
%months=[12 1 2 3 4 5];
time_var=1:30;
%% declare the time column you want to calculate the mean for
%% 2 for monthly means
%% 3 for daily means
time_column=3;

for jj=1:length(time_var)
    ind=find(dtime3(:,time_column)==time_var(jj));
    
    ur_ti_mean(jj)=nanmean(ur(ind));
    vr_ti_mean(jj)=nanmean(vr(ind));
    dtime2_ti_mean(jj)=nanmean(dtime2(ind));
    
    ur_data_pts(jj)=sum(~isnan(ur(ind)));
    vr_data_pts(jj)=sum(~isnan(vr(ind)));
    
    ur_ti_std(jj)=nanstd(ur(ind));
    vr_ti_std(jj)=nanstd(vr(ind));
    
end

%%  calculate the error bar
vr_error_bar=vr_ti_std*1.96./sqrt(vr_data_pts);
ur_error_bar=ur_ti_std*1.96./sqrt(ur_data_pts);

%% Figure 2
%% -----------------------------------------------------------------------
figure(2)
%plot(dtime2,ur,'r')
hold on
plot(dtime2,vr,'b')
%plot(dtime2_daily_mean,vr_daily_mean,'bs')
errorbar(dtime2_ti_mean,vr_ti_mean,vr_error_bar,'k','LineWidth',2)
%% plot the low pass data
plot(tlow_vr,harbor_low_vr,'Color','g','LineWidth',2)

%% FIGURE 2 FORMATTING
title(['Time Series at ' num2str(point(1)) ' Lon & ' num2str(point(2)) ' Lat'])
format_axis(gca,min(dtime2),max(dtime2),24*tick.major/24,24*tick.minor/24,'mm/dd',-80,100,20)
%legend('Cross Shelf','Along Shelf','Location','NorthEast');
legend('V Velocity','Daily Mean','Low Pass','Location','NorthEast');
ylabel('Velocity (cm/s)')
%title({[siteName ' ' radType ' Bearing ' num2str(bearing)]; 'Real Time Quality Metrics'})
set(gca,'TickDir','out')
timestamp(2,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_05.m')
print(2,'-dpng','-r400',[ conf.Plot.PrintPath conf.Totals.DomainName '_V_ts_' ...
    timestr_sd '_' timestr_ed '_ts_index_' num2str(I1) '_LAT_' num2str(I2) '_4.png'])

%% Figure 3
%% -----------------------------------------------------------------------
figure(3)
hold on
plot(dtime2,ur,'b')
%plot(dtime2_daily_mean,vr_daily_mean,'bs')
errorbar(dtime2_ti_mean,ur_ti_mean,ur_error_bar,'k','LineWidth',2)
%% plot the low pass data
plot(tlow_ur,harbor_low_ur,'Color','g','LineWidth',2)

%% FIGURE 3 FORMATTING
title(['Time Series at ' num2str(point(1)) ' Lon & ' num2str(point(2)) ' Lat'])
format_axis(gca,min(dtime2),max(dtime2),24*tick.major/24,24*tick.minor/24,'mm/dd',-60,60,20)
%legend('Cross Shelf','Along Shelf','Location','NorthEast');
legend('U Velocity','Daily Mean','Low Pass','Location','NorthEast');
ylabel('Velocity (cm/s)')
%title({[siteName ' ' radType ' Bearing ' num2str(bearing)]; 'Real Time Quality Metrics'})
set(gca,'TickDir','out')
timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_05.m')
print(3,'-dpng','-r400',[ conf.Plot.PrintPath conf.Totals.DomainName '_U_ts_' ...
    timestr_sd '_' timestr_ed '_ts_index_' num2str(I1) '_LAT_' num2str(I2) '_4.png'])
toc

%save [conf.Plot.PrintPath conf.Totals.DomainName '_' timestr_sd '_' timestr_sd '_time_series.mat']


