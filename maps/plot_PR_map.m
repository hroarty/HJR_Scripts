% base map
% m_proj('lambert','lons',[-68 -65],'lat',[17 19],'rectbox','on');
% [cs,h]=m_etopo2('contourf',[-7000:500:0],'edgecolor','none');
% m_gshhs_l('patch',[.5 .8 0],'edgecolor','none');
% m_grid('linewi',2,'layer','top');
% caxis([-7000 000]);
% m_contfbar(.92,[.2 .5],cs,h,'endpiece','no','axfrac',.02);
% colormap(m_colmap('blue'));   
% title('Puerto Rico HF Radar Network');

hold on

coastFileName='/Users/roarty/Documents/GitHub/HJR_Scripts/data/coast_files/PR_coast.mat';
conf.HourPlot.axisLims=[-68-30/60 -65 16+00/60 18+40/60];% All PR
plotBasemap(conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),coastFileName,'mercator','patch',[240,230,140]./255);

%%-------------------------------------------------
%% Plot location of sites

%% read in the MARACOOS sites
dir='/Users/roarty/Documents/GitHub/HJR_Scripts/data/';
file='caricoos_codar_sites_2018.txt';
[C]=read_in_maracoos_sites(dir,file);

%% plot the location of the radar sites

num_of_range_cells=30;

c=lines(5);

for ii=1:5
    hdls.RadialSites=m_plot(C{3}(ii),C{4}(ii),'^k','markersize',8,'linewidth',2);
    %% print the site name
    m_text(C{3}(ii)+0.1,C{4}(ii)+0.1,C{2}(ii),'FontSize',10,'FontWeight','bold','Color','k');
    
    %% Generate and plot the range rings
     angular_coverage=C{7}(ii)-C{6}(ii);
     start_angle=C{6}(ii);
     lat=C{4}(ii);
     lon=C{3}(ii);
     
     angular_coverage=C{7}(ii)-C{6}(ii);
    radial_spacing=5;
    rc_size=C{9}(ii);
    num_of_range_cells=30;
    
    [r_ring_x , r_ring_y , r_line_x , r_line_y] = HJR_generate_range_rings(rc_size, num_of_range_cells, angular_coverage, C{6}(ii), radial_spacing, lat, lon);

    m_plot(r_ring_x , r_ring_y,'-','Color',c(ii,:))
    m_plot(r_line_x , r_line_y,'-','Color',c(ii,:))
end




% m_elev;


 %% plot_bathymetry

 f='/Users/roarty/data/bathymetry/etopo1_Puerto_Rico.nc';
 
[LON,LAT,Z] = read_in_etopo_bathy(f);
% bathy=load ('/Users/roarty/Documents/GitHub/HJR_Scripts/data/bathymetry/puerto_rico/puerto_rico_6second_grid.mat');
% ind2= bathy.depthi==99999;
% bathy.depthi(ind2)=NaN;
bathylines=[ -50 -100 -500 -1000 -2000 -3000 -4000 -5000];

[cs, h1] = m_contour(LON,LAT, Z,bathylines);
clabel(cs,h1,'fontsize',8,'Color',[0.8 0.8 0.8]);
set(h1,'LineColor',[0.8 0.8 0.8])

%% Add title and timestamp to the figure
title('CARICOOS HF Radar Network','FontWeight','bold','FontSize',14)

conf.Plot.Filenname='CARICOOS_HFR_Network.png';
conf.Plot.script='plot_PR_map.m';
conf.Plot.print_path='/Users/roarty/COOL/01_CODAR/02_Collaborations/Puerto_Rico/20180620_MTS_Charleston/';


timestamp(1,[conf.Plot.Filenname ' / ' conf.Plot.script])

% set(gca, 'LooseInset', get(gca, 'TightInset'))

%% print the figure
print(1,'-dpng','-r400',[conf.Plot.print_path conf.Plot.Filenname])


