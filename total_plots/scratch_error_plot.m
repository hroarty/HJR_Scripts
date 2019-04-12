tic


close all
clear all


% Add HFR_Progs to the path
% addpath /Users/hroarty/Documents/MATLAB/HFR_Progs-2_1_3beta/matlab/general
% add_subdirectories_to_path('/Users/hroarty/Documents/MATLAB/HFR_Progs-2_1_3beta/matlab/',{'CVS','private','@'});



%% OI Total Configuration
%conf.Totals.DomainName = 'BPU';
conf.Totals.DomainName = 'MARA';
%conf.OI.BaseDir = '/Users/hroarty/data/totals/';
%conf.OI.BaseDir = '/Users/hroarty/COOL/01_CODAR/BPU/20120628_RAWO_effect/Totals/';
conf.OI.BaseDir = '/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/';
%conf.OI.AsciiDir = '/home/codaradm/data/totals/oi/ascii/';
conf.OI.FilePrefix = strcat('tuv_oi_',conf.Totals.DomainName,'_');
%conf.OI.FilePrefix = strcat('Mean_');
conf.OI.FileSuffix = '.mat';
conf.OI.MonthFlag = true;
conf.MonthFlag = true;

%% Plot Setup

%addpath /Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/
conf.Plot.coastFile = '/Users/hroarty/data/coast_files/MARA_coast.mat';
%conf.Plot.coastFile = '/Users/hroarty/data/coast_files/BPU3_coast.mat';
conf.Plot.Projection = 'Mercator';
conf.Plot.plotBasemap_xargs = {'patch',[.5 .9 .5],'edgecolor','k'};
conf.Plot.m_grid_xargs = {'linewidth',2,'linestyle','--','tickdir','out','fontsize',12,'box','on'};
conf.Plot.Speckle = false;

%% Hourly Plots Setup
conf.HourPlot.BaseDir = '/Users/hroarty/COOL/01_CODAR/OPT/ONT_paper/totals_no_bistatic/';
conf.HourPlot.Type='OI';
conf.HourPlot.FilePrefix = [ conf.Totals.DomainName '_oi1h_' ];
conf.HourPlot.axisLims = [-77 -73 34.5 37];
conf.HourPlot.VectorScale = .02;
conf.HourPlot.plotData_xargs={2};%% use this for plot_vel
conf.HourPlot.plotData_xargs={'Length',5,'Width',5};%,'Page'};
conf.HourPlot.VelocityScaleLocation = [-72.5 42];
conf.HourPlot.DistanceBarLength = 50;
conf.HourPlot.DistanceBarLocation = [-73 41.5];
conf.HourPlot.ColorTicks = [0:10:50];
conf.HourPlot.ColorMapBins=10;
conf.HourPlot.ColorMap='lines';
conf.HourPlot.Print=1;


%% Error Plots (default to FitDif)
conf.ErrorPlot.BaseDir = '/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/';
conf.ErrorPlot.FilePrefix = [ conf.Totals.DomainName '_fitdif_' ];
conf.ErrorPlot.TitlePrefix = [ 'LSQ Fit Difference: ' ];
conf.ErrorPlot.ColorTicks = [0:2:20];
conf.ErrorPlot.Error = 'FitDif';
conf.ErrorPlot.ErrorComponent = 'TotalErrors';
conf.ErrorPlot.axisLims = [-77 -73 34.5 37]; %MARC Region
conf.ErrorPlot.DistanceBarLength = 50;
conf.ErrorPlot.DistanceBarLocation = [-74.5 40.25];
conf.ErrorPlot.MarkerSize = 8;
conf.ErrorPlot.Print=false;
M=colormap7;
conf.ErrorPlot.ColorMap=M;

conf.ErrorPlot2.FilePrefix = [ conf.Totals.DomainName '_gdop_' ];
conf.ErrorPlot2.TitlePrefix = [ 'GDOP: ' ];
conf.ErrorPlot2.ColorTicks = [0:0.25:3];
conf.ErrorPlot2.Error = 'GDOP';
conf.ErrorPlot2.ErrorComponent = 'TotalErrors';

