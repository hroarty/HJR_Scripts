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
conf.HourPlot.ColorTicks=0:10:100;
% conf.HourPlot.axisLims=[-68 -65 16+30/60 18+40/60];% All PR
% conf.Totals.grid_lims=[-68 -65 16+00/60 18+40/60];

conf.HourPlot.axisLims=[-77 -73 33.5 37];% 
conf.Totals.grid_lims=[-77 -73 33.5 37];


radial_type='measured';

conf.HourPlot.DomainName='MARACOOS';
conf.HourPlot.Print=false;
conf.HourPlot.Coast='/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.HourPlot.grid=3;

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
% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/02_Collaborations/Puerto_Rico/20161201_Progress_Report/';
% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/02_Collaborations/Puerto_Rico/20170418_CARICOOS_Meeting/';
conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20161007_Matthew_Prep/20170929_NN_totals/';


%dtime = datenum(2014,5,1,0,0,2):1/24:datenum(2014,05,2,0,0,0);

% months=[datenum(2015,12,1) datenum(2016 ,1:12 ,1)];
% months=[datenum(2016,1:3:10,1) datenum(2017,1,1)];
months=datenum(2016,10,6):1/24:datenum(2016,10,7,9,0,0);

% conf.time.start=datenum(2016,6,1);
% conf.time.end=datenum(2016,7,1);
% conf.time.interval=

for ii=1:numel(months)% monthly means
% for ii=1 % single mean   

%% Declare the time that you want to load
% dtime = months(ii):1/24:months(ii+1);% interval means
% dtime = months(ii):1/24:months(end); % single mean
dtime=months(ii); % single hour


%% load the total data depending on the config
s=conf.HourPlot.Type;
% [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);
% f='http://hfrnet.ucsd.edu/thredds/dodsC/HFR/PRVI/6km/hourly/RTV/HFRADAR,_Puerto_Rico_and_the_US_Virgin_Islands,_6km_Resolution,_Hourly_RTV_best.ncd';
f='http://hfrnet.ucsd.edu/thredds/dodsC/HFR/USEGC/6km/hourly/RTV/HFRADAR,_US_East_and_Gulf_Coast,_6km_Resolution,_Hourly_RTV_best.ncd';
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

% dx=5;
% dy=5;
% flag=NaN;
% [U,notOnGrid_U] = griddata_nointerp(TUVavg.LON,TUVavg.LAT,TUVavg.LonLat(:,1),TUVavg.LonLat(:,2),TUVavg.U,dx,dy,flag);
% [V,notOnGrid_V] = griddata_nointerp(TUVavg.LON,TUVavg.LAT,TUVavg.LonLat(:,1),TUVavg.LonLat(:,2),TUVavg.V,dx,dy,flag);

% U=griddata(TUVavg.LonLat(:,1),TUVavg.LonLat(:,2),TUVavg.U,TUVavg.LON,TUVavg.LAT);
% V=griddata(TUVavg.LonLat(:,1),TUVavg.LonLat(:,2),TUVavg.V,TUVavg.LON,TUVavg.LAT);

% calculate the mean of the grided data set
% U=nanmean(TUVavg.Ug,3);
% V=nanmean(TUVavg.Vg,3);

U=TUVavg.Ug;
V=TUVavg.Vg;

%% set the velocity in the grid points below 50% coverage to Nans
% U(ind)=NaN;
% V(ind)=NaN;

hold on 

%% Plot the base map for the radial file
plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.HourPlot.Coast,'Mercator','patch',[240,230,140]./255,'edgecolor','k')


% coast = load(conf.HourPlot.Coast);
% coast2 = coast.ncst;
% e = plot(coast2(:,1), coast2(:,2), 'k', 'linewidth', 1);
% tanLand = [240,230,140]./255;
% mapshow(coast2(:,1), coast2(:,2), 'DisplayType', 'polygon', 'facecolor', tanLand)


%% Pcolor the magnitude of the vectors
 mag = sqrt(U.^2 + V.^2); % 
 m_pcolor(TUVcat.LON,TUVcat.LAT,mag);
 shading flat
 
 plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.HourPlot.Coast,'Mercator','patch',[240,230,140]./255,'edgecolor','k')

 % plot the vectors
% h=streakarrow(TUVavg.LON(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end),...
%     TUVavg.LAT(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end),...
%     U(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end),...
%     V(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end), 1, 1, 1);

% [hdls.plotData,I] = plotData2( TUVavg, 'm_vec_same', TUVavg.TimeStamp, conf.HourPlot.VectorScale);
[hdls.plotData,I] = plotData2( TUVcat, 'm_vec_same_color', TUVavg.TimeStamp, conf.HourPlot.VectorScale);

%% plot_bathymetry
bathy=load ('/Users/hroarty/data/bathymetry/eastcoast_4min.mat');
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
% this will generate a discretized colormap
% colormap( feval( conf.HourPlot.ColorMap, numel(conf.HourPlot.ColorTicks)-1 ) );
colormap(conf.HourPlot.ColorMap)

%colormap(winter(10));

% load ('/home/hroarty/Matlab/cm_jet_32.mat')


cax = colorbar;
hdls.colorbar = cax;
hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                    'saturated.'], 'fontsize', 8 );
hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 12 );

set(cax,'ytick',conf.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')

%-------------------------------------------------
% Add title string
% try, conf.HourPlot.TitleString;
% catch
%   conf.HourPlot.TitleString = [conf.HourPlot.DomainName,' ',conf.HourPlot.Type,': ', ...
%                             datestr(dtime,'yyyy/mm/dd HH:MM'),' ',TUVcat.TimeZone(1:3)];
% end

conf.HourPlot.TitleString = [conf.HourPlot.DomainName,' ',conf.HourPlot.Type,': ', ...
                            datestr(dtime,'yyyy/mm/dd HH:MM'),' ',TUVcat.TimeZone(1:3)];
hdls.title = title( conf.HourPlot.TitleString, 'fontsize', 16,'color','k' );

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Add title string
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% titleStr = {sprintf('%s %s Average, %d possible hourly maps', ...
%                     conf.HourPlot.DomainName,conf.HourPlot.Type,length(TUVcat.TimeStamp)),
%             sprintf('From %s to %s',datestr(dtime(1),'dd-mmm-yyyy HH:MM'),datestr(dtime(end),'dd-mmm-yyyy HH:MM'))};
% hdls.title = title(titleStr, 'fontsize', 20 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add path of script to image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/mean_vector_plot_MARA_NN_curly.m')

sd_str=datestr(min(dtime),'yyyymmddTHHMM');
ed_str=datestr(max(dtime),'yyyymmddTHHMM');

% print(1,'-dpng','-r200',[conf.Plot.PrintPath 'Total_' conf.HourPlot.Type '_' ...
%     conf.HourPlot.DomainName '_' sd_str '_' ed_str '.png'])

print(1,'-dpng','-r200',[conf.Plot.PrintPath 'Total_' conf.HourPlot.Type '_' ...
    conf.HourPlot.DomainName '_' sd_str  '.png'])

conf.HourPlot.TitleString=[];

close all

end

toc




