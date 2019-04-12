%% This m script was written to extract time series data from the grid points 
%% that are closest to the virtual meterological towers for the BPU project
% close all
% clear all

tic

%% determine which computer you are running the script on
compType = computer;

if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes';
else
     root = '/home';
end

% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160125_Jonas/';
% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/02_Collaborations/Puerto_Rico/20170418_CARICOOS_Meeting/';
conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20171214_Currents_For_Josh/';


%% Configuration Parameters
        
conf.Totals.DomainName='MARA';
conf.Totals.BaseDir=[root '/codaradm/data/totals/maracoos/oi/mat/5MHz/'];
conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix='.mat';
conf.Totals.MonthFlag=1;
conf.Totals.TypeFlag=0;
conf.Totals.HourFlag=0;
conf.Totals.SuffixFlag=0;
conf.HourPlot.Type='Totals';
%% MAB point
%point=[-74-42/60-37/3600,38+47/60+9.3/3600];%% off NJ
%point=[-75-15/60-00/3600,36+00/60+00/3600];%% off NC
% point=[-74-18/60-00/3600,39+22/60+00/3600];%% off Atlantic City
conf.point=[-73.81959,38.81673];%% 45 miles SE of Sea Isle City, NJ
conf.Save.directory='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20171214_Currents_For_Josh/';


% radial_type='measured';
% conf.Totals.DomainName='CARA';
% conf.OI.BaseDir=[root '/codaradm/data/totals/caracoos/oi/mat/13MHz/' radial_type '/'];
% conf.OI.FilePrefix=strcat('tuv_OI_',conf.Totals.DomainName,'_');
% conf.OI.FileSuffix='.mat';
% conf.OI.MonthFlag=true;
% conf.HourPlot.Type='OI';
% %% Mona Passage Point
% conf.Data.point=[-67-30/60,18+10/60];
% conf.Save.directory='/Users/hroarty/COOL/01_CODAR/02_Collaborations/Puerto_Rico/20170418_CARICOOS_Meeting/';

conf.Plot.script_name='time_series_from_05.m';
conf.Data.Institution='Rutgers University';
conf.Data.Contact='Hugh Roarty hroarty@marine.rutgers.edu';
conf.Data.Info={'This data file is the time, U and V of a point in the CODAR field'};


dtime=datenum(2016,12,1,0,0,2):1/24:datenum(2017,3,31,0,0,0);
tick.major=30;
tick.minor=7;

%% create strings to use in the map filename
timestr_sd=datestr(dtime(1),'yyyymmdd');
timestr_ed=datestr(dtime(end),'yyyymmdd');


% % F=filenames_standard_filesystem(conf.Radials.BaseDir,conf.Radials.Sites,...
% %     conf.Radials.Types,dtime,conf.Radials.MonthFlag,conf.Radials.TypeFlag,...
% %     conf.Totals.HourFlag,conf.Totals.SuffixFlag);
% 
% s=conf.HourPlot.Type;
% 
% [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,...
%     conf.(s).FileSuffix,conf.(s).MonthFlag, conf.Totals.HourFlag);
% 
% numFiles = length(f);
% 
% U=[];
% V=[];
% dtime2=[];
% 
% 
% 
% for ii = 1:numFiles
%     try
%      fprintf('Loading file %u of %u\n ',ii,numFiles);
%     
%      data=load(f{ii});
%      d=dist(conf.point(1),conf.point(2),data.TUV.LonLat(:,1),data.TUV.LonLat(:,2));
%      
%      %% find the closest grid point
%      [Y,I] = min(d);
%      
%      %% find grid points within a certain distance
%      d2=deg2km(d); % convert the degrees to km
%      I2=d2<6; % find the index of the points within the distance
%      
%      U=[U;nanmean(data.TUV.U(I2))];
%      V=[V;nanmean(data.TUV.V(I2))];
%      dtime2=[dtime2;data.TUV.TimeStamp];
%      
%      clear data
%      
%      catch
%         fprintf('Can''t load %s ... skipping\n',f{ii});
%         
%     end
% 
% end
% 
% % Insert the metadata into the file
% var.MetaData.Script=conf.Plot.script_name;
% var.MetaData.Institution=conf.Data.Institution;
% var.MetaData.Contact=conf.Data.Contact;
% var.MetaData.Information=conf.Data.Info;
% 
% % Insert the data into the file
% var.U=U;
% var.V=V;
% var.dtime2=dtime2;
% var.conf.Data.point=conf.point;
% 
% save([conf.Save.directory 'CODAR_point_time_series_' conf.Totals.DomainName ...
%     '_' timestr_sd '_' timestr_ed '.mat'], '-struct', 'var');






%% calculate the low pass filtered time series
%% Get the lowpass filtered data
per=32;
om=2*pi/per;
ns=64;




