
%% this m script will generate daily mean surface current plots along with wind

close all
clear all

tic



%% Define some configuration parameters
conf.start_date=datenum(2012,01,01);
conf.end_date=datenum(2012,12,31);
conf.x_interval=30;
conf.date_format='mm/dd';
conf.ymin=-40;
conf.ymax=40;
conf.y_interval=10;
conf.quad={'NE','SE','SW','NW'};

conf.wind.scale=10;
conf.wind.origin=[-74.5 40];
conf.wind.text=[-74.65 39.85];

conf.HourPlot.axisLims= [-74-20/60 -73-50/60 40+20/60 40+40/60];
conf.HourPlot.CoastFile='/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.HourPlot.windscale=0.1*30;
conf.HourPlot.ColorTicks=0:3:30;
conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131004_NYH_Analysis/Daily_Means/';
conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.DomainName='MARASR';
% conf.HourPlot.plotData_xargs={2};%% use this for plot_vel
% conf.HourPlot.plotData_xargs={'Length',5,'Width',5};%,'Page'};
conf.HourPlot.Type='OI';%% this can be OI or UWLS
conf.HourPlot.script='/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/mean_daily_vector_plot_wrapper_25.m';
conf.HourPlot.grid=1;% this controls how many vectors get plotted
conf.HourPlot.Mask='/Users/hroarty/data/mask_files/25MHz_Mask_Box.txt';

conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/25MHz/';
conf.OI.FilePrefix=['tuv_oi_' conf.HourPlot.DomainName '_'];
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;





month_time=datenum(2013,9,20,0,0,2):1:datenum(2013,10,4,0,0,0);


for jj =1:length(month_time)-1
    
    dtime = month_time(jj):1/24:month_time(jj+1);
    
    
    %% load the total data depending on the config
    s=conf.HourPlot.Type;
    [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);


    %% concatenate the total data
    [TUVcat,goodCount] = catTotalStructs(f,'TUV');
    
    %% mask the totals removing grid points outside New York Harbor
    [TUVcat,I]=maskTotals(TUVcat,conf.HourPlot.Mask,true);



    %% calculate the percent coverage at aech grid point
    coverage = 100 * sum( isfinite(TUVcat.U+TUVcat.V), 2 ) / size(TUVcat.U,2);

    %% find the grid points less that 50% coverage
    ind=find(coverage<50);

    %% set the velocity in the grid points below 50% coverage to Nans
    TUVcat.U(ind,:)=NaN;
    TUVcat.V(ind,:)=NaN;

    %% calculate the mean only when you have 50% data coverage for the day
    TUV.dayM=nanmeanTotals(TUVcat,2);

    mean_vector_plot_fn_02(TUV.dayM,conf);
   
    set(gca, 'LooseInset', get(gca, 'TightInset'))
    
    close all
end



toc











