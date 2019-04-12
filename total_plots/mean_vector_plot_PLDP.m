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
conf.HourPlot.ColorMap='parula-mod';
conf.HourPlot.ColorTicks=0:5:30;
%conf.HourPlot.axisLims=[-64.7 -63.7 -65.1 -64.64];%lon lat
conf.HourPlot.axisLims=[-65 -63.7 -65.2 -64.64];%lon lat
grid_spacing=2;
% conf.HourPlot.axisLims=[-64-24/60 -63-54/60 -64-57/60 -64-45/60];% zoom version
% grid_spacing=1;
conf.HourPlot.axisMask=horzcat(conf.HourPlot.axisLims([1 2 2 1 1])',conf.HourPlot.axisLims([3 3 4 4 3])');

conf.HourPlot.DomainName='PLDP';
%conf.HourPlot.DomainName='MARAShort';
conf.HourPlot.Print=false;

conf.Plot.coastFile='/Users/hroarty/data/coast_files/Antarctica4.mat';
conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/Antarctica/20141217_Maps/';

conf.Totals.Mask='/Users/hroarty/data/mask_files/Antarctica_Coast_Mask.txt';

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

%% Plot the base map for the total file
 %plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.Plot.coastFile,'Mercator','patch',[240,230,140]./255,'edgecolor','k')

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
 

%% Plot the percent coverage
percentLimits = [0,100];
conf.HourPlot.ColorTicks = 0:5:30;

%% calculate the percent coverage at aech grid point
coverage = 100 * sum( isfinite(TUVcat.U+TUVcat.V), 2 ) / size(TUVcat.U,2);

%% find the grid points less that 50% coverage
pct_cov=50;
ind=find(coverage<pct_cov);

%% set the velocity in the grid points below 50% coverage to Nans
TUVcat.U(ind,:)=NaN;
TUVcat.V(ind,:)=NaN;


ii = false(size(TUVcat));

%% Subsample the data
% Find the unique values for the lat and lon grid
unique_x=unique(TUVcat.LonLat(:,1));
unique_y=unique(TUVcat.LonLat(:,2));

% The indices for the rows and columns to keep
% x_ind=[1;10;19;27;36;44;53;61;70;78;87;96;105;113;122;130;138];
% y_ind=[1;10;20;29;38;47;57;66;76;85;94;103;113;121;130];



x_ind=1:grid_spacing:length(unique_x);
y_ind=1:grid_spacing:length(unique_y);

[NX,NY]=meshgrid(unique_x(x_ind),unique_y(y_ind));

% Vectorize the array
NX=NX(:);
NY=NY(:);

% define the varaible before you write to it
marcoos_grid_ind=[];

% find the indices of the grid points you want to keep
for i=1:length(NX)
    ind=find(NX(i)==TUVcat.LonLat(:,1) &NY(i)==TUVcat.LonLat(:,2));
    if ~isempty(ind)
        marcoos_grid_ind(i)=ind;
    end
end

% remove the zeros from the indices array
marcoos_grid_ind(marcoos_grid_ind==0)=[];

% % create a row vector of the Index of spatial grid points to be kept
% SpatialI=1:1:length(data.TUV.U);
% SpatialI=30:1:50;
% 
% % transpose the row vector into a column vector
% SpatialI=SpatialI';

%% Use the subsrefTUV function to only plot certain grid points
TUVsub=subsrefTUV(TUVcat,marcoos_grid_ind);

p.meanTUV.Thresh=20;
p.HourPlot.VectorScale=0.004;
p.HourPlot.plotData_xargs= {};

numTimes = length(f);


% Now mean
fprintf('Temporal Averaging: %d of %d hours present\n',goodCount,numTimes);
if goodCount/numTimes < 0.5
    fprintf('No mean current calculation for %s\n',datestr(times(end)));
    return
end

TUVavg = nanmeanTotals(TUVsub);
TUV = TUVavg;
TUV.OtherMetadata.nanmeanTotals.Total_avgHrs = numTimes;
TUV.OtherMetadata.nanmeanTotals.Actual_avgHrs = goodCount;

%% Mask the data based on the land mask for Antarctica
%% mask any totals outside axes limits
[TUV,I]=maskTotals(TUV,conf.Totals.Mask,false); % true keeps vectors in box

%% Mask the data outside the plotting axis limits
[TUV,I]=maskTotals(TUV,conf.HourPlot.axisMask,true); % true keeps vectors in box

%% Plot the average vector map
hdls = [];
%[hdls.plotData,I] = plotData( TUV, 'm_vec', median(dtime), p.HourPlot.VectorScale);%, ...
                             % p.HourPlot.plotData_xargs{:} );
                             
[hdls.plotData,I] = plotData2( TUV, 'm_vec_same', TUV.TimeStamp, p.HourPlot.VectorScale, ...
p.HourPlot.plotData_xargs{:} );


%% -------------------------------------------------
%% Plot location of sites
try
%% read in the MARACOOS sites
dir='/Users/hroarty/data/';
file='antarctic_codar_sites.txt';
[C]=read_in_maracoos_sites(dir,file);

%% plot the location of the 13 MHz sites
for ii=5:7
    hdls.RadialSites=m_plot(C{3}(ii),C{4}(ii),'^k','markersize',8,'linewidth',2);
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

bathy=load ('/Users/hroarty/data/bathymetry/antarctica/antarctic_bathy_2.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
bathylines1=0:-10:-100;
bathylines2=0:-200:-1400;
bathylines=[ bathylines2];

[cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
clabel(cs,h1,'fontsize',8);
set(h1,'LineColor','k')

%% Plot the 6 m bathymetry contour
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
%colormap( feval( conf.HourPlot.ColorMap, numel(conf.HourPlot.ColorTicks)-1 ) );
M=load('/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/curly_vectors/parula-mod.mat');

colormap(M.cmap);
%colormap(winter(10));

% load ('/home/hroarty/Matlab/cm_jet_32.mat')
% colormap(cm_jet_32);

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
titleStr = {sprintf('%s %s Average Current, %d possible hourly maps', ...
                    conf.HourPlot.DomainName,conf.HourPlot.Type,length(TUVcat.TimeStamp)),...
            sprintf('From %s to %s',datestr(dtime(1),'yyyy-mm-dd HH:MM'),datestr(dtime(end),'yyyy-mm-dd HH:MM'))};
hdls.title = title(titleStr, 'fontsize', 20 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add path of script to image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/mean_vector_plot_PLDP.m')

%-------------------------------------------------
% Print if desired
%-------------------------------------------------

sd_str=datestr(dtime(1),'yyyymmdd');
ed_str=datestr(dtime(end),'yyyymmdd');
print(1,'-dpng','-r200',[conf.Plot.PrintPath conf.HourPlot.DomainName '_total_average_' sd_str '_' ed_str '.png'])


%


toc
