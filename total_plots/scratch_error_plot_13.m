tic


close all
clear all


% Add HFR_Progs to the path
addpath /Users/hroarty/Documents/MATLAB/HFR_Progs-2_1_3beta/matlab/general
add_subdirectories_to_path('/Users/hroarty/Documents/MATLAB/HFR_Progs-2_1_3beta/matlab/',{'CVS','private','@'});



%% OI Total Configuration
conf.Totals.DomainName = 'BPU';
%conf.Totals.DomainName = 'MARA';
%conf.OI.BaseDir = '/Users/hroarty/data/totals/';
% conf.OI.BaseDir = '/Users/hroarty/data/totals/BPU_Network/';
conf.OI.BaseDir = '/Volumes/codaradm/data/totals/maracoos/oi/mat/13MHz/';
%conf.OI.AsciiDir = '/home/codaradm/data/totals/oi/ascii/';
conf.OI.FilePrefix = strcat('tuv_oi_',conf.Totals.DomainName,'_');
%conf.OI.FilePrefix = strcat('Mean_');
conf.OI.FileSuffix = '.mat';
conf.OI.MonthFlag = true;
conf.MonthFlag = false;

%% Plot Setup

%addpath /Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/
%conf.Plot.coastFile = '/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.Plot.coastFile = '/Users/hroarty/data/coast_files/BPU3_coast.mat';
conf.Plot.Projection = 'Mercator';
conf.Plot.plotBasemap_xargs = {'patch',[.5 .9 .5],'edgecolor','k'};
conf.Plot.m_grid_xargs = {'linewidth',2,'linestyle','--','tickdir','out','fontsize',12,'box','on'};
conf.Plot.Speckle = false;

%% Hourly Plots Setup
% conf.HourPlot.BaseDir = '/Users/hroarty/COOL/01_CODAR/OPT/ONT_paper/totals_no_bistatic/';
conf.HourPlot.BaseDir = '/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20171215_MTS_Kobe/';
conf.HourPlot.Type='OI';
conf.HourPlot.FilePrefix = [ conf.Totals.DomainName '_oi1h_' ];
conf.HourPlot.axisLims= [-74-15/60 -73-15/60 39+30/60 40+15/60];% NJ shelf
conf.HourPlot.VectorScale = .02;
conf.HourPlot.plotData_xargs={2};%% use this for plot_vel
conf.HourPlot.plotData_xargs={'Length',5,'Width',5};%,'Page'};
conf.HourPlot.VelocityScaleLocation = [-72.5 41];
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
conf.ErrorPlot.ColorTicks = [0:1:2];
conf.ErrorPlot.Error = 'FitDif';
conf.ErrorPlot.ErrorComponent = 'TotalErrors';
conf.ErrorPlot.axisLims = [-74-15/60 -73-15/60 39+30/60 40+15/60]; %MARC Region
conf.ErrorPlot.DistanceBarLength = 50;
conf.ErrorPlot.DistanceBarLocation = [-74.5 40.25];
conf.ErrorPlot.MarkerSize = 20;
conf.ErrorPlot.ColorMap='jet';% red blue colormap
conf.ErrorPlot.Print = false;

num=8;

switch num
    
    case 2
        conf.ErrorPlot.FilePrefix = [ conf.Totals.DomainName '_gdop_' ];
        conf.ErrorPlot.TitlePrefix = [ 'GDOP: ' ];
        conf.ErrorPlot.ColorTicks = [0:0.25:3];
        conf.ErrorPlot.Error = 'GDOP';
        conf.ErrorPlot.ErrorComponent = 'TotalErrors';

    case 3
        conf.ErrorPlot.FilePrefix = [ conf.Totals.DomainName '_gdopU_' ];
        conf.ErrorPlot.TitlePrefix = [ 'GDOP Uerr: ' ];
        conf.ErrorPlot.ColorTicks = [0:0.25:3];
        conf.ErrorPlot.Error = 'GDOP';
        conf.ErrorPlot.ErrorComponent = 'Uerr';

    case 4
        conf.ErrorPlot.FilePrefix = [ conf.Totals.DomainName '_gdopV_' ];
        conf.ErrorPlot.TitlePrefix = [ 'GDOP Verr: ' ];
        conf.ErrorPlot.ColorTicks = [0:0.25:3];
        conf.ErrorPlot.Error = 'GDOP';
        conf.ErrorPlot.ErrorComponent = 'Verr';

    case 5
        
        conf.ErrorPlot.FilePrefix = [ conf.Totals.DomainName '_oiun_' ];
        conf.ErrorPlot.TitlePrefix = [ 'OI Uncertainty: ' ];
        conf.ErrorPlot.ColorTicks = [0:0.1:1.4];
        conf.ErrorPlot.Error = 'OIuncert';
        conf.ErrorPlot.ErrorComponent = 'TotalErrors';

    case 6
        conf.ErrorPlot.FilePrefix = [ conf.Totals.DomainName '_oiunU_' ];
        conf.ErrorPlot.TitlePrefix = [ 'OI Uncertainty U: ' ];
        conf.ErrorPlot.ColorTicks = [0:0.1:1];
        conf.ErrorPlot.Error = 'OIuncert';
        conf.ErrorPlot.ErrorComponent = 'Uerr';

    case 7
        conf.ErrorPlot.FilePrefix = [ conf.Totals.DomainName '_oiunV_' ];
        conf.ErrorPlot.TitlePrefix = [ 'OI Uncertainty V: ' ];
        conf.ErrorPlot.ColorTicks = [0:0.1:1];
        conf.ErrorPlot.Error = 'OIuncert';
        conf.ErrorPlot.ErrorComponent = 'Verr';
        
    case 8

        conf.ErrorPlot.FilePrefix = [ conf.Totals.DomainName '_oiunUV_' ];
        conf.ErrorPlot.TitlePrefix = [ 'OI Uncertainty UV: ' ];
        conf.ErrorPlot.ColorTicks = [-.5:0.1:.5];
        conf.ErrorPlot.Error = 'OIuncert';
        conf.ErrorPlot.ErrorComponent = 'UVCovariance';

end

dtime=datenum(2016,5,23,15,0,2):1/24:datenum(2016,5,23,18,0,2);



%print_path='/Users/hroarty/COOL/01_CODAR/BPU/20120628_RAWO_effect/Uncertainty_Radials/';
print_path= conf.HourPlot.BaseDir;

for ii=1:length(dtime)
%% Plot OIuncert
  try
   fprintf('Starting MARC_driver_plot_errors OIuncert \n');

   MARC_driver_plot_errors_HJR(dtime(ii),conf,'ErrorPlot.Print',true, ...
       'ErrorPlot.Type',           'OI');%, ...
%        'ErrorPlot.FilePrefix',     conf.(num).FilePrefix, ...
%        'ErrorPlot.TitlePrefix',    conf.(num).TitlePrefix, ...
%        'ErrorPlot.ColorTicks',     conf.(num).ColorTicks, ...
%        'ErrorPlot.Error',          conf.(num).Error, ...
%        'ErrorPlot.ErrorComponent', conf.(num).ErrorComponent);
  catch
    fprintf('MARC_driver_plot_errors failed because:\n');
    res=lasterror;
    fprintf('%s\n',res.message)
  end

timestamp(1,'scratch_error_plot_13.m')

print('-dpng','-r200',[conf.HourPlot.BaseDir conf.ErrorPlot.FilePrefix '_' datestr(dtime(ii),'yyyy_mm_dd_HHMM') '.png']);

close all
end
toc
