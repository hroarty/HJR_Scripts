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


conf.HourPlot.Type='OI';
p.HourPlot.Type=conf.HourPlot.Type;
p.HourPlot.VectorScale=0.004;
p.HourPlot.ColorMap='jet';
p.HourPlot.ColorTicks=0:3:15;
p.HourPlot.axisLims=[-68.5 -67 17.25 18.75];
p.HourPlot.DomainName='CARA';
p.HourPlot.Print=false;
p.meanTUV.Thresh=20;
p.HourPlot.plotData_xargs= {};
p.HourPlot.CoastFile='/Users/hroarty/data/coast_files/PR_coast.mat';

% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20151202_YR5.0_Progress/PR_Plots/';
% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/02_Collaborations/Puerto_Rico/20160614_Progress_Report/PR_Plots/';
conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/02_Collaborations/Puerto_Rico/20161201_Progress_Report/';

radial_type='measured';

conf.OI.BaseDir=[root '/codaradm/data/totals/caracoos/oi/mat/13MHz/' radial_type '/'];
conf.OI.FilePrefix='tuv_OI_CARA_';
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;

%months=[datenum(2014 ,12 ,1) datenum(2015 ,1:6 ,1)];
months=[datenum(2015,12,1) datenum(2016 ,1:6 ,1)];
months=[datenum(2016,6:12,1)];

for ii=1:numel(months)-1

%% Declare the time that you want to load
dtime = months(ii):1/24:months(ii+1);

%% load the total data depending on the config
s=conf.HourPlot.Type;
[f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);


%% concatenate the total data
[TUVcat,goodCount] = catTotalStructs(f,'TUV',false,false,false);

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

grid_spacing=2;

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

%% Create the filename for the coastline file
%coastline_file='BPU_coast_';


%% Plot the base map for the radial file
plotBasemap( p.HourPlot.axisLims(1:2),p.HourPlot.axisLims(3:4),p.HourPlot.CoastFile,'Mercator','patch',[240,230,140]./255,'edgecolor','k')

hold on

numTimes = length(f);


% Now mean
fprintf('Temporal Averaging: %d of %d hours present\n',goodCount,numTimes);
if goodCount < p.meanTUV.Thresh
    fprintf('No mean current calculation for %s\n',datestr(times(end)));
    return
end

TUVavg = nanmeanTotals(TUVsub);
TUV = TUVavg;
TUV.OtherMetadata.nanmeanTotals.Total_avgHrs = numTimes;
TUV.OtherMetadata.nanmeanTotals.Actual_avgHrs = goodCount;
  
%% Plot the average vectors
hdls = [];
%[hdls.plotData,I] = plotData( TUV, 'm_vec', median(dtime), p.HourPlot.VectorScale);%, ...
                             % p.HourPlot.plotData_xargs{:} );
                             
[hdls.plotData,I] = plotData2( TUV, 'm_vec_same', TUV.TimeStamp, p.HourPlot.VectorScale, ...
p.HourPlot.plotData_xargs{:} );

%% plot_bathymetry
bathy=load ('/Users/hroarty/data/bathymetry/puerto_rico/puerto_rico_6second_grid.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
bathylines=[ -100 -500 -1000 -2000];

[cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
clabel(cs,h1,'fontsize',8);
set(h1,'LineColor','k')


%%-------------------------------------------------
%% Plot location of sites
try
%% read in the MARACOOS sites
dir='/Users/hroarty/data/';
file='maracoos_codar_sites.txt';
[C]=read_in_maracoos_sites(dir,file);

%% plot the location of the 13 MHz sites

for ii=48:49
    hdls.RadialSites=m_plot(C{3}(ii),C{4}(ii),'^k','markersize',8,'linewidth',2);
end

catch
end

%-------------------------------------------------
% Plot the colorbar
try
  p.HourPlot.ColorTicks;
catch
  ss = max( cart2magn( TUV.U(:,I), TUV.V(:,I) ) );
  p.HourPlot.ColorTicks = 0:10:ss+10;
end

caxis( [ min(p.HourPlot.ColorTicks), max(p.HourPlot.ColorTicks) ] );
colormap( feval( p.HourPlot.ColorMap, numel(p.HourPlot.ColorTicks)-1 ) );
cax = colorbar;
hdls.colorbar = cax;
hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                    'saturated.'], 'fontsize', 14 );
hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 14 );

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
titleStr = {sprintf('%s %s , %d hour mean', ...
                    p.HourPlot.DomainName,conf.HourPlot.Type,length(TUVcat.TimeStamp)),
            sprintf('From %s to %s',datestr(dtime(1)),datestr(dtime(end)))};
hdls.title = title(titleStr, 'fontsize', 20 );

%-------------------------------------------------
% Print if desired
if p.HourPlot.Print
  [odn,ofn] = datenum_to_directory_filename( p.HourPlot.BaseDir, dtime, ...
              p.HourPlot.FilePrefix, '.jpg', p.MonthFlag );
  odn = odn{1}; ofn = ofn{1};
  ofn = fullfile(odn,ofn);
  if ~exist( odn, 'dir' )
      mkdir(odn);
  end
    
  print_kerfoot(ofn,700,'-shave 120x');
%  print_kerfoot(ofn,700,'-shave 120x +repage'); %for gif
end




timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/mean_vector_plot.m')

sd_str=datestr(min(dtime),'yyyymmdd');
ed_str=datestr(max(dtime),'yyyymmdd');

print(1,'-dpng','-r400',[conf.Plot.PrintPath 'Total_Mean_' num2str(pct_cov) 'pct_' p.HourPlot.DomainName '_' sd_str '_' ed_str '.png'])

close all

end

toc