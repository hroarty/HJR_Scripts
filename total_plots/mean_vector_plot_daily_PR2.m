%% Configs for the surface current plots

%% determine which computer you are running the script on
compType = computer;

if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes';
else
     root = '/home';
end

conf.HourPlot.Type='OI';
conf.HourPlot.Type=conf.HourPlot.Type;
conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.ColorTicks=0:3:30;
conf.HourPlot.axisLims=[-68.5 -66.75 17.25 18.75];
conf.HourPlot.DomainName='CARA';
conf.HourPlot.Print=false;
conf.meanTUV.Thresh=20;
conf.HourPlot.plotData_xargs= {};
conf.HourPlot.CoastFile='/Users/hroarty/data/coast_files/PR_coast2.mat';
conf.HourPlot.print_path='/Users/hroarty/COOL/01_CODAR/DHS/131101_MONA_2013/20140515_Drifter_Plots/';

conf.HourPlot.windscale=0.1*30;

conf.OI.radial_type='measured';

conf.OI.BaseDir=[root '/codaradm/data/totals/caracoos/oi/mat/13MHz/' conf.OI.radial_type '/'];
conf.OI.FilePrefix='tuv_OI_CARA_';
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=1;

%% read in the PR data
[data]=NDBC_monthly_readin_func('/Users/hroarty/data/NDBC/MGZP4/','txt');

%% convert the wind direction FROM to TOWARDS
data.MWID2=angle360(data.MWID,180);

%% convert the magnitude and direction to u and v
[data.WINDu,data.WINDv]=compass2uv(data.MWID2,data.WSPD);






%% Declare the days that you want to load
dtime = datenum(2014,5,1,0,0,2):24/24:datenum(2014,5,14,0,0,0);

for ii=1:numel(dtime)-1
%% declare the time that you want to load for that day
dtime2=dtime(ii):1/24:dtime(ii+1);

%% WIND %%%%%%%%%%%%%%%%%%%

%% find the indices of the wind data that match the surface current time period
ind=find(data.time >= dtime2(1) & data.time <= dtime2(end));

%% calculate the daily mean wind 
wind_mean.u=nanmean(data.WINDu(ind));
wind_mean.v=nanmean(data.WINDv(ind));
wind_mean.mag=sqrt(wind_mean.u.^2+wind_mean.v.^2);
wind_mean.mag_str=num2str(round2(wind_mean.mag,0.1));


%% CURRENTS %%%%%%%%%%%%%%%

%% load the total data depending on the config
s=conf.HourPlot.Type;
[f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime2,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);


%% concatenate the total data
[TUVcat,goodCount] = catTotalStructs(f,'TUV');


%% calculate the percent coverage at aech grid point
coverage = 100 * sum( isfinite(TUVcat.U+TUVcat.V), 2 ) / size(TUVcat.U,2);

%% find the grid points less that 50% coverage
pct_cov=60;
ind=find(coverage<pct_cov);

%% set the velocity in the grid points below 50% coverage to Nans
TUVcat.U(ind,:)=NaN;
TUVcat.V(ind,:)=NaN;

%% calculate the mean only when you have 50% data coverage for the day
TUVmean=nanmeanTotals(TUVcat,2);


%% plot the daily mean
mean_vector_plot_fn_03(TUVmean,wind_mean,conf);
end