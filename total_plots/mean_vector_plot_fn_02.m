function mean_vector_plot_fn_02(TUVcat,p,dtime)


%% Subsample the data
% Find the unique values for the lat and lon grid
unique_x=unique(TUVcat.LonLat(:,1));
unique_y=unique(TUVcat.LonLat(:,2));

% The indices for the rows and columns to keep
% x_ind=[1;10;19;27;36;44;53;61;70;78;87;96;105;113;122;130;138];
% y_ind=[1;10;20;29;38;47;57;66;76;85;94;103;113;121;130];


x_ind=1:p.HourPlot.grid:length(unique_x);
y_ind=1:p.HourPlot.grid:length(unique_y);

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

%% Plot the base map for the radial file
plotBasemap( p.HourPlot.axisLims(1:2),p.HourPlot.axisLims(3:4),p.HourPlot.CoastFile,'Mercator','patch',[1 .69412 0.39216],'edgecolor','k')

hold on

TUV = TUVsub;
  
%% Plot the percent coverage
hdls = [];
%[hdls.plotData,I] = plotData( TUV, 'm_vec', median(dtime), p.HourPlot.VectorScale);%, ...
                             % p.HourPlot.plotData_xargs{:} );
                             
[hdls.plotData,I] = plotData2( TUV, 'm_vec_same', TUV.TimeStamp, p.HourPlot.VectorScale);%, ...
%p.HourPlot.plotData_xargs{:} );


%%-------------------------------------------------
%% Plot location of sites
try
%% read in the MARACOOS sites
dir='/Users/hroarty/data/';
file='maracoos_codar_sites.txt';
[C]=read_in_maracoos_sites(dir,file);

%% plot the location of the 13 MHz sites

for ii=18:23
    hdls.RadialSites=m_plot(C{3}(ii),C{4}(ii),'^k','markersize',8,'linewidth',2);
end

catch
end

%% -------------------------------------------------
    %% Plot the political boundaries
    
    %% load the political boundaries file
%     boundaries=load('/Users/hroarty/data/political_boundaries/WDB2_global_political_boundaries.dat');

    %% plot the location of the sites within the bounding box
%     hdls.RadialSites=m_plot(sites{1}(in),sites{2}(in),'^r','markersize',8,'linewidth',2);

    %% plot the political boundaries
%     hdls.boundaries=m_plot(boundaries(:,1),boundaries(:,2),'-k','linewidth',1);

% -------------------------------------------------------------------------
% % plot the county borders
% S1 = shaperead('/Users/hroarty/data/political_boundaries/cb_2016_us_county_500k/cb_2016_us_county_500k.shp');
% for jj=1:length(S1)
%     m_plot(S1(jj).X,S1(jj).Y,'-k','linewidth',1);
% end


%% plot_bathymetry
%m_plot_bathymetry2('mac',[-25 -50 -100 -500])%% plot the bathymetry
%bathy=load ('/Users/hroarty/data/bathymetry/marcoos_15second_ngdc.mat');
bathy=load (p.HourPlot.Bathy);
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
%bathylines=[-20 -50 -80 -200];

[cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,p.HourPlot.bathylines);
clabel(cs,h1,'fontsize',8);
set(h1,'LineColor','k')


%% -------------------------------------------------
% Plot the colorbar
try
  p.HourPlot.ColorTicks;
catch
  ss = max( cart2magn( TUV.U(:,I), TUV.V(:,I) ) );
  p.HourPlot.ColorTicks = 0:10:ss+10;
end

caxis( [ min(p.HourPlot.ColorTicks), max(p.HourPlot.ColorTicks) ] );
% colormap( feval( p.HourPlot.ColorMap, numel(p.HourPlot.ColorTicks)-1 ) );
colormap(p.HourPlot.ColorMap)
%jet(64);

cax = colorbar;
hdls.colorbar = cax;
hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                    'saturated.'], 'fontsize', 14 );
hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 14 );

set(cax,'ytick',p.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')

%%-------------------------------------------------
%% Add title string
try p.HourPlot.TitleString;
catch
    if p.HourPlot.TypeMean
  p.HourPlot.TitleString = [p.HourPlot.DomainName,' ',p.HourPlot.Type,': ', ...
                            datestr(dtime(1),'yyyy/mm/dd HH:MM'),' to ',datestr(dtime(end),'yyyy/mm/dd HH:MM')];
    else 
      p.HourPlot.TitleString = [p.HourPlot.DomainNameTitle,' ',p.HourPlot.Type,': ', ...
                            datestr(dtime,'yyyy/mm/dd HH:MM'),' ',TUVcat.TimeZone];  
    end
    
end
hdls.title = title( p.HourPlot.TitleString, 'fontsize', 10,'color','k' );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add title string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sd_str='Jan 01, 2012';
% sd_str2='20120101';
% 
% sd_str3='Dec 31, 2012';
% sd_str4='20121231';
% 
% titleStr = ['BPU Mean for:  ' sd_str ' to ' sd_str3 ];...
%             
% 
% hdls.title = title(titleStr);
% set(hdls.title,'fontsize', 20);

sd_str2=datestr(TUVcat.TimeStamp(1),'yyyymmddTHHMM');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print the figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


timestamp(1,p.HourPlot.script)

print('-dpng',p.HourPlot.resolution,[p.HourPlot.print_path 'TUV_' p.HourPlot.name '_' p.HourPlot.region '_' sd_str2 '_' p.OI.combo '.png'])

close all




