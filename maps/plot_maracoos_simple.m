clear all
close all



%% plot the base map small map ISRAEL
conf.Plot.lims=[-78-00/60 -67.5-00/60 33+00/60 43+30/60];

%% plot the base map big map
%lims=[-175-00/60 -135-00/60 53+00/60 72+00/60];

%coastFileName = '/Users/hroarty/COOL/01_CODAR/DHS/121025_Alaska_Results/Alaska_Coast.mat';
% conf.Plot.Coast='/Users/hroarty/COOL/01_CODAR/MARACOOS/20130313_GEO_HF/Maps/maracoos_coast_large.mat';
conf.Plot.Coast='/Users/hroarty/data/coast_files/MARA_Coast2.mat';

hold on

% plotBasemap(conf.Plot.lims(1:2),conf.Plot.lims(3:4),conf.Plot.Coast,'mercator','patch',[240,230,140]./255);





%% location of the global hf radar sites
%% Load in the global hf radar locations csv
dir='/Users/hroarty/COOL/KML/';
file='Global_HF_Radar_Sites_20120510.csv';
[sites]=read_in_global_hf_sites(dir,file);

%% filter the sites outside the domain
in = inpolygon(sites{1},sites{2},conf.Plot.lims([1 2 2 1 1]),conf.Plot.lims([3 3 4 4 3]));

%% plot the location of the sites within the bounding box
%hdls.RadialSites=m_plot(sites{1}(in),sites{2}(in),'^r','markersize',8,'linewidth',2);

%% load the political boundaries file
%boundaries=load('/Volumes/coolgroup/toolboxes/map_figs/WDB2_global_international_boundaries.dat');

%% load the political boundaries file
boundaries=load('/Users/hroarty/data/political_boundaries/WDB2_global_political_boundaries.dat');





%% -------------------------------------------------
%% Plot location of sites
% try
%% read in the MARACOOS sites
dir='/Users/hroarty/data/';
file='maracoos_codar_sites_2018.txt';
[C]=read_in_maracoos_sites(dir,file);

LR=1:17;
SR=[18 19 20 21 22 23 24 41];
HR=25:40;

conf.Plot.directory='/Users/hroarty/COOL/01_CODAR/MARACOOS_II/20180130_HFR_Book/';
tanLand = [240,230,140]./255;

rc_size=6; % km
num_of_range_cells=30;
radial_spacing=5; % degrees


for ii=1:17
    
    hold on
    
    %% plot_bathymetry
    %m_plot_bathymetry2('mac',[-25 -50 -100 -1000])%% plot the bathymetry

    %bathy=load ('/Users/hroarty/data/bathymetry/marcoos_30second_ngdc.mat');
    bathy=load ('/Users/hroarty/data/bathymetry/eastcoast_4min.mat');
    ind2= bathy.depthi==99999;
    bathy.depthi(ind2)=NaN;
    bathylines=[ -50  -1000];
    
    [cs, h1] = contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
    clabel(cs,h1,'fontsize',8,'Color',[0.8 0.8 0.8]);
    set(h1,'LineColor',[0.8 0.8 0.8],'LineWidth',1)
    
    % m_map
% %     plotBasemap(lims(1:2),lims(3:4),coastFileName,'mercator','patch','k')
%     m_proj('lambert','long',lims(1:2),'lat',lims(3:4));
%     m_usercoast(conf.Plot.Coast,'patch','k');
%     m_grid('xticklabels',[],'yticklabels',[])
    
    % other method to plot coast
    coast = load(conf.Plot.Coast);
    coast2 = coast.ncst;
    e = plot(coast2(:,1), coast2(:,2), 'k', 'linewidth', 1);
    mapshow(coast2(:,1), coast2(:,2), 'DisplayType', 'polygon', 'facecolor', 'k')
    
    %% Generate and plot the range rings
     angular_coverage=C{7}(ii)-C{6}(ii);
     start_angle=C{6}(ii);
     lat=C{4}(ii);
     lon=C{3}(ii);
    
    
    [r_ring_x , r_ring_y , r_line_x , r_line_y] = HJR_generate_range_rings(rc_size, num_of_range_cells, angular_coverage, start_angle, radial_spacing, lat, lon);

    plot(r_ring_x , r_ring_y,'r-')
    plot(r_line_x , r_line_y,'r-')

    xlim(conf.Plot.lims(1:2));
    ylim(conf.Plot.lims(3:4));
    
    project_mercator;
    grid on
    box on
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',[])
    
    %% plot the political boundaries
%     hdls.boundaries=m_plot(boundaries(:,1),boundaries(:,2),'-w','linewidth',1);
    hdls.boundaries=plot(boundaries(:,1),boundaries(:,2),'-w','linewidth',1);
    
    % hdls.RadialSitesSR=m_plot(C{3}(SR),C{4}(SR),'o','markersize',6,'MarkerFaceColor','b','MarkerEdgeColor','k');
    % hdls.RadialSitesHR=m_plot(C{3}(HR),C{4}(HR),'o','markersize',6,'MarkerFaceColor','g','MarkerEdgeColor','k');
%     hdls.RadialSitesLR=m_plot(C{3}(ii),C{4}(ii),'o','markersize',12,'MarkerFaceColor','r','MarkerEdgeColor','k');
    hdls.RadialSitesLR=plot(C{3}(ii),C{4}(ii),'o','markersize',12,'MarkerFaceColor','r','MarkerEdgeColor','k');
    
    % timestamp(1,'plot_maracoos.m')
    % print(1,'-dpng','-r100','Site_Map_Mercator_Maracoos_' '.png')

    dim=[];
    crop=1;
    magn_factor=10;
    print_str=[conf.Plot.directory 'Site_Map_Mercator_Maracoos_' C{2}{ii} '.png'];
    fig_print(1,print_str,dim,crop,magn_factor)

    close all

end
