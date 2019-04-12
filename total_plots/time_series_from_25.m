%% This m script was written to extract time series data from the grid points 
%% that are closest to the virtual meterological towers for the BPU project

%% determine which computer you are running the script on
compType = computer;

if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes';
else
     root = '/home';
end

%% load the total data
        
conf.Totals.DomainName='MARASR';
conf.Totals.BaseDir=[root '/codaradm/data/totals/maracoos/oi/mat/25MHz/'];
conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix='.mat';
conf.Totals.MonthFlag=1;

dtime=datenum(2013,10,6,0,0,2):1/24:datenum(2013,10,15,00,0,0);

%% create strings to use in the map filename
timestr_sd=datestr(dtime(1),'yyyymmdd');
timestr_ed=datestr(dtime(end),'yyyymmdd');


% F=filenames_standard_filesystem(conf.Radials.BaseDir,conf.Radials.Sites,...
%     conf.Radials.Types,dtime,conf.Radials.MonthFlag,conf.Radials.TypeFlag);

[f]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime,conf.Totals.FilePrefix,conf.Totals.FileSuffix,conf.Totals.MonthFlag);

%% Concatenate the total data
[TUVcat,goodCount]=catTotalStructs(f,'TUV');

d=dist(-74,40+31/60,TUVcat.LonLat(:,1),TUVcat.LonLat(:,2));

[Y,I] = min(d);


%% subplot 211
plot(TUVcat.TimeStamp,TUVcat.U(I,:),'r')
hold on
plot(TUVcat.TimeStamp,TUVcat.V(I,:),'b')

%% FIGURE 2 FORMATTING
format_axis(gca,min(TUVcat.TimeStamp),max(TUVcat.TimeStamp),24*3/24,12/24,'mm/dd',-60,60,10)
legend('U','V','Location','NorthEast');
ylabel('Total Velocity (cm/s)')
%title({[siteName ' ' radType ' Bearing ' num2str(bearing)]; 'Real Time Quality Metrics'})

set(gca,'TickDir','out')

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_25.m')

print(1,'-dpng','-r400',[ conf.Totals.DomainName '_' timestr_sd '_' timestr_ed '_ts_index_' num2str(I) '.png'])


