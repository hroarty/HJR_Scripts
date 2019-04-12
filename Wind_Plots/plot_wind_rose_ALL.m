%% This m script plots yearly mean wind vectors on a map of the MAB
%% This script was written by Hugh Roarty January 2016 

conf.NDBC.years=2007:2017;

%% Configuration settings for the map
conf.Plot.lims=[-77 -65 34 43];%ALL MAB
conf.Plot.coast='/Users/hroarty/data/coast_files/MARA_coast.mat';
conf.Plot.boundaries=load('/Users/hroarty/data/political_boundaries/WDB2_global_political_boundaries.dat');
conf.Plot.bathylines=[ -50 -80 -200 -1000];
conf.Plot.wind_plot_scale=4;
conf.Plot.wind_scale=2;
conf.Plot.temporal_coverage=0.4;

conf.season.name={'Winter','Spring','Summer','Autumn'};
conf.season.months={[12 1 2],[3 4 5],[6 7 8],[9 10 11]};
conf.season.month_letter={'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'};
    
% conf.NDBC.Sites={'44004', '44005', '44008', '44009','44011',...
%                 '44014','44017','44020','44025',...                    
%                 '44027','44065','44066',...
%                 'alsn6','brbn4','chlv2','ocim2'};

conf.NDBC.Sites={ '44008', '44009','44014','44025'};

conf.NDBC.t0 = datenum(conf.NDBC.years(1),1,1);
conf.NDBC.tN = datenum(conf.NDBC.years(end),1,1);
    

for ii=1:length(conf.NDBC.Sites)

    buoyData{ii}=load_buoy(conf.NDBC.t0,conf.NDBC.tN,conf.NDBC.Sites{ii});
    buoyData{ii}.time2.vec=datevec(buoyData{ii}.time);
    buoyData{ii}.time2.max=max(buoyData{ii}.time);
    buoyData{ii}.time2.min=min(buoyData{ii}.time);

end
    
    % loop through each of the seasons
    


   

    for ii=1:length(conf.NDBC.Sites)
              
       wind_rose(buoyData{ii}.wfdir,buoyData{ii}.wspd,'dtype','meteo','n',12,'di',0:5:30,'ci',[5 10 15 20])
       
       h= title([buoyData{ii}.name ' Wind Rose:  ' num2str(conf.NDBC.years(1)) ' to ' num2str(conf.NDBC.years(end)-1)] ,'FontWeight','bold','FontSize',14);

        timestamp(1,'plot_wind_rose_seasons.m')

         %% create the output directory and filename
        output_directory = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/';
        % output_filename = ['MAB_Wind_Vectors_'  num2str(conf.NDBC.years(jj)) '.png'];
        output_filename = [buoyData{ii}.name '_Wind_Rose_ALL_' num2str(conf.NDBC.years(1)) '_' num2str(conf.NDBC.years(end)-1) '.png'];

        %% print the image
        print(1, '-dpng', '-r200', [output_directory output_filename]);
        
        close all
        
        clear ind
   
    end





