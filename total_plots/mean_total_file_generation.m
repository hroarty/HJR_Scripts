%% Scratch script to generate radial coverage plots
%% Written by Hugh Roarty on March 26, 2010

tic

close all; clear all;
% addpath /home/codaradm/HFR_Progs-2_1_3beta/matlab/general
% addpath /home/codaradm/operational_scripts/totals
% add_subdirectories_to_path('/home/codaradm/HFR_Progs-2_1_3beta/matlab/',{'CVS','private','@'});
% addpath /home/hroarty/Matlab
% addpath /home/codaradm/cocmp_scripts/helpers

conf.HourPlot.Type='OI';%% this can be OI or UWLS
conf.HourPlot.Type=conf.HourPlot.Type;
conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.ColorTicks=0:10:100;
conf.HourPlot.axisLims=[-77 -68 34 43];
conf.HourPlot.DomainName='MARA';
%conf.HourPlot.DomainName='MARAShort';
conf.HourPlot.Print=false;

conf.Plot.coastFile='/Users/hroarty/data/coast_files/MARA_coast.mat';
%conf.Plot.PrintPath='/Volumes/hroarty/codar/MARACOOS/Coverage_Total/';
%conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/Erick_Fredj/20140219_Aviso_HFR_Comparison/';
%conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20151202_YR5.0_Progress/Long_Range_Coverage/';
%conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160212_Monthly_Figures/';
conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160211_Barry/';

%conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/';
conf.OI.BaseDir='/Volumes/michaesm/codar/reprocessed/pre09LR/totals/maracoos/oi/mat/5MHz/';
conf.OI.FilePrefix=['tuv_oi_' conf.HourPlot.DomainName '_'];
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;

%% metadata for saving file
conf.Plot.script_path='/Users/hroarty/Documents/MATLAB/HJR_Scripts/Wind_Plots/';
conf.Plot.script_name='plot_NDBC_climatology_seasonal.m';
conf.Data.Institution='Rutgers University';
conf.Data.Contact='Hugh Roarty hroarty@marine.rutgers.edu';
conf.Data.Info='This data file is monthly mean of data from an NDBC buoy';


%% Declare the time that you want to load
% end_time=floor(now*24+1)/24 +2/(24*60*60);
% start_time=end_time-1;
start_time=datenum(2007,6,3);
end_time=datenum(2007,6,6);
dtime=start_time:1/24:end_time;

months=datenum(2007 ,6 ,1);

for ii=1:numel(months)

    %dtime = months(ii):1/24:months(ii+1);


    %% load the total data depending on the config
    s=conf.HourPlot.Type;
    [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);


    %% concatenate the total data
    

    [TUVcat,goodCount] = catTotalStructs(f,'TUV',false,false,false);
    ii = false(size(TUVcat));

%     %% calculate the number of valid measurements for each map
%     good.number=sum(~isnan(TUVcat.U),1);
%     good.max=max(good.number);
%     good.percent=good.number./good.max;

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
     
     %% add metadata to mat file that will be saved
        var.name=buoyData{ii}.name;
        var.variable=conf.NDBC.standard_name{jj};
        var.season=conf.season.name;
        var.MetaData.Script=conf.Plot.script_name;
        var.MetaData.Institution=conf.Data.Institution;
        var.MetaData.Contact=conf.Data.Contact;
        var.MetaData.Information=conf.Data.Info;
    
   




    
end
