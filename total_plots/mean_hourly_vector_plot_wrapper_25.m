
%% this m script will generate daily mean surface current plots along with wind

close all
clear all

tic



%% Define some configuration parameters
conf.start_date=datenum(2016,09,02,16,0,0);
conf.end_date=datenum(2016,09,04,19,0,0);
conf.x_interval=30;
conf.date_format='mm/dd';
conf.ymin=-40;
conf.ymax=40;
conf.y_interval=10;
conf.quad={'NE','SE','SW','NW'};

conf.wind.scale=10;
conf.wind.origin=[-74.5 40];
conf.wind.text=[-74.65 39.85];


conf.HourPlot.CoastFile='/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.HourPlot.windscale=0.1*30;
conf.HourPlot.ColorTicks=0:20:100;
conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20160906_Hermine_Prep/20160930_DEL_Plots/';
conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.DomainName='MARASR';
conf.HourPlot.DomainNameTitle='MARACOOS 25MHz';
conf.HourPlot.name='MARACOOS_25MHz';

conf.HourPlot.TypeMean=0;
% conf.HourPlot.plotData_xargs={2};%% use this for plot_vel
% conf.HourPlot.plotData_xargs={'Length',5,'Width',5};%,'Page'};
conf.HourPlot.Type='OI';%% this can be OI or UWLS
conf.HourPlot.script='/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/mean_hourly_vector_plot_wrapper_25.m';
conf.HourPlot.grid=1;% this controls how many vectors get plotted


conf.HourPlot.Bathy='/Users/hroarty/data/bathymetry/marcoos_15second_ngdc.mat';


conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/25MHz/';
conf.OI.FilePrefix=['tuv_oi_' conf.HourPlot.DomainName '_'];
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;

%% NYH
% conf.HourPlot.axisLims= [-74-15/60 -73-56/60 40+24/60 40+38/60];
% conf.HourPlot.region='NYH';
% conf.HourPlot.Mask='/Users/hroarty/data/mask_files/25MHz_Mask.txt';
% conf.HourPlot.bathylines=[-5 -10 -15 -20];

%% Delaware Bay
conf.HourPlot.axisLims=[-75-15/60 -74-45/60 38+40/60 39+00/60];
conf.HourPlot.region='DEL';
conf.Totals.MaxTotSpeed=300;
conf.OI.cleanTotalsVarargin={{'OIuncert','Uerr',0.5},{'OIuncert','Verr',0.5},{'OIuncert','UVCovariance',0.5}};
conf.HourPlot.Mask=[-74.5 38.3; -74.5 39.5; -75.5 39.5; -75.5 38.3;-74.5 38.3];
conf.HourPlot.bathylines=[-10 -20];

%% create the time variable
dtime=conf.start_date:1/24:conf.end_date;


for jj =1:length(dtime)
        
    %% load the total data depending on the config
    s=conf.HourPlot.Type;
    [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);


    %% load the total data
     load(f{jj},'TUV');
    
    %% mask the totals removing grid points outside the plotting area
    [TUV,I]=maskTotals(TUV,conf.HourPlot.Mask,true);
    
    %% clean the totals to eliminate the baseline problem
    TUV=cleanTotals(TUV,conf.Totals.MaxTotSpeed,conf.OI.cleanTotalsVarargin{:});
    
    dtime2=dtime(jj);
    
    mean_vector_plot_fn_02(TUV,conf,dtime2);
   
    set(gca, 'LooseInset', get(gca, 'TightInset'))
    
    close all
end



toc











