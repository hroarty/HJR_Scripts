
%% this m script will generate daily mean surface current plots along with wind

close all
clear all

tic



%% Define some configuration parameters
conf.start_date=datenum(2016,5,23,15,0,0);
conf.end_date=datenum(2016,5,23,18,0,0);
conf.x_interval=30;
conf.date_format='mm/dd';
conf.ymin=-40;
conf.ymax=40;
conf.y_interval=10;
conf.quad={'NE','SE','SW','NW'};

conf.wind.scale=10;
conf.wind.origin=[-74.5 40];
conf.wind.text=[-74.65 39.85];

% conf.HourPlot.axisLims= [-75 -73 38.5 40.75];
conf.HourPlot.axisLims= [-75-00/60 -73-00/60 38+30/60 41+00/60];% NJ shelf
conf.HourPlot.axisLims= [-74-15/60 -73-15/60 39+30/60 40+15/60];% NJ shelf
conf.HourPlot.CoastFile='/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.HourPlot.windscale=0.1*30;
conf.HourPlot.ColorTicks=0:5:40;
% conf.HourPlot.ColorTicks=0:10:50;
%conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20141103_YR4.0_progress/nj13_average_vectors/';
%conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131217_Sandy_Award/29150909_SEAB_Inspection/';
%conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20151202_YR5.0_Progress/nj13_average/'
% conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20160930_QC_Check/';
% conf.HourPlot.print_path='//Users/hroarty/COOL/01_CODAR/MARACOOS_II/20170622_Bacteria_Counts/';
% conf.HourPlot.print_path = '/Users/hroarty/COOL/01_CODAR/South_Africa/20171201_South_Africa_Talk/';
% conf.HourPlot.print_path = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20160410_CG_Drifter_Experiment/20180201_13_Daily_Maps/';
% conf.HourPlot.print_path ='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160410_CG_Drifter_Experiment/20180202_13_Gap_Filled_Maps/';
conf.HourPlot.print_path ='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160410_CG_Drifter_Experiment/20180530_Maps_Clean/';

conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.DomainName='BPU';
conf.HourPlot.name='MARACOOS_2km_13MHz';
conf.HourPlot.TitleName='MARACOOS 2km 13MHz';
conf.HourPlot.region='ALL';
% conf.HourPlot.plotData_xargs={2};%% use this for plot_vel
% conf.HourPlot.plotData_xargs={'Length',5,'Width',5};%,'Page'};
conf.HourPlot.Type='OI';%% this can be OI or UWLS
conf.HourPlot.script='/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/hourly_vector_plot_wrapper_13.m';
conf.HourPlot.grid=1;
conf.HourPlot.Mask=[conf.HourPlot.axisLims([1 2 2 1 1])',conf.HourPlot.axisLims([3 3 4 4 3])'];
% conf.HourPlot.Bathy='/Users/hroarty/data/bathymetry/marcoos_15second_ngdc.mat';
conf.HourPlot.Bathy='/Users/hroarty/data/bathymetry/eastcoast_4min.mat';
conf.HourPlot.bathylines=-10:-20:-100;
conf.HourPlot.TypeMean=0;
conf.HourPlot.resolution='-r100';

conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/13MHz/';
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/13MHz/measured/';
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/13MHz/ideal/';
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/13MHz/';
% conf.OI.BaseDir='/Volumes/hroarty/data/realtime/totals/maracoos/oi/mat/13MHz/';

conf.OI.FilePrefix='tuv_oi_BPU_';
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;
conf.OI.no_hour_flag=false;
conf.OI.combo='No_Clean';

conf.Totals.MaxTotSpeed=300;
conf.OI.cleanTotalsVarargin={{'OIuncert','Uerr',0.6},{'OIuncert','Verr',0.6},{'OIuncert','UVCovariance',0.6}};

conf.HourPlot.DomainNameTitle=[conf.HourPlot.TitleName ' TUV'];

month_time=conf.start_date:1/24:conf.end_date;         % Hourly Files
% month_time=conf.start_date:1:conf.end_date;         % Daily Means
% month_time=[conf.start_date conf.end_date];       % Single Mean
%month_time=[datenum(2015 ,6:12 ,1)];               % Monthly Means

for jj =1:length(month_time)
    
%     dtime = month_time(jj):1/24:month_time(jj+1);
    dtime=month_time(jj);
    
    
    %% load the total data depending on the config
    s=conf.HourPlot.Type;
    [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);


    %% concatenate the total data
    [TUVcat,goodCount] = catTotalStructs(f,'TUV',true,false,false);
%     [TUVcat,goodCount] = catTotalStructs(f,'TUVosn',true,false,false);
    
     TUVcat=cleanTotals(TUVcat,conf.Totals.MaxTotSpeed,conf.OI.cleanTotalsVarargin{:});



%     %% calculate the percent coverage at aech grid point
%     coverage = 100 * sum( isfinite(TUVcat.U+TUVcat.V), 2 ) / size(TUVcat.U,2);
% 
%     %% find the grid points less that 50% coverage
%     ind=find(coverage<50);
% 
%     %% set the velocity in the grid points below 50% coverage to Nans
%     TUVcat.U(ind,:)=NaN;
%     TUVcat.V(ind,:)=NaN;
    
    %% mask the totals outside the plot limits
    TUVcat=maskTotals(TUVcat,conf.HourPlot.Mask);



    %% calculate the mean only when you have 50% data coverage for the day
%     TUV.dayM=nanmeanTotals(TUVcat,2);

    mean_vector_plot_fn_02(TUVcat,conf,dtime);
    
    %% create a mat file of the daily mean and save it
%     sd_str2=datestr(TUVcat.TimeStamp(1),'yyyymmdd');
%     savefile=['/Users/hroarty/COOL/01_CODAR/Erick_Fredj/20140218_Daily_Means/TUV_' ...
%         conf.HourPlot.DomainName '_50percent_' sd_str2 '.mat'];
%     save(savefile,'TUV')
    
    close all
    
    clear sd_str2 savefile
end



toc











