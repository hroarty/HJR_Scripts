function [ ofn, hdls, p ] = MARC_driver_plot_errors_HJR( dtime, p, varargin )
%-------------------------------------------------
% MARCOOS HF-Radar Processing Toolbox
%
% Real-time Total Errors plotting script
% Edited by Sage 3/6/2009
%-------------------------------------------------
if numel(dtime)>1
  error('This function can only process one hour at a time');
end

% Default parameters and parameter checks
p = HFRPdriver_default_conf( p );
mand_params = { 'ErrorPlot.TitlePrefix', 'ErrorPlot.Error', 'ErrorPlot.ErrorComponent' };
p = checkParamValInputArgs( p, {}, mand_params, varargin{:} );

try, p.ErrorPlot.DomainName;
catch
  p.ErrorPlot.DomainName = p.Totals.DomainName;
end

try, p.ErrorPlot.FilePrefix;
catch
  p.ErrorPlot.FilePrefix = [ 'error_plot_' p.ErrorPlot.Type '_' ...
                      p.ErrorPlot.DomainName '_' ];
end

%-------------------------------------------------
% Load totals data type depending on config
try, p.ErrorPlot.Type;
catch
  p.ErrorPlot.Type = 'Totals';
end

s = p.ErrorPlot.Type;
[tdn,tfn] = datenum_to_directory_filename( p.(s).BaseDir, dtime, p.(s).FilePrefix, p.(s).FileSuffix, p.(s).MonthFlag );
tdn = tdn{1};

data = load(fullfile(tdn,tfn{1}));

%-------------------------------------------------
% Set up the Basemap

% Define axis limits if necessary
try, p.ErrorPlot.axisLims;

catch, p.ErrorPlot.axisLims = axisLims( data.TUV, 0.1 ); end

% Basemap with nice boundary
clf
plotBasemap( p.ErrorPlot.axisLims(1:2), p.ErrorPlot.axisLims(3:4), ...
             p.Plot.coastFile, p.Plot.Projection, 'patch',[1 .69412 0.39216],'edgecolor','k' ...
             );
        
% m_ungrid;
% m_grid( p.Plot.m_grid_xargs{:}, 'xtick', [floor(p.HourPlot.axisLims(1)):ceil(p.HourPlot.axisLims(2))] );

hold on

if p.Plot.Speckle
  m_usercoast( p.Plot.coastFile, 'speckle', 'color', 'k' )
end

% Add distance bar
try, p.ErrorPlot.DistanceBarLocation;
  [hdls.DistanceBar,hdls.DistanceBarText, ...
      p.ErrorPlot.DistanceBarLocation] = ...
                      m_distance_bar( p.ErrorPlot.DistanceBarLength, ...
                      p.ErrorPlot.DistanceBarLocation,'horiz',0.2 );
  set(hdls.DistanceBar,'linewidth',2 );
  set(hdls.DistanceBarText,'fontsize',13,'fontweight','bold');
catch
end

%-------------------------------------------------
% Plot the colorbar
try
  p.ErrorPlot.ColorTicks;
catch
  ss = max( cart2magn( data.TUV.U(:,I), data.TUV.V(:,I) ) );
  p.ErrorPlot.ColorTicks = 0:10:ss+10;
end

caxis( [ min(p.ErrorPlot.ColorTicks), max(p.ErrorPlot.ColorTicks) ] );

try
    p.ErrorPlot.ColorMap;
catch
  p.ErrorPlot.ColorMap = 'jet';
end
colormap( feval( p.ErrorPlot.ColorMap, numel(p.ErrorPlot.ColorTicks)-1 ) );
% colormap(p.ErrorPlot.ColorMap(1:numel(p.ErrorPlot.ColorTicks)-1,:))
cax = colorbar;
hdls.colorbar = cax;
%hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
%                    'saturated.'], 'fontsize', 8 );
%hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 12 );

set(cax,'ytick',p.ErrorPlot.ColorTicks,'fontsize',14,'fontweight','bold')

%-------------------------------------------------
% Plot the data
for jj=1:numel(data.TUV.ErrorEstimates)
  if strcmp(data.TUV.ErrorEstimates(jj).Type,p.ErrorPlot.Error)
    err_ind = jj;  
  end
end

hdls = [];
[hdls.plotData,I] = colordot( data.TUV.LonLat(:,1),data.TUV.LonLat(:,2),...
                    data.TUV.ErrorEstimates(err_ind).(p.ErrorPlot.ErrorComponent),...
                    [ min(p.ErrorPlot.ColorTicks) max(p.ErrorPlot.ColorTicks) ],...
                    'm_plot','markersize',p.ErrorPlot.MarkerSize);
                
%-------------------------------------------------
% Plot location of sites
sl = vertcat( data.RTUV.SiteOrigin );

% Only plot the ones that are inside the plot limits.
plotRect = [ p.ErrorPlot.axisLims([1,3]);
         p.ErrorPlot.axisLims([2,3]);
         p.ErrorPlot.axisLims([2,4]);
         p.ErrorPlot.axisLims([1,4]);
         p.ErrorPlot.axisLims([1,3]) ];
ins = inpolygon(sl(:,1),sl(:,2),plotRect(:,1),plotRect(:,2));
hdls.RadialSites = m_plot( sl(ins,1), sl(ins,2), ...
                         '^k','markersize',8,'linewidth',2);

%-------------------------------------------------
% Add title string
try, p.ErrorPlot.TitleString;
catch
  p.ErrorPlot.TitleString = [p.ErrorPlot.TitlePrefix, ...
      datestr(dtime,'yyyy/mm/dd HH:MM'),' ',data.TUV.TimeZone(1:3)];
end
hdls.title = title( p.ErrorPlot.TitleString, 'fontsize', 16,'color','k' );

%-------------------------------------------------
% Print if desired
try, p.ErrorPlot.Print;
catch, p.ErrorPlot.Print = false;
end

if p.ErrorPlot.Print
  [odn,ofn] = datenum_to_directory_filename( p.ErrorPlot.BaseDir, dtime, ...
              p.ErrorPlot.FilePrefix, '.png', p.MonthFlag );
  odn = odn{1}; ofn = ofn{1};
  ofn = fullfile(odn,ofn);
  if ~exist( odn, 'dir' )
      mkdir(odn);
  end


  
  
end


hold off
