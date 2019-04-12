
conf.HourPlot.Type='OI';
p.HourPlot.Type=conf.HourPlot.Type;
conf.HourPlot.VectorScale=0.004;
p.HourPlot.ColorMap='jet';
p.HourPlot.ColorTicks=0:10:100;
p.HourPlot.axisLims=[-75-20/60 -72-30/60 38.5 41];
p.HourPlot.DomainName='13 MHz';
p.HourPlot.Print=false;
p.HourPlot.CoastFile='/Users/hroarty/data/coast_files/MARA_coast.mat';


conf.UWLS.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS/20120208_Zelenke_Request/totals/lsq/';
conf.UWLS.FilePrefix='tuv_BPU_';
conf.UWLS.FileSuffix='.mat';
conf.UWLS.MonthFlag=false;

%conf.OI.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS/20120208_Zelenke_Request/totals/oi/';
conf.OI.BaseDir='/Volumes/codaradm/data/totals/maracoos/oi/mat/13MHz';
%conf.OI.BaseDir='/Volumes/hroarty/codar/MARCOOS/data/totals13_no_bistatic/oi/';
conf.OI.FilePrefix='tuv_oi_BPU_';
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;


%% Declare the time that you want to load
dtime = datenum(2013,07,24,0,0,2):1/24:datenum(2013,07,26,23,0,0);

%% load the total data depending on the config
s=conf.HourPlot.Type;
[f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);


%% concatenate the total data
[TUVcat,goodCount] = catTotalStructs(f,'TUVorig');

ii = false(size(TUVcat));

%% Plot the base map for the radial file
plotBasemap( p.HourPlot.axisLims(1:2),p.HourPlot.axisLims(3:4),p.HourPlot.CoastFile,'Mercator','patch',[.5 .9 .5],'edgecolor','k')

hold on

%% Plot the percent coverage
percentLimits = [0,100];
p.HourPlot.ColorTicks = 0:10:100;
[h,ts]=plotData(TUVcat,'perc','m_line',percentLimits);
set(h,'markersize',15);


%%-------------------------------------------------
%% Plot location of sites
try
%% read in the MARACOOS sites
dir='/Users/hroarty/data/';
file='maracoos_codar_sites.txt';
[C]=read_in_maracoos_sites(dir,file);

%% plot the location of the 13 MHz sites

site_numbers=[17 19 20 21 22];

for ii=site_numbers
    hdls.RadialSites=m_plot(C{3}(ii),C{4}(ii),'^k','markersize',8,'linewidth',2);
end

catch
end

%-------------------------------------------------
% Plot the colorbar
try
  p.HourPlot.ColorTicks;
catch
  ss = max( cart2magn( data.TUV.U(:,I), data.TUV.V(:,I) ) );
  p.HourPlot.ColorTicks = 0:10:ss+10;
end
caxis( [ min(p.HourPlot.ColorTicks), max(p.HourPlot.ColorTicks) ] );
%colormap( feval( p.HourPlot.ColorMap, numel(p.HourPlot.ColorTicks)-1 ) );
colormap(p.HourPlot.ColorMap);
%colormap(winter(10));

% load ('/home/hroarty/Matlab/cm_jet_32.mat')
% colormap(cm_jet_32);

cax = colorbar;
hdls.colorbar = cax;
hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                    'saturated.'], 'fontsize', 8 );
hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 12 );

set(cax,'ytick',p.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')

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
                    p.HourPlot.DomainName,conf.HourPlot.Type,length(TUVcat.TimeStamp)),
            sprintf('From %s to %s',datestr(dtime(1),'dd-mmm-yyyy HH:MM'),datestr(dtime(end),'dd-mmm-yyyy HH:MM'))};
hdls.title = title(titleStr, 'fontsize', 20 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add path of script to image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/mean_coverage_plot.m')

sd_str=datestr(min(dtime),'yyyymmdd');
ed_str=datestr(max(dtime),'yyyymmdd');

print(1,'-dpng','-r400',['Total_Coverage_' p.HourPlot.DomainName '_' sd_str '_' ed_str '.png'])







