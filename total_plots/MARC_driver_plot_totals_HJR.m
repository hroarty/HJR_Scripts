function [ ofn, hdls, p ] = MARC_driver_plot_totals_HJR( dtime, p, varargin )
%-------------------------------------------------
% MARCOOS HF-Radar Processing Toolbox
%
% Real-time Totals plotting script
% This script can plot the LSQ or OI Totals
%
% Edited by Sage 3/4/2009
%-------------------------------------------------
if numel(dtime)>1
  error('This function can only process one hour at a time');
end

% Default parameters and parameter checks
p = HFRPdriver_default_conf( p );
mand_params = { 'HourPlot.VectorScale' };
p = checkParamValInputArgs( p, {}, mand_params, varargin{:} );

try, p.HourPlot.DomainName;
catch
  p.HourPlot.DomainName = p.Totals.DomainName;
end

try, p.HourPlot.FilePrefix;
catch
  p.HourPlot.FilePrefix = [ 'hour_plot_' p.HourPlot.Type '_' ...
                      p.HourPlot.DomainName '_' ];
end

%-------------------------------------------------
% Load totals data type depending on config
s = p.HourPlot.Type;
[tdn,tfn] = datenum_to_directory_filename( p.(s).BaseDir, dtime, p.(s).FilePrefix, p.(s).FileSuffix, p.(s).MonthFlag );
tdn = tdn{1};

data = load(fullfile(tdn,tfn{1}));

%-------------------------------------------------
% Set up the Basemap

% Define axis limits if necessary
try, p.HourPlot.axisLims;
catch, p.HourPlot.axisLims = axisLims( data.TUV, 0.1 ); end

% Basemap with nice boundary
clf
plotBasemap( p.HourPlot.axisLims(1:2), p.HourPlot.axisLims(3:4), ...
             p.Plot.coastFile, p.Plot.Projection, p.Plot.plotBasemap_xargs{:} ...
             );
whitebg([0.6 0.6 0.6])
         
%m_ungrid;
%m_grid( p.Plot.m_grid_xargs{:}, 'xtick', [floor(p.HourPlot.axisLims(1)):ceil(p.HourPlot.axisLims(2))] );

hold on

%% plot_bathymetry
m_plot_bathymetry2('mac',[-50 -100 -500])%% plot the bathymetry

if p.Plot.Speckle
  m_usercoast( p.Plot.coastFile, 'speckle', 'color', 'k' )
end

%% Add the velocity bar
try, p.HourPlot.VelocityScaleLocation;
  [hdls.VelocityScaleArrow,hdls.VelocityScaleText,p.HourPlot.VelocityScaleLocation] ...
    = plotVelocityScale( p.HourPlot.VelocityScaleLength, p.HourPlot.VectorScale, ...
                     [num2str(p.HourPlot.VelocityScaleLength) ' cm/s'], ...
                     p.HourPlot.VelocityScaleLocation,'horiz', ...
                     'm_vec','linewidth',2 );
  set(hdls.VelocityScaleText,'fontsize',13,'fontweight','bold')
  set(hdls.VelocityScaleArrow,'facecolor','k')
catch
end

% Add distance bar
try, p.HourPlot.DistanceBarLocation;
  [hdls.DistanceBar,hdls.DistanceBarText, ...
    p.HourPlot.DistanceBarLocation] = ...
                    m_distance_bar( p.HourPlot.DistanceBarLength, ...
                    p.HourPlot.DistanceBarLocation,'horiz',0.2 );
  set(hdls.DistanceBar,'linewidth',2 );
  set(hdls.DistanceBarText,'fontsize',13,'fontweight','bold');
catch
end

%-------------------------------------------------
% Plot the data
hdls = [];

% Find the unique values for the lat and lon grid
unique_x=unique(data.TUV.LonLat(:,1));
unique_y=unique(data.TUV.LonLat(:,2));

% The indices for the rows and columns to keep
% x_ind=[1;10;19;27;36;44;53;61;70;78;87;96;105;113;122;130;138];
% y_ind=[1;10;20;29;38;47;57;66;76;85;94;103;113;121;130];

grid_spacing=3;
x_ind=[1:grid_spacing:length(unique_x)];
y_ind=[1:grid_spacing:length(unique_y)];

[NX,NY]=meshgrid(unique_x(x_ind),unique_y(y_ind));

% Vectorize the array
NX=NX(:);
NY=NY(:);

% define the varaible before you write to it
marcoos_grid_ind=[];

% find the indices of the grid points you want to keep
for i=1:length(NX)
    ind=find(NX(i)==data.TUV.LonLat(:,1) &NY(i)==data.TUV.LonLat(:,2));
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
data.TUV=subsrefTUV(data.TUV,marcoos_grid_ind);

% [hdls.plotData] = plotData( data.TUV, 'm_vec',dtime, p.HourPlot.VectorScale, ...
%                               p.HourPlot.plotData_xargs{:});

                              
 [hdls.plotData,I] = plotData2( data.TUV, 'm_vec_same', dtime, p.HourPlot.VectorScale, ...
                               p.HourPlot.plotData_xargs{:} );
%%-------------------------------------------------
%% Plot location of sites
try
sl = vertcat( data.RTUV.SiteOrigin );

% Only plot the ones that are inside the plot limits.
plotRect = [ p.HourPlot.axisLims([1,3]);
         p.HourPlot.axisLims([2,3]);
         p.HourPlot.axisLims([2,4]);
         p.HourPlot.axisLims([1,4]);
         p.HourPlot.axisLims([1,3]) ];
ins = inpolygon(sl(:,1),sl(:,2),plotRect(:,1),plotRect(:,2));
hdls.RadialSites = m_plot( sl(ins,1), sl(ins,2), ...
                         '^k','markersize',8,'linewidth',2);

%% plot the buoy location
%hdls.buoy = m_plot( -73.6666, 40.0335, ...
%                         '^k','markersize',8,'linewidth',2);  
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
colormap( feval( p.HourPlot.ColorMap, numel(p.HourPlot.ColorTicks)-1 ) )
%colormap( feval( p.HourPlot.ColorMap, p.HourPlot.ColorMapBins))
%colormap(jet(10))

cax = colorbar;
hdls.colorbar = cax;
hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                    'saturated.'], 'fontsize', 8 );
hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 12 );

set(cax,'ytick',p.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')

%-------------------------------------------------
% Add title string
try, p.HourPlot.TitleString;
catch
  p.HourPlot.TitleString = [p.HourPlot.DomainName,' ',p.HourPlot.Type,': ', ...
                            datestr(dtime,'yyyy/mm/dd HH:MM'),' ',data.TUV.TimeZone(1:3)];
end
hdls.title = title( p.HourPlot.TitleString, 'fontsize', 16,'color',[.2 .3 .9] );

%timestamp(1,'/Users/hroarty/COOL/01_CODAR/OPT/ONT_paper/scratch_totalplot.m')

%-------------------------------------------------
% Print if desired
if p.HourPlot.Print
  [odn,ofn] = datenum_to_directory_filename( p.HourPlot.BaseDir, dtime, ...
              p.HourPlot.FilePrefix, '.png', p.MonthFlag );
  odn = odn{1}; ofn = ofn{1};
  ofn = fullfile(odn,ofn);
  if ~exist( odn, 'dir' )
      mkdir(odn);
  end
    
  %print_kerfoot(ofn,700,'-shave 120x');
  print( '-dpng', '-r300', ofn)
end


hold off
