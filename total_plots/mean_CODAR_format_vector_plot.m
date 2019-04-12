
conf.HourPlot.Type='UNC';
p.HourPlot.Type=conf.HourPlot.Type;
p.HourPlot.VectorScale=0.004;
p.HourPlot.ColorMap='lines';
p.HourPlot.ColorTicks=0:10:50;
p.HourPlot.axisLims=[-75-20/60 -73 38.5 41];
p.HourPlot.DomainName='BPU';
p.HourPlot.Print=false;
p.meanTUV.Thresh=20;
p.HourPlot.plotData_xargs= {};


conf.UWLS.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS/20120208_Zelenke_Request/totals/lsq/';
conf.UWLS.FilePrefix='tuv_BPU_';
conf.UWLS.FileSuffix='.mat';
conf.UWLS.MonthFlag=false;

conf.OI.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS/20120208_Zelenke_Request/totals/oi/';
conf.OI.FilePrefix='tuv_oi_BPU_';
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=false;

conf.MEAS.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS/20120208_Zelenke_Request/totals/meas/';
conf.MEAS.FilePrefix='TOTL_SHOR_';
conf.MEAS.FileSuffix='.tuv';
conf.MEAS.MonthFlag=false;

conf.UNC.BaseDir='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180201_2017_Reprocessing/20180215_Sara_QC_Data/2017_05/Totals_qcd/IdealPattern/';
conf.UNC.FilePrefix='TOTL_RDLi_';
conf.UNC.FileSuffix='.tuv';
conf.UNC.MonthFlag=false;


%% Decalre the time that you want to load
dtime = datenum(2017,05,01,0,0,0):1/24:datenum(2017,06,01,0,0,0);

%% load the total data depending on the config
s=conf.HourPlot.Type;
[f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag,0);

for ii=1:length(f)
[ d, fn, c ] = loadDataFileWithChecks( f{ii} );
end


%% concatenate the total data
[TUVcat,goodCount] = catTotalStructs(f,'TUV',0,0,0,0);

ii = false(size(TUVcat));

%% Subsample the data
% Find the unique values for the lat and lon grid
unique_x=unique(TUVcat.LonLat(:,1));
unique_y=unique(TUVcat.LonLat(:,2));

% The indices for the rows and columns to keep
% x_ind=[1;10;19;27;36;44;53;61;70;78;87;96;105;113;122;130;138];
% y_ind=[1;10;20;29;38;47;57;66;76;85;94;103;113;121;130];

x_ind=[1:3:length(unique_x)];
y_ind=[1:3:length(unique_y)];

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
coastline_file='BPU_coast_';


%% Plot the base map for the radial file
plotBasemap( p.HourPlot.axisLims(1:2),p.HourPlot.axisLims(3:4),coastline_file,'Mercator','patch',[.5 .9 .5],'edgecolor','k')

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
  
%% Plot the percent coverage
hdls = [];
%[hdls.plotData,I] = plotData( TUV, 'm_vec', median(dtime), p.HourPlot.VectorScale);%, ...
                             % p.HourPlot.plotData_xargs{:} );
                             
[hdls.plotData,I] = plotData2( TUV, 'm_vec_same', TUV.TimeStamp, p.HourPlot.VectorScale, ...
p.HourPlot.plotData_xargs{:} );


%%-------------------------------------------------
%% Plot location of sites
try
%% read in the MARACOOS sites
dir='/Users/hroarty/data/';
file='maracoos_codar_sites.txt';
[C]=read_in_maracoos_sites(dir,file);

%% plot the location of the 13 MHz sites

for ii=1:17
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


