function curly_vector_plot_fn(TUV,p)

%% grid the data
x=TUV.LonLat(:,1);
y=TUV.LonLat(:,2);
[X,Y] = meshgrid(unique(x),unique(y));

U=NaN(size(X));
V=NaN(size(Y));

%% don't use griddata from Laura on 12/4/15
% U=griddata(x,y,TUV.U,X,Y);
% V=griddata(x,y,TUV.V,X,Y);


% for ii=1:numel(X)
%     temp_distance=dist(X(ii),Y(ii),x,y);
%     [~,I]=min(temp_distance);
%     U(ii)=TUV.U(I);
%     V(ii)=TUV.V(I);
% end


%% you dont want to use grid data to make the grid rectangular.  Also, you 
%% should loop through the smaller grid so new grid points dont get assigned
%% a U and V 
for ii=1:numel(x)
    temp_distance=dist(x(ii),y(ii),X(:),Y(:));
    [~,I]=min(temp_distance);
    U(I)=TUV.U(ii);
    V(I)=TUV.V(ii);
end


hold on
    
%% Pcolor the magnitude of the vectors


 mag = sqrt(U.^2 + V.^2); % 
 pcolor(X,Y,mag);
 shading flat
%shading interp
%clim = [min(p.HourPlot.ColorTicks),max(p.HourPlot.ColorTicks)];
%[~,hts] = colordot( x,y,mag,clim,'m_line');
%scatter( x,y,20,mag,'filled');
%set(h,'markersize',15);

%% Plot the base map for the total file
%plotBasemap( p.HourPlot.axisLims(1:2),p.HourPlot.axisLims(3:4),p.HourPlot.CoastFile,'Mercator','patch',[1 .69412 0.39216],'edgecolor','k')
coast = load('/Users/hroarty/data/coast_files/MARA_Coast.mat');
coast2 = coast.ncst;
e = plot(coast2(:,1), coast2(:,2), 'k', 'linewidth', 1);

tanLand = [240,230,140]./255;
mapshow(coast2(:,1), coast2(:,2), 'DisplayType', 'polygon', 'facecolor', tanLand)

xlim(p.HourPlot.axisLims(1:2));
ylim(p.HourPlot.axisLims(3:4));

%% draw the curly vectors
%curvvec(X,Y,U,V, 'color', 'k', 'minmag',0, 'maxmag', 30, 'numpoints',30, 'thin', 3, 'linewidth', 1.25);
%streakarrow(X,Y,U,V, 1, 1, 1);

streakarrow(X(1:p.HourPlot.grid:end,1:p.HourPlot.grid:end),...
    Y(1:p.HourPlot.grid:end,1:p.HourPlot.grid:end),...
    U(1:p.HourPlot.grid:end,1:p.HourPlot.grid:end),...
    V(1:p.HourPlot.grid:end,1:p.HourPlot.grid:end), ...
    p.HourPlot.np, p.HourPlot.arrow, p.HourPlot.thin);

project_mercator;
grid on
box on



%%-------------------------------------------------
%% Plot location of sites
try
% read in the MARACOOS sites
dir='/Users/hroarty/data/';
file='maracoos_codar_sites.txt';
[C]=read_in_maracoos_sites(dir,file);

%% plot the location of the 13 MHz sites

for ii=1:17
    hdls.RadialSites=plot(C{3}(ii),C{4}(ii),'^k','markersize',8,'linewidth',2);
end

catch
end

%% plot_bathymetry
%m_plot_bathymetry2('mac',[-25 -50 -100 -500])%% plot the bathymetry

%% -------------------------------------------------
    %% Plot the political boundaries
    
    %% load the political boundaries file
    boundaries=load('/Users/hroarty/data/political_boundaries/WDB2_global_political_boundaries.dat');

    %% plot the location of the sites within the bounding box
    %hdls.RadialSites=m_plot(sites{1}(in),sites{2}(in),'^r','markersize',8,'linewidth',2);

    %% plot the political boundaries
    hdls.boundaries=plot(boundaries(:,1),boundaries(:,2),'-k','linewidth',1);

%bathy=load ('/Users/hroarty/data/bathymetry/marcoos_15second_ngdc.mat');
bathy=load ('/Users/hroarty/data/bathymetry/eastcoast.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
bathylines=[ -50 -80 -200];

[cs, h1] = contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
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
%colormap( feval( p.HourPlot.ColorMap, numel(p.HourPlot.ColorTicks)-1 ) );
%colormap(flipud(p.HourPlot.ColorMap));
%colormap(flipud(autumn(6)));
colormap(p.HourPlot.ColorMap);
% colormap(jet(6));

cax = colorbar;
hdls.colorbar = cax;
hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                    'saturated.'], 'fontsize', 14 );
hdls.xlabel = xlabel( cax, 'cm/s', 'fontsize', 14 );

set(cax,'ytick',p.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')

%%-------------------------------------------------
%% Add title string
try, p.HourPlot.TitleString;
catch
%   p.HourPlot.TitleString = [p.HourPlot.DomainName,' ',p.HourPlot.Type,': ', ...
%                             datestr(TUV.TimeStamp,'yyyy/mm/dd HH:MM'),' ',TUV.TimeZone(1:3)];
  p.HourPlot.TitleString = ['Surface Current Map 25 Hour Mean: ', ...
                            datestr(TUV.TimeStamp,'mmm dd, yyyy HH:MM')];                     
                        
end
hdls.title = title( p.HourPlot.TitleString, 'fontsize', 16,'color','black' );

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

sd_str2=datestr(TUV.TimeStamp(1),'yyyymmdd');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print the figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



timestamp(1,p.HourPlot.script)

print('-dpng','-r200',[p.HourPlot.print_path 'TUV_' p.HourPlot.name '_' p.HourPlot.region '_' sd_str2 '.png'])

close all




