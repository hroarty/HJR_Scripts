clear all
close all

lims=[-74.5 -71 39 41.25]; % zoom out all of NJ
% lims=[-74-15/60 -73-30/60 39+30/60 40+15/60]; % zoom in on SPRK
% lims=[-74-20/60 -73-30/60 39+50/60 40+30/60]; % zoom in on BRAD
% lims=[-74-20/60 -73-30/60 39+40/60 40+20/60]; % zoom in on SPRK
% lims=[-74-30/60 -73-40/60 39+20/60 40+00/60]; % zoom in on BRNT
% lims=[-74-16/60 -73-56/60 40+24/60 40+40/60]; % zoom in on PORT

coastFileName = '/Users/roarty/Documents/GitHub/HJR_Scripts/data/coast_files/MARA_coast.mat';

for jj=4:10

hold on
%figure
plotBasemap(lims(1:2),lims(3:4),coastFileName,'mercator','patch',[240,230,140]./255);

%% Load the NYHOPS info and plot
% f='http://colossus.dl.stevens-tech.edu:8080/thredds/dodsC/fmrc/NYBight/NYHOPS_Forecast_Collection_for_the_New_York_Bight_best.ncd';
% lat=ncread(f,'lat');
% lon=ncread(f,'lon');
% m_plot(lon,lat,'.','MarkerSize',6,'Color',[0 0.49804 0])

%% -------------------------------------------------
%% Plot location of sites
try
%% read in the MARACOOS sites
dir='/Users/roarty/Documents/GitHub/HJR_Scripts/data/';
file='maracoos_codar_sites_2018.txt';
[C]=read_in_maracoos_sites(dir,file);

% site_num=18:24;%% 13 MHz Network
site_num=4:10;%% 13 MHz Network
% site_num=[19 20 21 29 30];%% 13 MHz Network
% site_num=30;%% 13 MHz Network
% site_num=[09 19 21 22];%% Tsunami Network

%% plot the location of the 13 MHz sites

spacing1=0.1;
spacing2=0.2;

column=18;
num=2;% add num to get NYHOPS grid point closest to 44091

for ii=1:length(site_num)
    hdls.RadialSites=m_plot(C{3}(site_num(ii)),C{4}(site_num(ii)),'^r','markersize',8,'linewidth',2);
    m_text(C{3}(site_num(ii))-spacing2,C{4}(site_num(ii))+spacing1,C{2}(site_num(ii)),'FontSize',12,'FontWeight','bold','Color','r');
end

catch
end

%% Plot location of NDBC Buoys
%% read in the NDBC sites
dir2='/Users/roarty/Documents/GitHub/HJR_Scripts/data/';
file2='NDBC_sites.txt';
[G]=read_in_maracoos_sites(dir2,file2);

%% plot the location of the NDBC sites

% sites=[7 8 9];
% for ii=sites%length(G{1})
%     hdls.NDBCSites=m_plot(G{3}(ii),G{4}(ii),'sb','markersize',8,'linewidth',2);
%     hdls.NDBC_Names=m_text(G{3}(ii)+spacing1*1.5,G{4}(ii),G{2}(ii),'FontWeight','bold','Color','b');
% end

%% load the political boundaries file
boundaries=load('/Users/roarty/Documents/GitHub/HJR_Scripts/data/political_boundaries/WDB2_global_political_boundaries.dat');

%% plot the location of the sites within the bounding box
%hdls.RadialSites=m_plot(sites{1}(in),sites{2}(in),'^r','markersize',8,'linewidth',2);

%% plot the political boundaries
hdls.boundaries=m_plot(boundaries(:,1),boundaries(:,2),'-k','linewidth',1);


%% plot_bathymetry
%m_plot_bathymetry2('mac',[-25 -50 -100 -500])%% plot the bathymetry

