
%% this m script will generate daily mean surface current plots along with wind

close all
clear all

tic



%% Define some configuration parameters
conf.start_date=datenum(2017,5,1,0,0,0);
conf.end_date=datenum(2017,5,2,23,0,0);
conf.x_interval=30;
conf.date_format='mm/dd';
conf.ymin=-40;
conf.ymax=40;
conf.y_interval=10;
conf.quad={'NE','SE','SW','NW'};

conf.wind.scale=10;
conf.wind.origin=[-74.5 40];
conf.wind.text=[-74.65 39.85];

conf.HourPlot.region='regionS';

switch conf.HourPlot.region
    case 'regionALL'
    lims=[-77 -68 35 43];%ALL MAB
    case 'region01'
    lims=[-71 -68 40 43];% North
    case 'region02'
    lims=[-72 -69 39 41.5];% RI
    case 'region03'
    lims=[-75 -73 38.5 40.75];% NJ
    case 'region04'
    lims=[-76 -72 37 39];% MD
    case 'region05'
    lims=[-76 -73 35 37];% VA NC
    case 'regionS'
    lims=[-77 -73 34 39];
end

mask2=[lims([1 2 2 1 1]);lims([3 3 4 4 3])];
mask2=mask2';

conf.HourPlot.axisLims= lims;
conf.HourPlot.CoastFile='/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.HourPlot.windscale=0.1*30;
conf.HourPlot.ColorTicks=0:5:30;
% conf.HourPlot.ColorTicks=0:10:60;
% conf.HourPlot.ColorTicks=0:3:15;
% conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20151001_Juaquin_Prep/20151002_Daily_Average_5MHz/';
% conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20160930_QC_Check/';
% conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180201_2017_Reprocessing/20180305_Reprocessing_Analysis/';
conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180201_2017_Reprocessing/20180308_May1_Reprocessing/';

conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.DomainName='MARACOOS';
conf.HourPlot.name='MARA_50perc';
% conf.HourPlot.plotData_xargs={2};%% use this for plot_vel
% conf.HourPlot.plotData_xargs={'Length',5,'Width',5};%,'Page'};
conf.HourPlot.Type='OI';%% this can be OI or UWLS
conf.HourPlot.script='/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/mean_daily_vector_plot_wrapper_05.m';
conf.HourPlot.grid=1;
conf.HourPlot.Bathy='/Users/hroarty/data/bathymetry/eastcoast.mat';
conf.HourPlot.bathylines=[ -50 -80 -200 -1000];
conf.HourPlot.TypeMean=1;
conf.HourPlot.ColorMap=jet(64);
conf.HourPlot.resolution='-r300';


%% curly vector formatting
conf.HourPlot.np=1;
conf.HourPlot.arrow=1;
conf.HourPlot.thin=1;
conf.HourPlot.color='black';


conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/';
% conf.OI.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180201_2017_Reprocessing/20180301_May_Reprocessing/totals/maracoos/oi/mat/5MHz/';
conf.OI.combo='Combo1_Neg';
% conf.OI.BaseDir=['/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180201_2017_Reprocessing/20180308_May1_Reprocessing/' conf.OI.combo '/totals/maracoos/oi/mat/5MHz'];
conf.OI.FilePrefix='tuv_oi_MARA_';
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;
conf.OI.HourFlag=false;
conf.OI.cleanTotalsVarargin={{'OIuncert','Uerr',0.6},{'OIuncert','Verr',0.6},{'OIuncert','UVCovariance',0.6}};
conf.Totals.MaxTotSpeed=300;




% month_time=conf.start_date:1:conf.end_date;
month_time=[conf.start_date conf.end_date];
%month_time=[datenum(2014 ,10:12 ,1)];
%month_time=[datenum(2015 ,8 ,5:6)];

for jj =1:length(month_time)-1
    
    dtime = month_time(jj):1/24:month_time(jj+1);
    
    
    %% load the total data depending on the config
    s=conf.HourPlot.Type;
%     [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,...
%         conf.(s).FileSuffix,conf.(s).MonthFlag,conf.(s).HourFlag);
    [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,...
        conf.(s).FileSuffix,conf.(s).MonthFlag);

    %% concatenate the total data
    [TUVcat,goodCount] = catTotalStructs(f,'TUV',1,0,1,mask2);
%     [TUVcat,goodCount] = catTotalStructs(f,'TUVoi',1,0,1,mask2);
    %% clean the totals to eliminate the baseline problem
    TUVcat=cleanTotals(TUVcat,conf.Totals.MaxTotSpeed,conf.OI.cleanTotalsVarargin{:});

    %% calculate the percent coverage at each grid point
    coverage = 100 * sum( isfinite(TUVcat.U+TUVcat.V), 2 ) / size(TUVcat.U,2);

    %% find the grid points less that 50% coverage
    ind=find(coverage<50);

    %% set the velocity in the grid points below 50% coverage to Nans
    TUVcat.U(ind,:)=NaN;
    TUVcat.V(ind,:)=NaN;



    %% calculate the mean only when you have 50% data coverage for the day
    TUV.dayM=nanmeanTotals(TUVcat,2);
    
    %% Mask the totals outside the plotting limits
    TUV.dayM=maskTotals( TUV.dayM,mask2,1);
 
    mean_vector_plot_fn_02(TUV.dayM,conf,dtime);
    
%     curly_vector_plot_fn(TUV.dayM,conf);
    
    %% create a mat file of the daily mean and save it
%     sd_str2=datestr(TUVcat.TimeStamp(1),'yyyymmdd');
%     savefile=['/Users/hroarty/COOL/01_CODAR/Erick_Fredj/20140218_Daily_Means/TUV_' ...
%         conf.HourPlot.DomainName '_50percent_' sd_str2 '.mat'];
%     save(savefile,'TUV')
    
    close all
    
    clear sd_str2 savefile
end



toc











