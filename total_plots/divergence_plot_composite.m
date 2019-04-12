tic

clear all; close all; 

%% This m script was written to read in the yearly netcdf files that Mike 
%% Smith created at
%% /home/michaesm/codar/codar_means/yearly_means

%% -----------------------------------------------------------
%% Declare the time over which you want to process the data
%% now is local time of the machine
    
%% specific period
% start_time = datenum(2012,1,1,00,0,2);
% end_time=datenum(2012,1,1,23,0,2);
% dtime = start_time:1/24:end_time;
% time_str=datestr(dtime,'yyyy_mm_dd_HHMM');

%% now minus 24 hours
% end_time   = floor(now*24-1)/24 + 2/(24*60*60); %add some slop to handle rounding
% start_time = end_time - 24/24;
% dtime = [start_time:1/24:end_time]; 

lims=[-77 -68 34 43];
coastFileName = '/Users/hroarty/data/coast_files/MARA_coast.mat';
hold on
%figure


%% load the political boundaries file
boundaries=load('/Users/hroarty/data/political_boundaries/WDB2_global_political_boundaries.dat');

%% plot the location of the sites within the bounding box
%hdls.RadialSites=m_plot(sites{1}(in),sites{2}(in),'^r','markersize',8,'linewidth',2);




%% plot_bathymetry
%bathy=load ('/Users/hroarty/data/bathymetry/marcoos_15second_ngdc.mat');
bathy=load ('/Users/hroarty/data/bathymetry/eastcoast_4min.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
bathylines=[ -50 -100 -1000 -5000];



years.num=2007:2013;


%for ii=1:length(years.num)
    




%% -----------------------------------------------------------
%% the location of the total data yearly files
input_file = ['/Volumes/michaesm/codar/codar_means/yearly_means/'...
    'RU_5MHz_7yearcomposite_2007_01_01_0000.nc'];


%% get the time from the file
 dtime = ncread(input_file,'time');


%% extract the lat and lon from the nc file
lat = ncread(input_file,'lat');
lon = ncread(input_file,'lon');

%% read the coverage at each grid point
coverage = ncread(input_file,'perCov');

%% replace the fill values of -999 with NaN
logInd=coverage==-999;
coverage(logInd)=NaN;
coverage=coverage';

% %% read the divergence at each grid point
% div=ncread(input_file,'div');
% 
% %% replace the fill values of -999 with NaN
% logInd2=div==-999;
% div(logInd2)=NaN;
% div=div';

[lon,lat,u,v,div,vor]=divergence('netcdf','ncfile',input_file,'adddivergence',false,'addvorticity',false,'maxerror',nan); 
div=div';

%% create a new variable with lon lat and coverage
[LON LAT]=meshgrid(lon,lat);

m_proj('mercator','long',lims(1:2),'lat',lims(3:4));

%% call m_pcolor before plotbasemap because shading will be messed up if you 
%% call plotbasemap first
m_pcolor(LON,LAT,div)
shading interp

%colormap_blue_red_hjr
M=load('/Users/hroarty/Documents/MATLAB/color_maps/redblue.mat');
%M=flipud(M);
colormap(M.redblue);
caxis([-.2 .2])

%% Add a colorbar
cax = colorbar;
set(cax,'ylim',[-.2 .2],'ytick',[-0.2:0.1:0.2],'fontsize',14,'fontweight','bold')

    %% Plot the basemap
    

    plotBasemap(lims(1:2),lims(3:4),coastFileName,'mercator','patch',[240,230,140]./255);
    %% plot the political boundaries
    hdls.boundaries=m_plot(boundaries(:,1),boundaries(:,2),'-k','linewidth',1);
    %% Plot the bathymetry
    [cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,bathylines);
    clabel(cs,h1,'fontsize',8);
    set(h1,'LineColor','k')

%% ------------------------------------------------------------------------
%% This section of the code separates and uses only the distance of 150 km
%% and the 15 meter isobath to define the coverage grid

%% load the table and eastCoat variables
%load ('/Volumes/boardwalk_home/lemus/MARCOOS/maps/bathy/orig_table.mat'); 


%% load hugh's file  this contains the lat and lon of the nc files, the associated 
%% depth and distance to shore of each grid point
hugh_file=load ('/Users/hroarty/data/grid_files/MARACOOS_Coverage_Grid.mat');

%% load the land mask
eastCoast=load('/Users/hroarty/data/mask_files/MARACOOS_6kmMask.txt');










% axis([0 100 0 100])
% axis square
% grid on
% box on

% title({'MARACOOS HF Radar Data Coverage from';datestr(dtime+datenum(2001,01,01),'yyyy') },'FontWeight','bold','FontSize',14)
% xlabel({''; 'Temporal Coverage (%)'},'FontSize',12)
% ylabel({'Spatial Coverage (%)'; ''},'FontSize',12)


timestamp(1,'/HJR_Scripts/total_plots/divergence_plot_composite.m')

%% create the output directory and filename
output_directory = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150505_7_year_Divergence/';
output_filename = ['MARACOOS_Divergence_' datestr(dtime+datenum(2001,01,01),'yyyy') '.png'];

%% print the image
print(1, '-dpng', '-r200', [output_directory output_filename]);

close all;

%end


%clear all;

toc
