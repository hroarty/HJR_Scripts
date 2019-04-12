
%% this m script will generate daily mean surface current plots along with wind

close all
clear all

tic



%% Define some configuration parameters
conf.start_date=datenum(2015,8,18);
conf.end_date=datenum(2015,9,9);
conf.x_interval=30;
conf.date_format='mm/dd';
conf.ymin=-40;
conf.ymax=40;
conf.y_interval=10;
conf.quad={'NE','SE','SW','NW'};

conf.wind.scale=10;
conf.wind.origin=[-74.5 40];
conf.wind.text=[-74.65 39.85];

conf.HourPlot.axisLims=[-75-20/60 -74-40/60 38+30/60 39+5/60];
%conf.HourPlot.axisLims= [-74-20/60 -73 40 40+40/60];
conf.HourPlot.CoastFile='/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.HourPlot.windscale=0.1*30;
conf.HourPlot.ColorTicks=0:3:15;
%conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20141103_YR4.0_progress/nj13_average_vectors/';
%conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131217_Sandy_Award/29150909_SEAB_Inspection/';
conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20151202_YR5.0_Progress/Del_Bay/';
conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.DomainName='MARASR';
conf.HourPlot.name=[ conf.HourPlot.DomainName '_50perc'];
conf.HourPlot.region='ALL';
% conf.HourPlot.plotData_xargs={2};%% use this for plot_vel
% conf.HourPlot.plotData_xargs={'Length',5,'Width',5};%,'Page'};
conf.HourPlot.Type='OI';%% this can be OI or UWLS
conf.HourPlot.script='/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/mean_daily_vector_plot_wrapper_25_Delaware_Bay.m';
conf.HourPlot.grid=1;
%conf.HourPlot.Mask=[conf.HourPlot.axisLims([1 2 2 1 1])',conf.HourPlot.axisLims([3 3 4 4 3])'];
conf.HourPlot.mask=[-74.5 38.3; -74.5 39.5; -75.5 39.5; -75.5 38.3;-74.5 38.3];

conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/25MHz/';
conf.OI.FilePrefix=['tuv_oi_' conf.HourPlot.DomainName '_'];
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;
conf.OI.cleanTotalsVarargin={{'OIuncert','Uerr',0.5},{'OIuncert','Verr',0.5},{'OIuncert','UVCovariance',0.5}};
%conf.OI.cleanTotalsVarargin={{'OIuncert','UVCovariance',0.5}};
conf.Totals.MaxTotSpeed=300;




%month_time=conf.start_date:1:conf.end_date;
%month_time=[conf.start_date conf.end_date];
month_time=[datenum(2015 ,6:12 ,1)];

for jj =1:length(month_time)-1
    
    dtime = month_time(jj):1/24:month_time(jj+1);
    
    
    %% load the total data depending on the config
    s=conf.HourPlot.Type;
    [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);


    %% concatenate the total data
    [TUVcat,goodCount] = catTotalStructs(f,'TUV',true,false,true,conf);



    %% calculate the percent coverage at aech grid point
    coverage = 100 * sum( isfinite(TUVcat.U+TUVcat.V), 2 ) / size(TUVcat.U,2);

    %% find the grid points less that 50% coverage
    ind=find(coverage<50);

    %% set the velocity in the grid points below 50% coverage to Nans
    TUVcat.U(ind,:)=NaN;
    TUVcat.V(ind,:)=NaN;
    
    %% mask the totals outside the plot limits
    TUVcat=maskTotals(TUVcat,conf.HourPlot.mask);
    
    %% clean the totals to eliminate the baseline problem
    TUVcat=cleanTotals(TUVcat,conf.Totals.MaxTotSpeed,conf.OI.cleanTotalsVarargin{:});


    %% calculate the mean only when you have 50% data coverage for the day
    TUV.dayM=nanmeanTotals(TUVcat,2);

    mean_vector_plot_fn_02(TUV.dayM,conf);
    
    %% create a mat file of the daily mean and save it
%     sd_str2=datestr(TUVcat.TimeStamp(1),'yyyymmdd');
%     savefile=['/Users/hroarty/COOL/01_CODAR/Erick_Fredj/20140218_Daily_Means/TUV_' ...
%         conf.HourPlot.DomainName '_50percent_' sd_str2 '.mat'];
%     save(savefile,'TUV')
    
    close all
    
    clear sd_str2 savefile
end



toc