conf.ErrorPlot3.FilePrefix = [ conf.Totals.DomainName '_gdopU_' ];
conf.ErrorPlot3.TitlePrefix = [ 'GDOP Uerr: ' ];
conf.ErrorPlot3.ColorTicks = [0:0.25:3];
conf.ErrorPlot3.Error = 'GDOP';
conf.ErrorPlot3.ErrorComponent = 'Uerr';

conf.ErrorPlot4.FilePrefix = [ conf.Totals.DomainName '_gdopV_' ];
conf.ErrorPlot4.TitlePrefix = [ 'GDOP Verr: ' ];
conf.ErrorPlot4.ColorTicks = [0:0.25:3];
conf.ErrorPlot4.Error = 'GDOP';
conf.ErrorPlot4.ErrorComponent = 'Verr';

conf.ErrorPlot5.FilePrefix = [ conf.Totals.DomainName '_oiun_' ];
conf.ErrorPlot5.TitlePrefix = [ 'OI Uncertainty: ' ];
conf.ErrorPlot5.ColorTicks = [0:0.1:1.4];
conf.ErrorPlot5.Error = 'OIuncert';
conf.ErrorPlot5.ErrorComponent = 'TotalErrors';

conf.ErrorPlot6.FilePrefix = [ conf.Totals.DomainName '_oiunU_' ];
conf.ErrorPlot6.TitlePrefix = [ 'OI Uncertainty U: ' ];
conf.ErrorPlot6.ColorTicks = [0:0.2:1];
conf.ErrorPlot6.Error = 'OIuncert';
conf.ErrorPlot6.ErrorComponent = 'Uerr';

conf.ErrorPlot7.FilePrefix = [ conf.Totals.DomainName '_oiunV_' ];
conf.ErrorPlot7.TitlePrefix = [ 'OI Uncertainty V: ' ];
conf.ErrorPlot7.ColorTicks = [0:0.2:1];
% conf.ErrorPlot7.ColorTicks = [0 0.4 0.6 1];
conf.ErrorPlot7.Error = 'OIuncert';
conf.ErrorPlot7.ErrorComponent = 'Verr';

conf.ErrorPlot8.FilePrefix = [ conf.Totals.DomainName '_oiunUV_' ];
conf.ErrorPlot8.TitlePrefix = [ 'OI Uncertainty UV: ' ];
conf.ErrorPlot8.ColorTicks = [-.5:0.1:.5];
conf.ErrorPlot8.Error = 'OIuncert';
conf.ErrorPlot8.ErrorComponent = 'UVCovariance';

dtime=datenum(2018,4,17,17,0,0);

num='ErrorPlot6';

%% Plot OIuncert
  try
   fprintf('Starting MARC_driver_plot_errors OIuncert \n');
       MARC_driver_plot_errors_HJR(dtime,conf,'ErrorPlot.Print',false, ...
           'ErrorPlot.Type',           'OI', ...
           'ErrorPlot.FilePrefix',     conf.(num).FilePrefix, ...
           'ErrorPlot.TitlePrefix',    conf.(num).TitlePrefix, ...
           'ErrorPlot.ColorTicks',     conf.(num).ColorTicks, ...
           'ErrorPlot.Error',          conf.(num).Error, ...
           'ErrorPlot.ErrorComponent', conf.(num).ErrorComponent);
  catch
        fprintf('MARC_driver_plot_errors failed because:\n');
        res=lasterror;
        fprintf('%s\n',res.message)
  end

timestamp(1,'scratch_error_plot.m')

print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20161020_QC_Check/20180419_GS_QC/';


print('-dpng','-r200',[print_path conf.(num).FilePrefix '_' datestr(dtime,'yyyy_mm_dd_HHMM') '.png']);

toc
