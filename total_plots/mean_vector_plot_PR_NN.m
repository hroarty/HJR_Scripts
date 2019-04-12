tic

clear all
close all

%% determine which computer you are running the script on
compType = computer;

if ~isempty(strmatch('MACI64', compType))
     root = '/Volumes';
else
     root = '/home';
end


conf.HourPlot.Type='UWLS';

conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.ColorTicks=0:6:30;
conf.HourPlot.axisLims=[-69 -65 16+00/60 18+40/60];

conf.Totals.grid_lims=[-69 -65 16+00/60 18+40/60];

radial_type='measured';

conf.HourPlot.DomainName='Puerto Rico';
conf.HourPlot.Print=false;
conf.HourPlot.CoastFile='/Users/hroarty/data/coast_files/PR_coast3.mat';


conf.UWLS.BaseDir=[root '/codaradm/data/totals/caracoos/oi/mat/13MHz/measured/'];
conf.UWLS.FilePrefix='tuv_CARA_';
conf.UWLS.FileSuffix='.mat';
conf.UWLS.MonthFlag=true;

conf.OI.BaseDir=[root '/codaradm/data/totals/caracoos/oi/mat/13MHz/' radial_type '/'];
conf.OI.FilePrefix='tuv_OI_CARA_';
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;

% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20151202_YR5.0_Progress/PR_Plots/';
% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/02_Collaborations/Puerto_Rico/20160614_Progress_Report/PR_Plots_South/';
conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/02_Collaborations/Puerto_Rico/20161201_Progress_Report/';

%dtime = datenum(2014,5,1,0,0,2):1/24:datenum(2014,05,2,0,0,0);

% months=[datenum(2015,12,1) datenum(2016 ,1:6 ,1)];
months=datenum(2016,8:9,1);

for ii=1:numel(months)-1

%% Declare the time that you want to load
dtime = months(ii):1/24:months(ii+1);



%% load the total data depending on the config
s=conf.HourPlot.Type;
% [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);
f='http://hfrnet.ucsd.edu/thredds/dodsC/HFR/PRVI/6km/hourly/RTV/HFRADAR,_Puerto_Rico_and_the_US_Virgin_Islands,_6km_Resolution,_Hourly_RTV_best.ncd';

%% concatenate the total data
[TUVcat] = convert_NN_NC_to_TUVstruct(f,dtime,conf);

%% calculate the percent coverage at aech grid point
coverage = 100 * sum( isfinite(TUVcat.U+TUVcat.V), 2 ) / size(TUVcat.U,2);

%% find the grid points less that 50% coverage
pct_cov=50;
ind=find(coverage<pct_cov);

%% set the velocity in the grid points below 50% coverage to Nans
TUVcat.U(ind,:)=NaN;
TUVcat.V(ind,:)=NaN;

%% average the vectors
TUVavg = nanmeanTotals(TUVcat);


ii = false(size(TUVcat));

%% Plot the base map for the radial file
plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.HourPlot.CoastFile,'Mercator','patch',[240,230,140]./255,'edgecolor','k')

hold on

[hdls.plotData,I] = plotData2( TUVavg, 'm_vec_same', TUVavg.TimeStamp, conf.HourPlot.VectorScale);

%% plot_bathymetry
bathy=load ('/Users/hroarty/data/bathymetry/puerto_rico/puerto_rico_6second_grid.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
bathylines=[ -100 -500 -1000 -2000];

[cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
clabel(cs,h1,'fontsize',8);
set(h1,'LineColor','k')


% %%-------------------------------------------------
% %% Plot location of sites
% try
% %% read in the MARACOOS sites
% dir='/Users/hroarty/data/';
% file='maracoos_codar_sites.txt';
% [C]=read_in_maracoos_sites(dir,file);
% 
% %% plot the location of the radar sites
% 
% for ii=48:49
%     hdls.RadialSites=m_plot(C{3}(ii),C{4}(ii),'^k','markersize',8,'linewidth',2);
% end
% 
% catch
% end

%-------------------------------------------------
% Plot the colorbar
try
  conf.HourPlot.ColorTicks;
catch
  ss = max( cart2magn( data.TUV.U(:,I), data.TUV.V(:,I) ) );
  conf.HourPlot.ColorTicks = 0:10:ss+10;
end
caxis( [ min(conf.HourPlot.ColorTicks), max(conf.HourPlot.ColorTicks) ] );
colormap( feval( conf.HourPlot.ColorMap, numel(conf.HourPlot.ColorTicks)-1 ) );

%colormap(winter(10));

% load ('/home/hroarty/Matlab/cm_jet_32.mat')


cax = colorbar;
hdls.colorbar = cax;
hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                    'saturated.'], 'fontsize', 8 );
hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 12 );

set(cax,'ytick',conf.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')

%-------------------------------------------------
% % Add title string
% try, p.HourPlot.TitleString;
% catch
%   p.HourPlot.TitleString = [p.HourPlot.DomainName,' ',p.HourPlot.Type,': ', ...
%                             datestr(dtime,'yyyy/mm/dd HH:MM'),' ',TUVcat.TimeZone(1:3)];
% end
% hdls.title = title( p.HourPlot.TitleString, 'fontsize', 16,'color',[.2 .3 .9] );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add title string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
titleStr = {sprintf('%s %s Average, %d possible hourly maps', ...
                    conf.HourPlot.DomainName,conf.HourPlot.Type,length(TUVcat.TimeStamp)),
            sprintf('From %s to %s',datestr(dtime(1),'dd-mmm-yyyy HH:MM'),datestr(dtime(end),'dd-mmm-yyyy HH:MM'))};
hdls.title = title(titleStr, 'fontsize', 20 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add path of script to image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/mean_vector_plot_PR_NN.m')

sd_str=datestr(min(dtime),'yyyymmdd');
ed_str=datestr(max(dtime),'yyyymmdd');

print(1,'-dpng','-r400',[conf.Plot.PrintPath 'Total_Average_' conf.HourPlot.Type '_' ...
    conf.HourPlot.DomainName '_' sd_str '_' ed_str '.png'])

close all

end

toc




