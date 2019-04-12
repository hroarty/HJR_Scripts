close all
clear all

% Add HFR_Progs to the path
addpath /Users/hroarty/Documents/MATLAB/HFR_Progs-2_1_3beta/matlab/general
add_subdirectories_to_path('/Users/hroarty/Documents/MATLAB/HFR_Progs-2_1_3beta/matlab/',{'CVS','private','@'});



% %% OI Total Configuration
% %% 5 MHz configuration
% conf.Totals.DomainName = 'MARA';
% conf.OI.BaseDir = '/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/';
% conf.Totals.Mask='/Volumes/codaradm/data/mask_files/MARACOOS_6kmMask.txt';
% conf.Totals.Mask2='/Users/hroarty/data/mask_files/MARACOOS_6km_rough_Mask2.txt';
% 
% %% 13 MHz configuration
% conf.Totals.DomainName = 'BPU';
% conf.OI.BaseDir = '/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/';
% conf.Totals.Mask='/Volumes/codaradm/data/mask_files/MARACOOS_6kmMask.txt';

%% 25 MHz configuration
conf.Totals.DomainName = 'MARASR';
conf.OI.BaseDir = '/Volumes/codaradm/data/totals/maracoos/oi/mat/25MHz/';
conf.HourPlot.axisLims = [-74-11/60 -73-55/60 40+25/60 40+36/60]; %MARC Region
conf.Totals.Mask='/Users/hroarty/data/mask_files/25MHz_Mask.txt';
conf.Totals.Mask2=[conf.HourPlot.axisLims([1 2 2 1 1]);conf.HourPlot.axisLims([3 3 4 4 3])]';



conf.Totals.MaxTotSpeed=150;
conf.OI.cleanTotalsVarargin={{'OIuncert','Uerr',0.6},{'OIuncert','Verr',0.6}};

%conf.OI.BaseDir = '/Users/hroarty/data/totals/';
%conf.OI.BaseDir = '/Users/hroarty/COOL/01_CODAR/Ocean_Sciences_2012/Means/';
%conf.OI.BaseDir='/Volumes/ironman/data/totals/maracoos/oi/mat/13MHz/';


conf.OI.FilePrefix = strcat('tuv_oi_',conf.Totals.DomainName,'_');
%conf.OI.FilePrefix = strcat('Mean_');
conf.OI.FileSuffix = '.mat';
conf.OI.MonthFlag = true;

%% Plot Setup
conf.Plot.coastFile = '/Users/hroarty/data/coast_files/MARA_coast.mat';
%conf.Plot.coastFile= '/Users/hroarty/data/coast_files/13MHz_NJ.mat';
conf.Plot.Projection = 'Mercator';
conf.Plot.plotBasemap_xargs = {'patch',[240,230,140]./255,'edgecolor','k'};
conf.Plot.m_grid_xargs = {'linewidth',2,'linestyle','--','tickdir','out','fontsize',12,'box','on'};
conf.Plot.Speckle = false;

%% Hourly Plots Setup
conf.HourPlot.BaseDir = '/Users/hroarty/COOL/01_CODAR/Ocean_Sciences_2012/20120206_Plotting_Totals';
conf.HourPlot.Type='OI';
conf.HourPlot.FilePrefix = [ conf.Totals.DomainName '_oi1h_' ];

conf.HourPlot.VectorScale = .02;
%conf.HourPlot.plotData_xargs={2};%% use this for plot_vel
%conf.HourPlot.plotData_xargs={'Length',5,'Width',5};%,'Page'};
%conf.HourPlot.VelocityScaleLocation = [-72.5 42];
conf.HourPlot.DistanceBarLength = 5;
conf.HourPlot.DistanceBarLocation = [conf.HourPlot.axisLims(1)*.999 conf.HourPlot.axisLims(4)*.999];
conf.HourPlot.ColorTicks = [0:10:50];
conf.HourPlot.ColorMapBins=64;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.Print=1;
conf.MonthFlag=0;
conf.grid_spacing=1;

%dtime=datenum(2012,10,29,0,0,2):1/24:datenum(2012,10,29,2,0,2);
dtime=datenum(2015,6,17,11,0,2):1/24:datenum(2015,6,18,00,0,2);
%dtime=datenum(2015,6,17,20,0,0);

print_path='/Users/hroarty/COOL/STUDENT_ITEMS/Joe_Gradone_2015/20151008_NYH_Total_Plots/';

for ii=1:length(dtime)

    MARC_driver_plot_totals_orig_HJR(dtime(ii),conf);

    print('-dpng','-r400',[print_path conf.Totals.DomainName '_' datestr(dtime(ii),'yyyy_mm_dd_HHMM') '.png']);
    
    close all

end



%timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/scratch_totalplot.m')




