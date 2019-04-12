
conf.Totals.DomainName='MARA';
conf.Totals.BaseDir='/Users/hroarty/data/totals/';
conf.Totals.FilePrefix=strcat('tuv_oi_',conf.Totals.DomainName,'_');
conf.Totals.FileSuffix='.mat';
conf.Totals.MonthFlag='true';

dtime=datenum(2011,08,23,0,0,0):1/24:datenum(2011,08,30,23,0,0);  

% F=filenames_standard_filesystem(conf.Radials.BaseDir,conf.Radials.Sites,...
%     conf.Radials.Types,dtime,conf.Radials.MonthFlag,conf.Radials.TypeFlag);

[f]=datenum_to_directory_filename(conf.Totals.BaseDir,dtime,conf.Totals.FilePrefix,conf.Totals.FileSuffix,conf.Totals.MonthFlag);

%addpath '/Users/hroarty/data/totals/2011_08'

[TUVcat,goodCount]=catTotalStructs(f,'TUV');

subplot(211)
plot(TUVcat.TimeStamp,TUVcat.U(2300,:),'b')
hold on
plot(TUVcat.TimeStamp,TUVcat.U(2301,:),'r')
plot(TUVcat.TimeStamp,TUVcat.U(2407,:),'g')
plot(TUVcat.TimeStamp,TUVcat.U(2408,:),'k')
datetick('x','mm/dd')
grid on
Title('U Velocity Time Series at Grid Point Closest to 74.5W 37.2N')
%legend('Grid Point 8215','Grid Point 8216')
legend('Grid Point 2300','Grid Point 2301','Grid Point 2407','Grid Point 2408')

subplot(212)
plot(TUVcat.TimeStamp,TUVcat.V(2300,:),'b')
hold on
plot(TUVcat.TimeStamp,TUVcat.V(2301,:),'r')
plot(TUVcat.TimeStamp,TUVcat.V(2407,:),'g')
plot(TUVcat.TimeStamp,TUVcat.V(2408,:),'k')

datetick('x','mm/dd')
grid on
Title('V Velocity Time Series at Grid Point Closest to 74.5W 37.2N')
%legend('Grid Point 8215','Grid Point 8216')
%legend('Grid Point 2300','Grid Point 2301','Grid Point 2407','Grid Point 2408')


timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/time_series_from_TUV.m')

%print('-dpng','-r300','Laura_Grid_Point_71_41_ts.png');





