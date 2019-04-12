tic

clear all; close all; 

%% This m script was written to read in the yearly netcdf files that Mike 
%% Smith created at
%% /home/michaesm/codar/codar_means/yearly_means

%% -----------------------------------------------------------
%% Declare the time over which you want to process the data
%% now is local time of the machine
    
%% specific period
start_time = datenum(2016,01,23,17,0,2);
end_time=datenum(2016,01,23,17,0,2);
%end_time=datenum(2016,1,25,12,0,2);
dtime = start_time:1/24:end_time;
time_str=datestr(dtime,'yyyy_mm_dd_HHMM');

%% now minus 24 hours
% end_time   = floor(now*24-1)/24 + 2/(24*60*60); %add some slop to handle rounding
% start_time = end_time - 24/24;
% dtime = [start_time:1/24:end_time]; 

%regions={'region01';'region02';'region03';'region04';'region05'};
conf.regions={'Special'};
% conf.regions={'regionALL'};


%% load the political boundaries file
boundaries=load('/Users/hroarty/data/political_boundaries/WDB2_global_political_boundaries.dat');


files=cell(length(dtime),1);


%% -----------------------------------------------------------
%% the location of the total data 
conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/nc/5MHz/';
% conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/5MHz/ideal/';
% conf.OI.BaseDir='/Volumes/michaesm/codar/reprocessed/pre09LR/totals/maracoos/oi/nc/';
conf.OI.FilePrefix='RU_5MHz_';
conf.OI.FileSuffix='.totals.nc';
conf.OI.MonthFlag=true;

%% UVCovariance is not in the nc files so you can only use the two error estimates
%conf.OI.cleanTotalsVarargin={{'OIuncert','Uerr',0.6},{'OIuncert','Verr',0.6},{'OIuncert','UVCovariance',0.6}};
conf.OI.cleanTotalsVarargin={{'OIuncert','Uerr',0.6},{'OIuncert','Verr',0.6}};
conf.Totals.MaxTotSpeed=300;

conf.HourPlot.VectorScale = .02;
%conf.HourPlot.ColorTicks=0:3:15;
conf.HourPlot.ColorTicks=0:20:100;
%conf.HourPlot.ColorMap=colormap(feval(@jet,numel(conf.HourPlot.ColorTicks)-1));
conf.HourPlot.ColorMap=jet;
conf.HourPlot.grid=2;
conf.HourPlot.Coast='/Users/hroarty/data/coast_files/MARA_Coast.mat';

conf.HourPlot.DomainName='MARA';
conf.HourPlot.Type='OI';
conf.HourPlot.TitleFontSize=8;
% conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20160211_Barry/';
% conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20151001_Juaquin_Prep/';
% conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20161007_Matthew_Prep/';
conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180409_MARACOOS_Meeting/AWIPS_Use/';
conf.HourPlot.script='vector_plot_hourly_curly.m';

for ii = 1:length (dtime)
files{ii,1} =[conf.OI.BaseDir conf.OI.FilePrefix time_str(ii,:) conf.OI.FileSuffix]; 
end

for ii=1:length(dtime)
    
    tic
    
%% -----------------------------------------------------------
%% the location of the total data
% input_file = ['/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/RU_5MHz_'...
%     num2str(years.num(ii)) 'yearcomposite_' num2str(years.num(ii)) '_01_01_0000.nc']; 

input_file = files{ii,1}; 

%% get the time from the file
 dtime = ncread(input_file,'time');


%% extract the lat and lon from the nc file
lat = ncread(input_file,'lat');
lon = ncread(input_file,'lon');

% %% read the coverage at each grid point
% coverage = ncread(input_file,'perCov');
% 
% %% replace the fill values of -999 with NaN
% logInd=coverage==-999;
% coverage(logInd)=NaN;
% coverage=coverage';
% 
% % %% read the divergence at each grid point
% % div=ncread(input_file,'div');
% % 
% % %% replace the fill values of -999 with NaN
% % logInd2=div==-999;
% % div(logInd2)=NaN;
% % div=div';
% 
% [lon,lat,u,v,div,vor]=divergence('netcdf','ncfile',input_file,'adddivergence',false,'addvorticity',false,'maxerror',nan); 
% div=div';


%% load the current data
[TUV]=convert_NC_to_TUVgrid(input_file,true );



%% land mask the data
conf.Totals.Mask='/Users/hroarty/data/mask_files/MARACOOS_6kmMask.txt';
%[TUV,I]=maskTotals(TUV,conf.Totals.Mask,false); % false removes vectors on land

%[TUV,I]=maskTotals(TUV,mask2,true); % true keeps vectors in box

%% clean the totals by removing vectors with uncertainty above 0.6
TUV=cleanTotals(TUV,conf.Totals.MaxTotSpeed,conf.OI.cleanTotalsVarargin{:});

for jj=1:length(conf.regions)
    
    conf.region_select=conf.regions{jj};

switch conf.region_select
    case 'regionALL'
    lims=[-77 -68 34 43];%ALL MAB
    case 'region01'
    lims=[-71 -68 40 43];% North
    case 'region02'
    lims=[-72 -69 39 41.5];% RI
    case 'region03'
    lims=[-75 -72 38 41];% NJ
    case 'region04'
    lims=[-76 -72 37 39];% MD
    case 'region05'
    lims=[-76 -73 35 37];% VA NC
    case 'Special'
    lims=[-76 -72 36 39];% VA NC
end
    
conf.HourPlot.axisLims=lims;

mask2=[lims([1 2 2 1 1]);lims([3 3 4 4 3])];
mask2=mask2';

toc
%% Use this function to generate individual arrows
%  mean_vector_plot_fn_02(TUV,conf,dtime);

 %% use this function to plot curly vectors
 curly_vector_plot_for_NC_fn(TUV,conf);

close all;
% clear input_file

end

end


%clear all;

toc
