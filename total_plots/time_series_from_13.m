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

%% configuration data
        
conf.Totals.DomainName='MARA';
conf.Totals.BaseDir=[root '/codaradm/data/totals/maracoos/oi/mat/5MHz/'];
conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix='.mat';
conf.Totals.MonthFlag=1;

conf.Plot.PrintPath='/Users/hroarty/COOL/STUDENT_ITEMS/Robert_Forney_2013/Paper/20150109_Time_Series_Plots/';

%dtime=datenum(2014,8,1,0,0,2):1/24:datenum(2014,10,1,0,0,0);




% F=filenames_standard_filesystem(conf.Radials.BaseDir,conf.Radials.Sites,...
%     conf.Radials.Types,dtime,conf.Radials.MonthFlag,conf.Radials.TypeFlag);
% 
% [f]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime,conf.Totals.FilePrefix,conf.Totals.FileSuffix,conf.Totals.MonthFlag);
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
%      d=dist(point(1),point(2),data.TUV.LonLat(:,1),data.TUV.LonLat(:,2));
%      [Y,I] = min(d);
%      
%      U=[U;data.TUV.U(I)];
%      V=[V;data.TUV.V(I)];
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
% mag=sqrt(U.^2 + V.^2);
% plot(dtime2,mag)
% X_hashes=datenum(2014,9,18,0,0,2):4/24:datenum(2014,9,19,11,0,0);
% set(gca,'XTick',X_hashes,'XTicklabel',datestr(X_hashes,'HH:MM'))
% title(['Time Series at ' num2str(point(1)) ' Lon & ' num2str(point(2)) ' Lat'])

%% ************************************************************************
%% Start script from here if you already have the data
%% ************************************************************************
point=[-74.2,39.1];


load BPU_Total_CAT_20120801_20121001


dtime2=Tnotide.TimeStamp;

%% create strings to use in the map filename
timestr_sd=datestr(dtime2(1),'yyyymmdd');
timestr_ed=datestr(dtime2(end),'yyyymmdd');

data_type='TUVcat';

d=dist(point(1),point(2),Tnotide.LonLat(:,1),Tnotide.LonLat(:,2));
[Y,I] = min(d);

U=Tnotide.U(I,:);
V=Tnotide.V(I,:);

region='region4';
[wp,wp2,rot]=fn_region_geometry(region);

%% rotate the u and v into a cross shelf and along shelf current
[ur, vr] = dg_rotate_refframe(U,V,rot);

%% calculate the daily mean
time_interval=24;%24 for a daily mean since it is hourly data
                    %24*30 for monthly mean
                    
days=floor(Tnotide.TimeStamp);

unique_days=unique(days);

for ii=1:length(unique_days);
    ind=days==unique_days(ii);
    UR.daily_mean(ii)=nanmean(ur(ind));
    VR.daily_mean(ii)=nanmean(vr(ind));
    
    UR.daily_std(ii)=nanstd(ur(ind));
    VR.daily_std(ii)=nanstd(vr(ind));
    
    UR.daily_N(ii)=sum(ind);
    VR.daily_N(ii)=sum(ind);
    
    
end

%% error bar
%vr_error_bar=vr_ti_std*1.96./sqrt(vr_data_pts);


subplot 211
hold on
plot(dtime2,ur,'r')
%errorbar(unique_days,VR.daily_mean,VR.daily_std,'k','LineWidth',2)
legend('Cross Shelf')
%format_axis(gca,min(dtime2),max(dtime2),24*7/24,24*1/24,'mm/dd',-50,50,10)
format_axis(gca,datenum(2012,8,29),datenum(2012,9,8),24*7/24,24*1/24,'mm/dd',-80,80,20)
ylabel('Velocity (cm/s)')

subplot 212
hold on
plot(dtime2,ur,'r')
%errorbar(unique_days,VR.daily_mean,VR.daily_std,'k','LineWidth',2)
%legend('Along Shelf')
%plot(dtime2_daily_mean,vr_daily_mean,'bs')
%errorbar(dtime2_ti_mean,vr_ti_mean,vr_ti_std,'k','LineWidth',2)

%format_axis(gca,min(dtime2),max(dtime2),24*7/24,24*1/24,'mm/dd',-70,70,10)
format_axis(gca,datenum(2012,9,8),datenum(2012,9,20),24*7/24,24*1/24,'mm/dd',-80,80,20)

ylabel('Velocity (cm/s)')
%title({[siteName ' ' radType ' Bearing ' num2str(bearing)]; 'Real Time Quality Metrics'})

set(gca,'TickDir','out')

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_13.m')

print(1,'-dpng','-r400',[ conf.Plot.PrintPath conf.Totals.DomainName '_' timestr_sd '_' timestr_ed '_ts_index_' num2str(I) '_cross_shelf_NO_tide.png'])

toc


