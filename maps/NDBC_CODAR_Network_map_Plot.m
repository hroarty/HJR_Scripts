clear all
close all

lims=[-77 -69 35 42];
% lims=[-76 -68 38 42];
coastFileName = '/Users/roarty/Documents/GitHub/HJR_Scripts/data/coast_files/MARA_coast.mat';
conf.Totals.MaskFile='/Users/roarty/data/mask_files/MARACOOS_6kmMask.txt';

hold on
%figure
plotBasemap(lims(1:2),lims(3:4),coastFileName,'mercator','patch',[240,230,140]./255);

%% -------------------------------------------------
%% Plot location of sites
try
%% read in the MARACOOS sites
dir='/Users/roarty/Documents/GitHub/HJR_Scripts/data/';
file='maracoos_codar_sites_2018.txt';
[C]=read_in_maracoos_sites(dir,file);

site_num=1:17;%% 5 MHz Network
%site_num=[16 17 18 19 20 21 22];%% 13 MHz Network

%% plot the location of the  sites
for ii=1:length(site_num)
    hdls.RadialSites=m_plot(C{3}(site_num(ii)),C{4}(site_num(ii)),'^r','markersize',8,'linewidth',2);
    %% print the site name
    %m_text(C{3}(site_num(ii))-0.5,C{4}(site_num(ii)),C{2}(site_num(ii)),'FontSize',20,'FontWeight','bold','Color','r');
    %% print the site number
    %m_text(C{3}(site_num(ii)),C{4}(site_num(ii)),num2str(ii),'FontSize',18,'FontWeight','bold','Color','r');
end

catch
end

%% Plot location of NDBC Buoys
%% read in the NDBC sites
dir2='/Users/roarty/Documents/GitHub/HJR_Scripts/data/';
file2='NDBC_sites.csv';
[G]=read_in_ndbc_sites(dir2,file2);

%% plot the location of the NDBC sites
site_num=[3 4 6 7 8 10 11 12 16];
for ii=1:length(site_num)
    hdls.NDBCSites=m_plot(G{3}(site_num(ii)),G{4}(site_num(ii)),'sb','markersize',8,'linewidth',2);
    hdls.NDBC_Names=m_text(G{3}(site_num(ii))+0.2,G{4}(site_num(ii))+0.1,G{2}(site_num(ii)),'FontWeight','bold','Color','b');
end

%% plot the location of 44025 so it does not conflict with 44065
hdls.NDBCSites=m_plot(G{3}(9),G{4}(9),'sb','markersize',8,'linewidth',2);
hdls.NDBC_Names=m_text(G{3}(9)+0.2,G{4}(9)+0.0,G{2}(9),'FontWeight','bold','Color','b');

%% plot the location of ocim2 so it does not conflict with 44009
hdls.NDBCSites=m_plot(G{3}(17),G{4}(17),'sb','markersize',8,'linewidth',2);
hdls.NDBC_Names=m_text(G{3}(17)+0.2,G{4}(17)-0.2,G{2}(17),'FontWeight','bold','Color','b');


%% load the political boundaries file
boundaries=load('/Users/roarty/Documents/GitHub/HJR_Scripts/data/political_boundaries/WDB2_global_political_boundaries.dat');

%% plot the location of the sites within the bounding box
%hdls.RadialSites=m_plot(sites{1}(in),sites{2}(in),'^r','markersize',8,'linewidth',2);

%% plot the political boundaries
hdls.boundaries=m_plot(boundaries(:,1),boundaries(:,2),'-k','linewidth',1);


%% plot_bathymetry
%m_plot_bathymetry2('mac',[-25 -50 -100 -500])%% plot the bathymetry

%bathy=load ('/Users/hroarty/data/bathymetry/marcoos_15second_ngdc.mat');
bathy=load ('/Users/roarty/Documents/GitHub/HJR_Scripts/data/bathymetry/eastcoast_4min.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
bathylines=[ -50 -80 -200 -1000];
% bathylines=[ -30 -70 -100 -1000];

[cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
% clabel(cs,h1,'fontsize',8,'Color',[0.8 0.8 0.8]);
clabel(cs,h1,'fontsize',8,'Color',[0.8 0.8 0.8]);
set(h1,'LineColor',[0.8 0.8 0.8])


%% plot the shipping lanes
% plot_shipping_lanes_m_map(gcf)

%% Plot the HFR Coverage using Mike Smith nc file
% 
% % input_file = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/RU_5MHz_7yearcomposite_2007_01_01_0000.nc'; 
% input_file ='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/20170424_Decadal_Means/renamed/RU_5MHz_MARA_decadal_mean.nc';
% 
% %% extract the lat and lon from the nc file
% lat = ncread(input_file,'lat');
% lon = ncread(input_file,'lon');
% 
% %% make the lon and lat data into a grid
% [TUV.LON,TUV.LAT]=meshgrid(lon,lat);
% 
% %% transpose the matrices
% TUV.LON=TUV.LON';
% TUV.LAT=TUV.LAT';
% 
% %% read the coverage at each grid point
% coverage = ncread(input_file,'perCov');
% 
% %% replace the fill values of -999 with NaN
% logInd=coverage==-999;
% coverage(logInd)=NaN;
% 
% %% the coverage is a ratio, multiply by 100 to get percent
% coverage=coverage*100;
% 
% X=TUV.LON;
% Y=TUV.LAT;
% Z=coverage;
% 
% %% contour the coverage data
% % [cs,h2]=m_contour(X,Y,Z,0:10:100);
% [cs,h2]=m_contour(X,Y,Z,[60 60]);
% set(h2,'LineWidth',3,'Color','k')
% clabel(cs,h2,'fontsize',6);

% plot the coverage using Laura's file
input_file ='/Users/roarty/COOL/01_CODAR/MARACOOS/20131211_MAB_Currents/decadal_means.nc';
% var.u= [years.seasons{ii} '_u_mean'];
% var.v= [years.seasons{ii} '_v_mean'];
var.u= 'u_mean';
var.v= 'v_mean';
var.t=datenum(2007,12,1);

%% load the current data
[TUV]=convert_Nazzaro_NC_to_TUVgrid(input_file,var );

[TUV,I]=maskTotals(TUV,conf.Totals.MaskFile,false);

% U=TUV.U(:);
ind=abs(TUV.U)>0;

LonLat=TUV.LonLat(ind,:);

k = boundary(LonLat(:,1),LonLat(:,2),0.95);
hold on;
m_plot(LonLat(k,1),LonLat(k,2),'k','LineWidth',2);

% m_plot(LonLat(:,1),LonLat(:,2),'r.')


% title('MARACOOS HF Radar Network','FontWeight','bold','FontSize',14)


% timestamp(1,'NDBC_CODAR_Network_map_Plot.m')

output_directory = '/Users/roarty/COOL/01_CODAR/MARACOOS/20131211_MAB_Currents/Paper_Figures/02_FINAL/Figure_01/';
output_filename='CODAR_05_Map.png';

% set(gca, 'LooseInset', get(gca, 'TightInset'))

% print(1,'-dpng','-r400','CODAR_05_Map.png')
print(1, '-dpng', '-r300', [output_directory output_filename]);
