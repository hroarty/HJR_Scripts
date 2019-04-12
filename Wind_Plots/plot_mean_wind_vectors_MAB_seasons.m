%% This m script plots yearly mean wind vectors on a map of the MAB
%% This script was written by Hugh Roarty January 2016 

conf.NDBC.years=2007:2017;

%% Configuration settings for the map
conf.Plot.lims=[-77 -69 35 42];%ALL MAB
conf.Plot.coast='/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.Plot.boundaries=load('/Users/hroarty/data/political_boundaries/WDB2_global_political_boundaries.dat');
conf.Plot.bathylines=[ -50 -80 -200 -1000];
conf.Plot.wind_plot_scale=4;
conf.Plot.wind_scale=2;
conf.Plot.temporal_coverage=0.4;

conf.season.name={'Winter','Spring','Summer','Autumn'};
conf.season.months={[12 1 2],[3 4 5],[6 7 8],[9 10 11]};
conf.season.month_letter={'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'};

%% loop through each time frame to load the wind data and generate the plot
% for jj=1:length(conf.NDBC.years)-1
    for jj=1 % for a single plot


    %% read in the wind data
%     conf.NDBC.Sites={'44008', '44025','44009','44014'};
%     conf.NDBC.Sites={'44066'};
    
    conf.NDBC.Sites={'44004', '44005', '44008', '44009','44011',...
                    '44014','44017','44020','44025',...                    
                        '44027','44065','44066',...
                            'alsn6','brbn4','chlv2','ocim2'};

    conf.NDBC.t0 = datenum(conf.NDBC.years(jj),1,1);
% use this line for making yearly plots
%     conf.NDBC.tN = datenum(conf.NDBC.years(jj+1),1,1);
% use this line for making a single plot
    conf.NDBC.tN = datenum(conf.NDBC.years(end),1,1);
    

    for ii=1:length(conf.NDBC.Sites)

        buoyData{ii}=load_buoy(conf.NDBC.t0,conf.NDBC.tN,conf.NDBC.Sites{ii});
        buoyData{ii}.time2.vec=datevec(buoyData{ii}.t);
        buoyData{ii}.time2.max=max(buoyData{ii}.t);
        buoyData{ii}.time2.min=min(buoyData{ii}.t);

    end
    
    % loop through each of the seasons
    
    for kk=1:length(conf.season.name)

   

    for ii=1:length(conf.NDBC.Sites)
        
        %% find the indices of the rows that match the months of the particular season
           ind=buoyData{ii}.time2.vec(:,2)==conf.season.months{kk}(1) |...
           buoyData{ii}.time2.vec(:,2)==conf.season.months{kk}(2) |...
           buoyData{ii}.time2.vec(:,2)==conf.season.months{kk}(3);

        lon_buoy(ii)=buoyData{ii}.lon;
        lat_buoy(ii)=buoyData{ii}.lat;
        
        u(ii)=nanmean(buoyData{ii}.u(ind));
        v(ii)=nanmean(buoyData{ii}.v(ind));
        
        %% if there is less than the required temporal coverage convert the 
        %% mean to a NaN
        % use ind to know if data exists
        if sum(ind)<conf.Plot.temporal_coverage*8760*(length(conf.NDBC.years)-1)*0.25%0.25 for seasons
           u(ii)=NaN;
           v(ii)=NaN;
        end
        
        clear ind
    end

%% Create the basemap
hold on
plotBasemap(conf.Plot.lims(1:2),conf.Plot.lims(3:4),conf.Plot.coast,'mercator','patch',[240,230,140]./255);

%% read in the bathymetry and replace fill values with NaNs
bathy=load ('/Users/hroarty/data/bathymetry/eastcoast_4min.mat');
ind2= bathy.depthi==99999;
bathy.depthi(ind2)=NaN;
%% Plot the bathymetry
[cs, h1] = m_contour(bathy.loni,bathy.lati, bathy.depthi,conf.Plot.bathylines);
clabel(cs,h1,'fontsize',8,'Color',[0.8 0.8 0.8]);
set(h1,'LineColor',[0.8 0.8 0.8])


