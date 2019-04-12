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
%conf.HourPlot.axisLims=[-64.6 -63.6 -65.1 -64.64];%% old
conf.HourPlot.axisLims=[-65 -63.7 -65.2 -64.64];
conf.HourPlot.DomainName='PLDP';
%conf.HourPlot.DomainName='MARAShort';
conf.HourPlot.Print=false;

conf.Plot.coastFile='/Volumes/codaradm/data/coast_files/MARA_coast.mat';
conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/Antarctica/20141217_Maps/';


conf.OI.BaseDir='/Volumes/codaradm/data/totals/pldp/25MHz/0.5km/oi/mat/';
%conf.OI.BaseDir='/Volumes/codaradm/data/totals/shorts/maracoos/oi/mat/5MHz';
conf.OI.FilePrefix=['tuv_oi_' conf.HourPlot.DomainName '_'];
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;


%% Declare the time that you want to load
% end_time=floor(now*24+1)/24 +2/(24*60*60);
% start_time=end_time-1;
% dtime=start_time:1/24:end_time;





dtime = datenum(2015,1,21,0,0,0):1/24:datenum(2015,1,21,14,0,0);



%% load the total data depending on the config
s=conf.HourPlot.Type;
[f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);


%% concatenate the total data
[TUVcat,goodCount] = catTotalStructs(f,'TUV');
ii = false(size(TUVcat));

%% calculate the number of valid measurements for each map
good.number=sum(~isnan(TUVcat.U),1);
good.max=max(good.number);
good.percent=good.number./good.max;

hold on

%% Plot the base map for the radial file
% plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.Plot.coastFile,'Mercator','patch',[1 .69412 0.39216],'edgecolor','k')

  m_proj('mercator','longitudes',conf.HourPlot.axisLims(1:2), ...
       'latitudes',conf.HourPlot.axisLims(3:4));

 tanLand = [240,230,140]./255;
 S1 = m_shaperead('/Users/hroarty/data/shape_files/antarctica_shape/cst00_polygon_wgs84');
 
 for k=1:length(S1.ncst), 
  h1=m_line(S1.ncst{k}(:,1),S1.ncst{k}(:,2));
  m_patch(S1.ncst{k}(:,1),S1.ncst{k}(:,2),tanLand)
  %set(h1,'Color','k')
end; 

m_grid;

%% Plot the percent coverage if not using m_map
% percentLimits = [0,100];
% conf.HourPlot.ColorTicks = 0:10:100;
% p = 100 * sum( isfinite(TUVcat.U+TUVcat.V), 2 ) / size(TUVcat.U,2);
% log_ind=p<1;
% p(log_ind)=NaN;
% [h,ts] = colordot( TUVcat.LonLat(:,1),TUVcat.LonLat(:,2),p,percentLimits);
% set(h,'markersize',15);

%% Plot the percent coverage if using m_map
percentLimits = [0,100];
conf.HourPlot.ColorTicks = 0:10:100;
[h,ts]=plotData(TUVcat,'perc','m_line',percentLimits);
set(h,'markersize',15);


%% -------------------------------------------------
%% Plot location of sites
try
%% read in the MARACOOS sites
dir='/Users/hroarty/data/';
file='antarctic_codar_sites.txt';
[C]=read_in_maracoos_sites(dir,file);

%% plot the location of the 13 MHz sites
for ii=5:7
    hdls.RadialSites=plot(C{3}(ii),C{4}(ii),'^k','markersize',8,'linewidth',2);
end

catch
end

%% -------------------------------------------------
%% Plot the political boundaries

%% load the political boundaries file
%boundaries=load('/Users/hroarty/data/political_boundaries/WDB2_global_political_boundaries.dat');

%% plot the location of the sites within the bounding box
%hdls.RadialSites=m_plot(sites{1}(in),sites{2}(in),'^r','markersize',8,'linewidth',2);

%% plot the political boundaries
%hdls.boundaries=m_plot(boundaries(:,1),boundaries(:,2),'-k','linewidth',1);

%% -------------------------------------------------
%% plot_bathymetry

bathy=load ('/Users/hroarty/data/bathymetry/antarctica/antarctic_bathy_3.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
bathylines1=0:-10:-100;
bathylines2=0:-200:-1400;
bathylines=[ bathylines2];

[cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
clabel(cs,h1,'fontsize',8);
set(h1,'LineColor','k')

% [cs2, h2] = m_contour(bathy.loni,bathy.lati, bathy.depthi,[-6 -6]);
% set(h2,'LineColor','r')



%-------------------------------------------------
% Plot the colorbar
try
  conf.HourPlot.ColorTicks;
catch
  ss = max( cart2magn( data.TUV.U(:,I), data.TUV.V(:,I) ) );
  conf.HourPlot.ColorTicks = 0:10:ss+10;
end
caxis( [ min(conf.HourPlot.ColorTicks), max(conf.HourPlot.ColorTicks) ] );
%colormap( feval( p.HourPlot.ColorMap, numel(p.HourPlot.ColorTicks)-1 ) );
colormap(conf.HourPlot.ColorMap);
%colormap(winter(10));

% load ('/home/hroarty/Matlab/cm_jet_32.mat')
% colormap(cm_jet_32);

cax = colorbar;
hdls.colorbar = cax;
hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                    'saturated.'], 'fontsize', 8 );
hdls.xlabel = xlabel( cax, '%', 'fontsize', 12 );

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
titleStr = {sprintf('%s %s Coverage, %d possible hourly maps', ...
                    conf.HourPlot.DomainName,conf.HourPlot.Type,length(TUVcat.TimeStamp)),...
            sprintf('From %s to %s',datestr(dtime(1),'yyyy-mm-dd HH:MM'),datestr(dtime(end),'yyyy-mm-dd HH:MM'))};
hdls.title = title(titleStr, 'fontsize', 20 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add path of script to image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/mean_coverage_plot_PLDP.m')

%-------------------------------------------------
% Print if desired
%-------------------------------------------------

sd_str=datestr(dtime(1),'yyyymmdd');
ed_str=datestr(dtime(end),'yyyymmdd');
print(1,'-dpng','-r200',[conf.Plot.PrintPath conf.HourPlot.DomainName '_total_coverage_' sd_str '_' ed_str '.png'])


%% plot the time series of data coverage
figure(2)
plot(TUVcat.TimeStamp,good.percent)
%[AX,H1,H2] = plotyy(TUVcat.TimeStamp,good.percent,TUVcat.TimeStamp,good.number,'plot');
format_axis(gca,TUVcat.TimeStamp(1),TUVcat.TimeStamp(end),4/24,1/24,...
    'HH:MM',0,1,0.1)
xlabel('Date')
ylabel('Percent of Valid Measurements (Relative to Max for Time Period)')

titleStr2 = sprintf('PLDP Coverage Max: %d Grid Points', round(good.max));
hdls.title = title(titleStr2, 'fontsize', 20 );


% ylim([0 1])
% set(get(H2),'Ylim',[0 6000])
% box on
% grid on
% datetick('x','mm/dd/yy')
timestamp(2,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/mean_coverage_plot_05.m')
print(2,'-dpng','-r200',[conf.Plot.PrintPath conf.HourPlot.DomainName '_total_coverage_ts2_' sd_str '_' ed_str '.png'])

close all
clear dtime TUVcat good


toc
