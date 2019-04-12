tic

clear all; close all; 

%% This m script was written to read in the yearly netcdf files that Mike 
%% Smith created at
%% /home/michaesm/codar/codar_means/yearly_means

%% -----------------------------------------------------------
%% Declare the time over which you want to process the data
%% now is local time of the machine
    
%% specific period
start_time = datenum(2016,1,22,12,0,2);
end_time=datenum(2016,1,25,23,0,2);
dtime = start_time:1/24:end_time;
time_str=datestr(dtime,'yyyy_mm_dd_HHMM');

%% now minus 24 hours
% end_time   = floor(now*24-1)/24 + 2/(24*60*60); %add some slop to handle rounding
% start_time = end_time - 24/24;
% dtime = [start_time:1/24:end_time]; 

% conf.regions={'region01';'region02';'region03';'region04';'region05'};
conf.regions={'regionALL'};
% conf.regions={'region03'};


%% load the political boundaries file
boundaries=load('/Users/hroarty/data/political_boundaries/WDB2_global_political_boundaries.dat');


years.num=2007:2016;
years.num=years.num';
years.numS=cellstr(num2str(years.num));% convert to a cell array of strings

years.seasons={'Autumn', 'Spring' ,'Summer' ,'Winter'};

% for ii=1:length(years.seasons) %% use for seasonal means
    for ii=1 %% use for the 10 year mean
    
%% -----------------------------------------------------------
%% the location of the total data
% input_file = ['/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/RU_5MHz_'...
%     num2str(years.num(ii)) 'yearcomposite_' num2str(years.num(ii)) '_01_01_0000.nc']; 

% use this for the 7 year mean
% input_file = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/RU_5MHz_7yearcomposite_2007_01_01_0000.nc'; 

% input_file = '/Volumes/michaesm/codar/codar_means/seasonal_means/autumn/RU_5MHz_2009autumn.nc';

% use this for the seasonal means
% input_file = ['/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/RU_5MHz_7yearMean_' years.seasons{ii} '_2007.nc']

% use this for the seasonal means, 10 year
% input_file =['/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/20170424_Decadal_Means/renamed/RU_5MHz_MARA_' years.seasons{ii} '_mean.nc']

% use this for the annual means, 10 year
input_file =['/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/20170424_Decadal_Means/renamed/RU_5MHz_MARA_decadal_mean.nc']

%% get the time from the file
 dtime = ncread(input_file,'time');


%% extract the lat and lon from the nc file
lat = ncread(input_file,'lat');
lon = ncread(input_file,'lon');

%% read the coverage at each grid point
coverage = ncread(input_file,'perCov');

%% replace the fill values of -999 with NaN
logInd=coverage==-999;
coverage(logInd)=NaN;
coverage=coverage';

% %% read the divergence at each grid point
% div=ncread(input_file,'div');
% 
% %% replace the fill values of -999 with NaN
% logInd2=div==-999;
% div(logInd2)=NaN;
% div=div';

[lon,lat,u,v,div,vor]=divergenceLP('netcdf','ncfile',input_file,'adddivergence',false,'addvorticity',false,'maxerror',nan); 

%% load the current data
[TUV]=convert_NC_to_TUVgrid(input_file,false );
% [TUV]=convert_NC_to_TUVstruct(input_file,false );

TUV.Vorticity=vor';
TUV.Divergence=div';

%calculate the divergence with the MATLAB function
% div2=divergence(TUV.LON,TUV.LAT,TUV.U,TUV.V);
% TUV.Divergence=div2;

%% land mask the data
conf.Totals.Mask='/Users/hroarty/data/mask_files/MARACOOS_6kmMask_v2.txt';
% [TUV,I]=maskTotals(TUV,conf.Totals.Mask,false); % false removes vectors on land
%[TUV,I]=maskTotals(TUV,mask2,true); % true keeps vectors in box

mask=load(conf.Totals.Mask);

 IN = inpolygon(TUV.LON,TUV.LAT,mask(:,1),mask(:,2));
 
 TUV.U(IN)=NaN;
 TUV.V(IN)=NaN;
 


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
end
    


mask2=[lims([1 2 2 1 1]);lims([3 3 4 4 3])];
mask2=mask2';

conf.HourPlot.VectorScale = .02;
conf.HourPlot.axisLims=lims;
% conf.HourPlot.ColorTicks=0:3:15;
% conf.HourPlot.ColorTicks=0:1:10;
conf.HourPlot.ColorTicks=-0.02:0.005:.02;
%conf.HourPlot.ColorMap=colormap(feval(@jet,numel(conf.HourPlot.ColorTicks)-1));
conf.HourPlot.ColorMap=colormap(redblue);
conf.HourPlot.grid=5;
conf.HourPlot.Coast='/Users/hroarty/data/coast_files/MARA_Coast.mat';

conf.HourPlot.DomainName='MARA';
conf.HourPlot.Type='OI';
% conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150505_HJR_Figures_Yearly/Curly/20170222_Fall_2009/';
% conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150505_HJR_Figures_Yearly/Divergence_LP/';
% conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150505_HJR_Figures_Yearly/Vorticity/seasons/';
conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20170426_Decadal_Figures/20170427_01_Vorticity/';
% conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20170426_Decadal_Figures/20170427_02_Divergence/';

conf.HourPlot.script='divergence_plot_yearlies_v2.m';

% conf.HourPlot.TitleString=['Divergence Map ' years.numS{1} ' to ' years.numS{end} ' (6km Grid)'];
conf.HourPlot.TitleString=['Vorticity Map ' years.numS{1} ' to ' years.numS{end} ' (6km Grid)'];
% conf.HourPlot.TitleString=[years.seasons{ii} ' Divergence Map ' years.numS{1} ' to ' years.numS{end} ' (6km Grid)'];
% conf.HourPlot.TitleString=[years.seasons{ii} ' Vorticity Map ' years.numS{1} ' to ' years.numS{end} ' (6km Grid)'];
conf.HourPlot.TitleFontSize=12;

divergence_plot_for_NC_fn(TUV,conf);

close all;
% clear input_file

end

end


%clear all;

toc