%% plot the political boundaries
hdls.boundaries=m_plot(conf.Plot.boundaries(:,1),conf.Plot.boundaries(:,2),'-k','linewidth',1);

%% Plot the wind scale on the map
m_quiver(-71,36.9,conf.Plot.wind_scale/conf.Plot.wind_plot_scale,0/conf.Plot.wind_plot_scale,0,'r','linewidth',2);
m_text(-71,37, [num2str(conf.Plot.wind_scale) 'm/s'],'verticalalignment','bottom');



%% Plot the wind vectors on the map
w=m_quiver(lon_buoy,lat_buoy,u/conf.Plot.wind_plot_scale,v/conf.Plot.wind_plot_scale,0,'r','linewidth',2);

[dir,speed]=uv2compass(u,v);
% convert from oceanogrpahic to meteorological
dir=angle360(dir,180);
disp (conf.season.name{kk})
% dir, speed, conf.NDBC.Sites

for ii=1:length(conf.NDBC.Sites)
string=sprintf('%s %2.3g %2.3g',conf.NDBC.Sites{ii},dir(ii),speed(ii));
disp(string)
end
string=sprintf('Mean Direction:%2.3g Speed:%2.3g',nanmean(dir),nanmean(speed));
disp(string)
string=sprintf('STD Direction:%2.3g Speed:%2.3g',nanstd(dir),nanstd(speed));
disp(string)

% h= title(['MAB Wind Vectors Map from ' num2str(conf.NDBC.years(jj))] ,'FontWeight','bold','FontSize',14);
h= title({[ conf.season.name{kk} '  ' num2str(conf.NDBC.years(jj)) ' to ' num2str(conf.NDBC.years(end)-1)]} ,'FontWeight','bold','FontSize',18);

%% Plot the HFR Coverage

% input_file = ['/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/RU_5MHz_7yearMean_' conf.season.name{kk} '_2007.nc'];
% input_file = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/RU_5MHz_7yearcomposite_2007_01_01_0000.nc'; 

% use this for the seasonal means, 10 year
input_file =['/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/20170424_Decadal_Means/renamed/RU_5MHz_MARA_' conf.season.name{kk} '_mean.nc'];

% use this for the annual means, 10 year
% input_file =['/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20150508_Smith_NC_Files_means/20170424_Decadal_Means/renamed/RU_5MHz_MARA_decadal_mean.nc']


%% extract the lat and lon from the nc file
lat = ncread(input_file,'lat');
lon = ncread(input_file,'lon');

%% make the lon and lat data into a grid
[TUV.LON,TUV.LAT]=meshgrid(lon,lat);

%% transpose the matrices
TUV.LON=TUV.LON';
TUV.LAT=TUV.LAT';

%% read the coverage at each grid point
coverage = ncread(input_file,'perCov');

%% replace the fill values of -999 with NaN
logInd=coverage==-999;
coverage(logInd)=NaN;

%% the coverage is a ratio, multiply by 100 to get percent
coverage=coverage*100;

X=TUV.LON;
Y=TUV.LAT;
Z=coverage;

%% contour the coverage data
% [cs,h2]=m_contour(X,Y,Z,0:10:100);
% [cs,h2]=m_contour(X,Y,Z,[60 60]);
% set(h2,'LineWidth',3,'Color','k')
% clabel(cs,h2,'fontsize',6);


% timestamp(1,'plot_mean_wind_vectors_MAB_seasons.m')

 %% create the output directory and filename
output_directory = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/';
% output_filename = ['MAB_Wind_Vectors_'  num2str(conf.NDBC.years(jj)) '.png'];
output_filename = ['MAB_Wind_Vectors_'  conf.season.name{kk} '_' num2str(conf.NDBC.years(jj)) '_' num2str(conf.NDBC.years(end)-1) '.png'];

%% print the image
print(1, '-dpng', '-r200', [output_directory output_filename]);

% dim=[];
% crop=1;
% magn_factor=10;
% print_str=[output_directory output_filename];
% fig_print(1,print_str,dim,crop,magn_factor)


close all

    end
    end


