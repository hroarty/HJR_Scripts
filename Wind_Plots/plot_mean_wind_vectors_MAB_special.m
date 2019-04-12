%% This m script plots yearly mean wind vectors on a map of the MAB
%% This script was written by Hugh Roarty January 2016 

conf.NDBC.years=2007:2017;

%% Configuration settings for the map
% conf.Plot.lims=[-77 -65 34 43];%ALL MAB
conf.Plot.lims=[-76 -74 38 40];%ALL MAB
conf.Plot.ScaleLoc=[-75 39+40/60];
conf.Plot.coast='/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.Plot.boundaries=load('/Users/hroarty/data/political_boundaries/WDB2_global_political_boundaries.dat');
conf.Plot.bathylines=[ -50 -80 -200 -1000];
conf.Plot.wind_plot_scale=4;
conf.Plot.wind_scale=2;
conf.Plot.temporal_coverage=0.4;

%% loop through each time frame to load the wind data and generate the plot
% for jj=1:length(conf.NDBC.years)-1
    for jj=1 % use this to make a single plot for all the years


    %% read in the wind data
    %conf.NDBC.Sites={'44008', '44009','44025','44065' , '44014'};
    conf.NDBC.Sites={'44009','ocim2'};
    
%     conf.NDBC.Sites={'44004', '44005', '44008', '44009','44011',...
%                     '44014','44017','44020','44025',...                    
%                         '44027','44065','44066',...
%                             'alsn6','brbn4','chlv2','ocim2'};

%     conf.NDBC.t0 = datenum(conf.NDBC.years(jj),1,1);
% % use this line for making yearly plots
% %     conf.NDBC.tN = datenum(conf.NDBC.years(jj+1),1,1);
% % use this line for making a single plot
%     conf.NDBC.tN = datenum(conf.NDBC.years(end),1,1);
    
    % custom date
     conf.NDBC.t0 = datenum(2014,6,20);
     conf.NDBC.tN = datenum(2014,7,28);
     
     time_span_hr=(conf.NDBC.tN-conf.NDBC.t0)*24;
    

    for ii=1:length(conf.NDBC.Sites)

        buoyData{ii}=load_buoy(conf.NDBC.t0,conf.NDBC.tN,conf.NDBC.Sites{ii});

    end

    %% average the data

    for ii=1:length(conf.NDBC.Sites)

        lon_buoy(ii)=buoyData{ii}.lon;
        lat_buoy(ii)=buoyData{ii}.lat;
        
        u(ii)=nanmean(buoyData{ii}.u);
        v(ii)=nanmean(buoyData{ii}.v);
        
        %% if there is less than the required temporal coverage convert the 
        %% mean to a NaN
        % use this if statement for an annual mean plot
%         if sum(~isnan(buoyData{ii}.wspd))<conf.Plot.temporal_coverage*8760
        % use this if statement for a 7 year mean plot
        if sum(~isnan(buoyData{ii}.wspd))<conf.Plot.temporal_coverage*time_span_hr
           u(ii)=NaN;
           v(ii)=NaN;
        end
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
% m_quiver(conf.Plot.ScaleLoc(1),conf.Plot.ScaleLoc(2),conf.Plot.wind_scale/conf.Plot.wind_plot_scale,0/conf.Plot.wind_plot_scale,0,'r','linewidth',2);
% m_text(conf.Plot.ScaleLoc(1),conf.Plot.ScaleLoc(2)+0.1, [num2str(conf.Plot.wind_scale) 'm/s'],'verticalalignment','bottom','color','k');



%% Plot the wind vectors on the map
% w=m_quiver(lon_buoy,lat_buoy,u/conf.Plot.wind_plot_scale,v/conf.Plot.wind_plot_scale,0,'r','linewidth',2);


 h= title('Study Area' ,'FontWeight','bold','FontSize',14);
% h= title(['Wind Vectors from ' datestr(conf.NDBC.t0,'yyyymmdd') ' to ' datestr(conf.NDBC.tN,'yyyymmdd')] ,'FontWeight','bold','FontSize',14);


timestamp(1,'plot_mean_wind_vectors_MAB_special.m')



 %% create the output directory and filename
% output_directory = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/';
output_directory = '/Users/hroarty/COOL/GRACE/';
% use this for yearly maps
% output_filename = ['MAB_Wind_Vectors_'  num2str(conf.NDBC.years(jj))'.png'];
output_filename = ['MAB_Wind_Vectors_'  datestr(conf.NDBC.t0,'yyyymmdd') '_' datestr(conf.NDBC.tN,'yyyymmdd') '.png'];

%% print the image
print(1, '-dpng', '-r200', [output_directory output_filename]);


close all

end


