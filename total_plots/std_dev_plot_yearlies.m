tic

clear all; close all; 

%% This m script was written to read in the yearly netcdf files that Mike 
%% Smith created at
%% /home/michaesm/codar/codar_means/yearly_means

%conf.regions={'region01';'region02';'region03';'region04';'region05'};
conf.regions={'regionALL'};
% conf.regions={'region03'};


%% load the political boundaries file
boundaries=load('/Users/hroarty/data/political_boundaries/WDB2_global_political_boundaries.dat');


%years.num=2007:2016;
years.num=2007;

years.seasons={'Autumn', 'Spring' ,'Summer' ,'Winter'};

% for ii=1:length(years.seasons) %% use for seasonal means
    for ii=1:length(years.num) %% use for the 7 year mean
    
%% -----------------------------------------------------------
%% use for the annual means
% input_file = ['/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/RU_5MHz_'...
%     num2str(years.num(ii)) 'yearcomposite_' num2str(years.num(ii)) '_01_01_0000.nc']; 

%% use for the 7 year mean
% input_file = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/RU_5MHz_7yearcomposite_2007_01_01_0000.nc'; 

%% use for the seasonal means
% input_file = ['/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/RU_5MHz_7yearMean_' years.seasons{ii} '_2007.nc']

% use this for the seasonal means, 10 year
input_file =['/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/20170424_Decadal_Means/renamed/RU_5MHz_MARA_' years.seasons{ii} '_mean.nc'];

% use this for the annual means, 10 year
% input_file =['/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/20170424_Decadal_Means/renamed/RU_5MHz_MARA_decadal_mean.nc']




%% get the time from the file
 dtime = ncread(input_file,'time');
 
 %% get the time units from the nc variable
time.units=nc_attget(input_file,'time','units');
time.str=time.units(end-18:end);
time.matlab=datenum(time.str);

TUV.TimeStamp=time.matlab+dtime;
TUV.TimeZone='UTC';

%% extract the lat and lon from the nc file
TUV.lat = ncread(input_file,'lat');
TUV.lon = ncread(input_file,'lon');

[TUV.LON,TUV.LAT]=meshgrid(TUV.lon,TUV.lat);

TUV.LON=TUV.LON';
TUV.LAT=TUV.LAT';

TUV.u = ncread(input_file,'u');
TUV.v = ncread(input_file,'v');

%% read in the other data from the nc file
TUV.u_std = ncread(input_file,'u_std');
TUV.v_std = ncread(input_file,'v_std');
TUV.uv_std=ncread(input_file,'uv_std');

%% read the coverage at each grid point
TUV.cov = ncread(input_file,'perCov');

TUV.numTots= ncread(input_file,'numTots');

TUV.rawmag= ncread(input_file,'rawmag');

TUV.rawstd= ncread(input_file,'rawstd');

%% load the current data
% [TUV]=convert_NC_to_TUVgrid(input_file,false );



%% replace the fill values of -999 with NaN
ind=TUV.cov==-999;
TUV.cov(ind)=NaN;

ind2=TUV.uv_std==-999;
TUV.uv_std(ind2)=NaN;

ind3=TUV.rawstd==-999;
TUV.uv_std(ind3)=NaN;

ind4=TUV.numTots==-999;
TUV.uv_std(ind4)=NaN;

% calculate the standard error
% TUV.std_error=TUV.rawstd./sqrt(TUV.numTots);
TUV.std_error=TUV.uv_std./sqrt(TUV.numTots);


%% land mask the data
conf.Totals.Mask='/Users/hroarty/data/mask_files/MARACOOS_6kmMask.txt';
%[TUV,I]=maskTotals(TUV,conf.Totals.Mask,false); % false removes vectors on land

%[TUV,I]=maskTotals(TUV,mask2,true); % true keeps vectors in box

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
% conf.HourPlot.ColorTicks=10:10:60; % velocity or standard deviation
conf.HourPlot.ColorTicks=0:0.2:1;
%conf.HourPlot.ColorMap=colormap(feval(@jet,numel(conf.HourPlot.ColorTicks)-1));
conf.HourPlot.ColorMap=colormap(jet);
conf.HourPlot.grid=5;
conf.HourPlot.Coast='/Users/hroarty/data/coast_files/MARA_Coast.mat';

conf.HourPlot.DomainName='MARA';
conf.HourPlot.Type='OI';
conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20170426_Decadal_Figures/20170518_Std_Dev_uv_std/';
conf.HourPlot.script='std_dev_plot_yearlies.m';
conf.HourPlot.plotType='uv_std_error';
% conf.HourPlot.plotType='TUV_std_error_';

% conf.HourPlot.TitleString={['Surface Current Standard Deviation ' conf.HourPlot.plotType];' 2007 to 2016 (6km Grid)'};
% conf.HourPlot.TitleString={[years.seasons{ii} ' Surface Currents Standard Deviation'];'2007 to 2016 (6km Grid)'};
conf.HourPlot.TitleString={'Surface Currents Standard Error UV STD';'2007 to 2016 (6km Grid)'};

%  curly_vector_plot_for_NC_fn(TUV,conf);

std_dev_plot_for_NC_fn(TUV,conf);





close all;
% clear input_file

end

end


%clear all;

toc
