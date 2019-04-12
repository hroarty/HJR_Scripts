%% Create the basemap
% conf.Plot.lims=[-77 -68 35 42];%ALL MAB
conf.Plot.lims=[-72 -69 39 41];%Region 1
conf.Plot.coast='/Users/roarty/Documents/GitHub/HJR_Scripts/data/coast_files/MARA_coast.mat';
conf.Plot.boundaries=load('/Users/roarty/Documents/GitHub/HJR_Scripts/data/political_boundaries/WDB2_global_political_boundaries.dat');
conf.Plot.bathylines=[ -50 -80 -200 -1000];
conf.Plot.wind_plot_scale=4;
conf.Plot.wind_scale=2;
conf.Plot.temporal_coverage=0.4;
conf.Plot.LandColor= [240,230,140]./255; %rgb value for tan

conf.HourPlot.grid=2;
conf.HourPlot.np=2;
conf.HourPlot.arrow=1;
conf.HourPlot.thin=3;

hold on
% plotBasemap(conf.Plot.lims(1:2),conf.Plot.lims(3:4),conf.Plot.coast,'mercator','patch',[240,230,140]./255);

coast = load(conf.Plot.coast);
coast = coast.ncst;
%     e = plot(coast(:,1), coast(:,2), 'k', 'linewidth', 1);
mapshow(coast(:,1), coast(:,2), 'DisplayType', 'polygon', 'facecolor', conf.Plot.LandColor)

%% read in the bathymetry and replace fill values with NaNs
bathy=load ('/Users/roarty/Documents/GitHub/HJR_Scripts/data/bathymetry/eastcoast_4min.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
%% Plot the bathymetry
% [cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,conf.Plot.bathylines);
% clabel(cs,h1,'fontsize',8,'Color',[0.8 0.8 0.8]);
% set(h1,'LineColor',[0.8 0.8 0.8])


%% plot the political boundaries
hdls.boundaries=plot(conf.Plot.boundaries(:,1),conf.Plot.boundaries(:,2),'-k','linewidth',1);



input_file ='/Users/roarty/COOL/01_CODAR/MARACOOS/20131211_MAB_Currents/decadal_means.nc';

var.u= 'winter_u_mean';
var.v= 'winter_v_mean';
% var.u= [years.seasons{kk} '_u_mean'];
% var.v= [years.seasons{kk} '_v_mean'];
var.t=datenum(2007,12,1);

%% load the current data
[TUV]=convert_Nazzaro_NC_to_TUVgrid(input_file,var );



[dir,speed]=uv2compass(TUV.U,TUV.V);
dir=angle360(dir,180);% use this line for current direction from

pcolor(TUV.LON,TUV.LAT,speed)

% plot the vectors
streakarrow(X(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end),...
    Y(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end),...
    U(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end),...
    V(1:conf.HourPlot.grid:end,1:conf.HourPlot.grid:end), ...
    conf.HourPlot.np, conf.HourPlot.arrow, conf.HourPlot.thin);

project_mercator;
grid on
box on

colormap(jet(16))
cax=colorbar;
caxis([0 12])

cbh = colorbar ; %Create Colorbar
cbh.Ticks = 0:45:360 ; %Create 8 ticks from zero to 1
cbh.TickLabels = num2cell(0:45:360) ;    %Replace the labels of these 8 ticks with

%% Plot the bathymetry
[cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,conf.Plot.bathylines);
clabel(cs,h1,'fontsize',8,'Color',[0.8 0.8 0.8]);
set(h1,'LineColor',[0.8 0.8 0.8])

%% Add title and timestamp to the figure
% title({'2007-2016 Mean Surface Current Direction Toward'},'FontWeight','bold','FontSize',14)
title({'2007-2016 Mean Surface Currents Winter'},'FontWeight','bold','FontSize',14)

conf.Plot.Filenname=['Decadal_Current_Map_' var.u '.png'];
conf.Plot.script='plot_current_vector_map.m';
conf.Plot.print_path='/Users/roarty/COOL/01_CODAR/MARACOOS/20131211_MAB_Currents/';


timestamp(1,[conf.Plot.Filenname ' / ' conf.Plot.script])

% set(gca, 'LooseInset', get(gca, 'TightInset'))

%% print the figure
print(1,'-dpng','-r400',[conf.Plot.print_path conf.Plot.Filenname])