%% Start script from here if you already have the data
% conf.datapath='/Users/hroarty/COOL/01_CODAR/02_Collaborations/Puerto_Rico/20170418_CARICOOS_Meeting/';
% data=load([conf.datapath 'CODAR_point_time_series_CARA_20151201_20161130.mat']);
conf.datapath='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20171214_Currents_For_Josh/';
data=load([conf.datapath 'CODAR_point_time_series_MARA_20161201_20170330.mat']);

% U=inpaint_nans(data.U);
% V=inpaint_nans(data.V);
U=data.U;
V=data.V;
dtime2=data.dtime2;


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
[dir,speed]=uv2compass(ur,vr);

[dir_lo,speed_lo]=uv2compass(harbor_low_ur,harbor_low_vr);

%% Figure 1  Magnitude and driection of the raw data
figure(1)
subplot(2,1,1)
plot(dtime2,speed)
title(['Time Series at ' num2str(conf.point(1)) ' Lon & ' num2str(conf.point(2)) ' Lat'])
format_axis(gca,min(dtime2),max(dtime2),24*tick.major/24,24*tick.minor/24,'mm/dd/yy',0,60,10)
ylabel('Current Magnitude (cm/s)')

subplot(2,1,2)
plot(dtime2,dir)
format_axis(gca,min(dtime2),max(dtime2),24*tick.major/24,24*tick.minor/24,'mm/dd/yy',0,360,60)
ylabel('Current Direction Toward (deg N)')

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_05.m')
print(1,'-dpng','-r400',[ conf.Plot.PrintPath conf.Totals.DomainName '_MAG_DIR_ts_' timestr_sd '_' timestr_ed '_ts_index.png'])

% Figure 4 Magnitude and driection of the low pass data
figure(4)
subplot(2,1,1)
plot(tlow_ur,speed_lo)
title(['32 Hour Low Pass Time Series at ' num2str(conf.point(1)) ' Lon & ' num2str(conf.point(2)) ' Lat'])
format_axis(gca,min(dtime2),max(dtime2),24*tick.major/24,24*tick.minor/24,'mm/dd/yy',0,60,10)
ylabel('Current Magnitude (cm/s)')

subplot(2,1,2)
plot(tlow_ur,dir_lo)
format_axis(gca,min(dtime2),max(dtime2),24*tick.major/24,24*tick.minor/24,'mm/dd/yy',0,360,60)
ylabel('Current Direction Toward (deg N)')

timestamp(4,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_05.m')
print(4,'-dpng','-r400',[ conf.Plot.PrintPath conf.Totals.DomainName '_Low_Pass_MAG_DIRts_' timestr_sd '_' timestr_ed '_ts_index.png'])


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
time_var=[12 1:11];
%% declare the time column you want to calculate the mean for
%% 2 for monthly means
%% 3 for daily means
time_column=2;

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
title(['Time Series at ' num2str(conf.point(1)) ' Lon & ' num2str(conf.point(2)) ' Lat'])
format_axis(gca,min(dtime2),max(dtime2),24*tick.major/24,24*tick.minor/24,'mm/dd',-60,60,10)
% legend('Along Shelf','Daily Mean','Low Pass','Location','NorthEast');
legend('V Velocity','Monthly Mean','Low Pass','Location','NorthEast');
ylabel('Velocity (cm/s)')
%title({[siteName ' ' radType ' Bearing ' num2str(bearing)]; 'Real Time Quality Metrics'})
set(gca,'TickDir','out')
timestamp(2,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_05.m')
print(2,'-dpng','-r400',[conf.Plot.PrintPath conf.Totals.DomainName '_V_ts_' timestr_sd '_' timestr_ed '_ts_index.png'])

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
title(['Time Series at ' num2str(conf.point(1)) ' Lon & ' num2str(conf.point(2)) ' Lat'])
format_axis(gca,min(dtime2),max(dtime2),24*tick.major/24,24*tick.minor/24,'mm/dd',-60,60,10)
% legend('Cross Shelf','Daily Mean','Low Pass','Location','NorthEast');
legend('U Velocity','Monthly Mean','Low Pass','Location','NorthEast');
ylabel('Velocity (cm/s)')
%title({[siteName ' ' radType ' Bearing ' num2str(bearing)]; 'Real Time Quality Metrics'})
set(gca,'TickDir','out')
timestamp(3,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_05.m')
print(3,'-dpng','-r400',[ conf.Plot.PrintPath conf.Totals.DomainName '_U_ts_' timestr_sd '_' timestr_ed '_ts_index.png'])
toc

%  save [conf.Plot.PrintPath conf.Totals.DomainName '_' timestr_sd '_' timestr_sd '_time_series.mat']


