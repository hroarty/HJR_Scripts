tic

 clear all; close all; 
 
 if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes';
else
     root = '/home';
end

%% -----------------------------------------------------------
%% Declare the time over which you want to process the data
%% now is local time of the machine
start_time = datenum(2016,11,30,0,0,0);
% end_time=datenum(2016,12,1,0,0,0);
end_time=datenum(2018,5,2,0,0,0);
dtime = start_time:1/24:end_time;

% Add HFR_Progs to the path
addpath [root '/codaradm/HFR_Progs-2_1_3beta/matlab/general/']
add_subdirectories_to_path([root '/codaradm/HFR_Progs-2_1_3beta/matlab/',{'CVS','private','@'}]);


%% config info for the plot
conf.HourPlot.Type='OI';%% this can be OI or UWLS
conf.HourPlot.Type=conf.HourPlot.Type;
conf.HourPlot.VectorScale=0.004;
% conf.HourPlot.ColorMap='jet';
conf.HourPlot.Print=false;
conf.HourPlot.coastlinefile='/Users/hroarty/data/coast_files/MARA_coast.mat';
% conf.HourPlot.coastlinefile='/Users/hroarty/data/coast_files/NC_coast.mat';


% 5 MHz configs
%conf.OI.BaseDir='/Users/hroarty/data/realtime/totals/maracoos/oi/mat/5MHz/';
% conf.OI.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20161007_Matthew_Prep/20171024_Reprocessing/totals/maracoos/oi/mat/5MHz/';
% conf.OI.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180201_2017_Reprocessing/20180301_May_Reprocessing/totals/maracoos/oi/mat/5MHz';
conf.OI.BaseDir=[root '/codaradm/data/totals/maracoos/oi/mat/5MHz/'];
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/ideal/';
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/measured/';
conf.HourPlot.DomainName='MARA';
% conf.HourPlot.axisLims=[-75 -71-00/60 38+00/60 41+00/60];% NJ and Delaware
conf.HourPlot.axisLims=[-74 -73 35.5 36];
% conf.HourPlot.axisLims=[-77 -68-00/60 34+00/60 42+00/60];%% MAB
% conf.HourPlot.axisLims2=[-80 -74 33 38];% VA NC
% conf.HourPlot.axisLims=[-76.5 -73 33.5 37];% VA NC


conf.OI.FilePrefix=['tuv_oi_' conf.HourPlot.DomainName '_'];
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=1;
conf.OI.HourFlag=0;
conf.Totals.MaxTotSpeed=300;
conf.OI.cleanTotalsVarargin={{'OIuncert','Uerr',0.6},{'OIuncert','Verr',0.4},{'OIuncert','UVCovariance',0.6}};

conf.HourPlot.DistanceBarLength = 50;
conf.HourPlot.DistanceBarLocation = [conf.HourPlot.axisLims(2)-15/60 conf.HourPlot.axisLims(4)-15/60];
conf.HourPlot.ColorTicks = 0:10:60;
conf.HourPlot.ColorMapBins=64;
% [conf.HourPlot.ColorMap]=colormap6;
conf.HourPlot.ColorMap=jet(64);
% conf.HourPlot.ColorMap=cmocean('speed',length(conf.HourPlot.ColorTicks)-1);
conf.HourPlot.Print=1;
conf.HourPlot.Mask=[conf.HourPlot.axisLims([1 2 2 1 1])',conf.HourPlot.axisLims([3 3 4 4 3])'];
conf.HourPlot.grid_spacing=1;
conf.HourPlot.grid=1;



conf.HourPlot.Type='OI';
s = conf.HourPlot.Type;

%% load the total data depending on the config
s=conf.HourPlot.Type;
% [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag,conf.(s).HourFlag);
[f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);
conf.datatype='TUV';
% conf.datatype='TUVoi';



for ii = 1:length(dtime) 
    
    disp( [ 'Processing filename: ' f{ii} ] );
    try 
    data=load(f{ii});

    % clean the total vectors 
    TUV=cleanTotals(data.(conf.datatype),conf.Totals.MaxTotSpeed,conf.OI.cleanTotalsVarargin{:});
    
    Total_Vectors(ii)=sum(~isnan(TUV.U));
    
    clear TUV
    
    catch ME
        disp(ME.message)
        Total_Vectors(ii)=NaN;
    end
    
end

save('Vector_Count_6km_2016_2018.mat','dtime','Total_Vectors')
    



toc
