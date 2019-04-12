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
conf.HourPlot.axisLims=[-75 -73 38.5 40.75];
conf.HourPlot.DomainName='BPU';
%conf.HourPlot.DomainName='MARAShort';
conf.HourPlot.Print=false;

conf.Plot.coastFile='/Volumes/codaradm/data/coast_files/MARA_coast.mat';
% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20151202_YR5.0_Progress/nj13_coverage/';
conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160309_Greg_LCS/';
%conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/Erick_Fredj/20140219_Aviso_HFR_Comparison/';
%conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20130917_Drifters_Manning/20131008_Total_Analysis/';

%% loading configuration parameters
conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/13MHz/';
%conf.OI.BaseDir='/Volumes/codaradm/data/totals/shorts/maracoos/oi/mat/5MHz';
conf.OI.FilePrefix=['tuv_oi_' conf.HourPlot.DomainName '_'];
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;

dtime=datenum(2016,4,23,00,0,0):1/24:datenum(2016,4,24,0,0,0);
time_average=12;%% hours of half the time averaging interval
time_average_matlab=time_average/24;
time_average_str=num2str(2*time_average);

%% saving configuration parameters
conf.Totals.BaseDir=['/Users/hroarty/COOL/01_CODAR/Erick_Fredj/20160630_Eddy_Animation/' time_average_str '_hr_mean/'];
conf.Totals.FilePrefix=['tuv_oi_' time_average_str 'hr_mean_'];
conf.Totals.FileSuffix='.mat';
conf.MonthFlag=true;


%% Declare the time that you want to load
% end_time=floor(now*24+1)/24 +2/(24*60*60);
% start_time=end_time-1;
% dtime=start_time:1/24:end_time;



for ii=1:length(dtime)
    
 dtime2=dtime(ii)-time_average_matlab:1/24:dtime(ii)+time_average_matlab;

%% load the total data depending on the config
s=conf.HourPlot.Type;
[f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime2,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);

%% concatenate the total data
[TUVcat,goodCount] = catTotalStructs(f,'TUV',false,false,false);


TUV=nanmeanTotals( TUVcat, 2 );
    
% Save results
[tdn,tfn] = datenum_to_directory_filename( conf.Totals.BaseDir, TUV.TimeStamp, ...
                                           conf.Totals.FilePrefix, ...
                                           conf.Totals.FileSuffix, conf.MonthFlag );
tdn = tdn{1};

if ~exist( tdn, 'dir' )
  mkdir(tdn);
end
save(fullfile(tdn,tfn{1}),'TUV' )

end


toc