% bathy=load ('/Users/hroarty/data/bathymetry/marcoos_15second_ngdc.mat');
bathy=load ('/Users/roarty/Documents/GitHub/HJR_Scripts/data/bathymetry/eastcoast_4min.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
% bathylines=[ -5 -10:-5:-100]; % bathy lines for nj shelf
% bathylines=[ -2:-4:-20];% bathy lines for ny harbor
bathylines=[ -6 -15 -30 -50 -80 -200];

[cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
clabel(cs,h1,'fontsize',8);
set(h1,'LineColor','k')

%% plot the 30 m bathymetry contour
% [cs2, h2] = m_contour(bathy.loni,bathy.lati, bathy.depthi,[-30 -30]);
% set(h2,'LineColor','r','LineWidth',3)

%% Define the parameters for the range and angular bins.  Generate the data
%% for the rings
%% PORT start angle 270
%% SILD start angle 70

rc_size=6; % km
num_of_range_cells=30;
radial_spacing=5; % degrees

angular_coverage=C{7}(jj)-C{6}(jj); 
start_angle=C{6}(jj);%% 

row=jj;% the row for BRMR
lat2=C{4}(row);
lon2=C{3}(row);

%% Generate and plot the range rings
[r_ring_x , r_ring_y , r_line_x , r_line_y] = HJR_generate_range_rings(rc_size, num_of_range_cells, angular_coverage, start_angle, radial_spacing, lat2, lon2);
m_plot(r_ring_x , r_ring_y,'r-')% plot the range bins
%m_plot(r_line_x , r_line_y,'k-')% plot the angular bins

%% plot the shipping lanes
plot_shipping_lanes_m_map(gcf)

%% Plot the best coverage area for Erick Fredj's gap filling product
%% 5 MHz coverage
% conf.OSN.BestCoverageFile='/Users/hroarty/Documents/MATLAB/HFR_RealTime/totals_toolbox/toolbox_erick_fredj/MARACOOS_HFR_cvrg.txt'
%% 13 MHz coverage
% conf.OSN.BestCoverageFile='/Volumes/hroarty/codar/MARACOOS/Radials2Totals/totals_toolbox/toolbox_erick_fredj/BPU_HFR_cvrg.txt';
% BCF=load(conf.OSN.BestCoverageFile);
% hdls.boundaries=m_plot(BCF(:,1),BCF(:,2),'-k','linewidth',2);

%% Plot the offshore wind lease area
shape_dir       = '/Users/roarty/Documents/GitHub/HJR_Scripts/data/shape_files/NY_Call_Areas_4_4_2018/';
S1 = m_shaperead([shape_dir 'NY_Call_Areas_4_4_2018']);

for kk=1:length(S1.ncst)
    h1=m_line(S1.ncst{kk}(:,1),S1.ncst{kk}(:,2));
end

%% Load BOEM call area
% load(boemcall)

% boem_lon = X2013_boem_osw_call_area(:,2);
% boem_lat = X2013_boem_osw_call_area(:,4);
% 
% q = m_plot(boem_lon(1:end-5),boem_lat(1:end-5));                      %BOEM Call Area
% set(q,'Color','red','LineWidth',.9)
% s = m_plot(boem_lon(end-4:end),boem_lat(end-4:end));
% set(s,'Color','red','LineWidth',.9)


%% Add title and timestamp to the figure
title('HFR & NY Call Area','FontWeight','bold','FontSize',14)

conf.Plot.Filenname=['BOEM_CODAR_map_Plot_' C{2}{jj} '.png'];
conf.Plot.script='BOEM_CODAR_map_Plot.m';
conf.Plot.print_path='/Users/roarty/COOL/01_CODAR/BPU/20180607_NY_Bight_Impact/20180720_Total_Impact/'


timestamp(1,[conf.Plot.Filenname ' / ' conf.Plot.script])

set(gca, 'LooseInset', get(gca, 'TightInset'))

%% print the figure
print(1,'-dpng','-r400',conf.Plot.Filenname)

close all

end
