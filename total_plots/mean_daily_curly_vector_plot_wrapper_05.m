
%% this m script will generate daily mean surface current plots along with wind

close all
clear all

tic



%% Define some configuration parameters

conf.x_interval=30;
conf.date_format='mm/dd';
conf.ymin=-40;
conf.ymax=40;
conf.y_interval=10;
conf.quad={'NE','SE','SW','NW'};

conf.wind.scale=10;
conf.wind.origin=[-74.5 40];
conf.wind.text=[-74.65 39.85];

conf.HourPlot.region='region05';

switch conf.HourPlot.region
    case 'regionALL'
    lims=[-77 -68 34 43];%ALL MAB
    case 'region01'
    lims=[-71 -68 40 43];% North
    case 'region02'
    lims=[-72 -69 39 41.5];% RI
    case 'region03'
    lims=[-75 -72 39 41];% NJ
    case 'region04'
    lims=[-76 -72 37 39];% MD
    case 'region05'
    lims=[-76 -73 33.5 37];% VA NC
    case 'special'
    lims=[-76 -70 36.5 42];% Highlight the shelf break front    
end

mask2=[lims([1 2 2 1 1]);lims([3 3 4 4 3])];
mask2=mask2';

conf.HourPlot.axisLims= lims;
conf.HourPlot.CoastFile='/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.HourPlot.windscale=0.1*30;
conf.HourPlot.ColorTicks=0:10:60;
% conf.HourPlot.ColorTicks=0:3:12;
% conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160108_Shelf_Break_Front/';
% conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20170426_Decadal_Figures/20170907_Yearly_Plots/Uncertainty_Threshold/';
conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180201_2017_Reprocessing/';
conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
% conf.HourPlot.ColorMap='autumn';
conf.HourPlot.DomainName='MARA';
% conf.HourPlot.name='MARA_50perc';
conf.HourPlot.name='HYCOM_50perc';
% conf.HourPlot.plotData_xargs={2};%% use this for plot_vel
% conf.HourPlot.plotData_xargs={'Length',5,'Width',5};%,'Page'};
conf.HourPlot.Type='UWLS';%% this can be OI or UWLS
conf.HourPlot.script='/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/mean_daily_vector_plot_wrapper_05.m';
conf.HourPlot.grid=1;

%% curly vector formatting
conf.HourPlot.np=1;
conf.HourPlot.arrow=1;
conf.HourPlot.thin=1;
conf.HourPlot.color='black';

conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/';
conf.OI.FilePrefix='tuv_oi_MARA_';
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;
conf.OI.HourFlag=false;
conf.OI.ErrorFlag=true;
conf.OI.OtherFlag=true;
conf.OI.MaskFlag=false;
conf.OI.cleanTotalsVarargin={{'OIuncert','Uerr',0.6},{'OIuncert','Verr',0.6},{'OIuncert','UVCovariance',0.6}};
% conf.OI.cleanTotalsVarargin={{'OIuncert','Uerr',1},{'OIuncert','Verr',1}};

conf.UWLS.BaseDir='/Volumes/codaradm/data/totals/maracoos/lsq/5MHz/';
conf.UWLS.FilePrefix='tuv_MARA_';
conf.UWLS.FileSuffix='.mat';
conf.UWLS.MonthFlag=true;
conf.UWLS.HourFlag=false;
conf.UWLS.ErrorFlag=true;
conf.UWLS.OtherFlag=true;
conf.UWLS.MaskFlag=false;
conf.UWLS.cleanTotalsVarargin={{'GDOP','TotalErrors',1.25}};

conf.Totals.MaxTotSpeed=300; 

% months=[datenum(2015 ,8:12 ,1)];
% month_time=datenum(2015,6:12,1);
%month_time=[conf.start_date conf.end_date];
%month_time=[datenum(2014 ,10:12 ,1)];
% month_time=datenum([2016 ,3 ,28,6,0,0;2016 ,3 ,29,6,0,0]);
% month_time=datenum([2015 ,1 ,1,0,0,0;2015 ,2 ,1,0,0,0]);
month_time=datenum(2017 ,5 ,1:31);
conf.start_date=min(month_time);
conf.end_date=max(month_time);

for jj =1:length(month_time)-1
    
    dtime = month_time(jj):1/24:month_time(jj+1);
    
    
    % load the total data depending on the config
    s=conf.HourPlot.Type;
    [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,...
        conf.(s).FileSuffix,conf.(s).MonthFlag,conf.(s).HourFlag);


    %% concatenate the total data
    
    [TUVcat,goodCount] = catTotalStructs(f,'TUV',conf.OI.ErrorFlag,...
        conf.OI.OtherFlag,conf.OI.MaskFlag);
    
    % create a mat file of the concatenated data and save it
    sd_str2=datestr(TUVcat.TimeStamp(1),'yyyy_mm');
%     savefile=['/Users/hroarty/COOL/01_CODAR/Erick_Fredj/20140218_Daily_Means/TUV_' ...
%         conf.HourPlot.DomainName '_50percent_' sd_str2 '.mat'];
    savefile=['/Users/hroarty/data/totals/Totals_6km_' sd_str2 '.mat'];
    save(savefile,'TUVcat')
%     
%     %% URL for the HYCOM current data
%     f = 'http://ecowatch.ncddc.noaa.gov/thredds/dodsC/hycom/hycom_reg1_agg/HYCOM_Region_1_Aggregation_best.ncd';
% 
%     %% Temporally concatenate the total files                                 
%     [TUVcat,~] = catTotalStructs_HYCOM_NC(f,dtime);

    %% clean the totals to eliminate the baseline problem
    TUVcat=cleanTotals(TUVcat,conf.Totals.MaxTotSpeed,conf.(s).cleanTotalsVarargin{:});
    
    %% calculate the percent coverage at aech grid point
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
 
    %mean_vector_plot_fn_02(TUV.dayM,conf);
    
%     conf.HourPlot.TitleString= {['Surface Current Mean: ' datestr(TUVcat.TimeStamp(1),'mmm dd, yyyy') ' to ' datestr(TUVcat.TimeStamp(end),'mmm dd, yyyy')];...
%         [ conf.OI.cleanTotalsVarargin{1}{2} ' < ' num2str(conf.OI.cleanTotalsVarargin{1}{3}) '  ' conf.OI.cleanTotalsVarargin{2}{2} ' < ' num2str(conf.OI.cleanTotalsVarargin{2}{3})...
%         '  ' conf.OI.cleanTotalsVarargin{3}{2} ' < ' num2str(conf.OI.cleanTotalsVarargin{3}{3})]};
    conf.HourPlot.TitleString= {['Surface Current Mean: ' datestr(TUVcat.TimeStamp(1),'mmm dd, yyyy') ' to ' datestr(TUVcat.TimeStamp(end),'mmm dd, yyyy')];...
        [ conf.UWLS.cleanTotalsVarargin{1}{2} ' < ' num2str(conf.UWLS.cleanTotalsVarargin{1}{3}) ]};
    
    curly_vector_plot_fn(TUV.dayM,conf);
    
%     %% create a mat file of the daily mean and save it
%     sd_str2=datestr(TUVcat.TimeStamp(1),'yyyy_mm');
% %     savefile=['/Users/hroarty/COOL/01_CODAR/Erick_Fredj/20140218_Daily_Means/TUV_' ...
% %         conf.HourPlot.DomainName '_50percent_' sd_str2 '.mat'];
%     savefile=['/Users/hroarty/data/totals/Totals_6km_' sd_str2 '.mat'];
%     save(savefile,'TUV')
    
    close all
    clear sd_str2 savefile
end

toc













