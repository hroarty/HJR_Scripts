
clc
clear all
close all
 
tic



 conf.NDBC.years=2007:2016;

conf.NDBC.t0=datenum(conf.NDBC.years(1),1,1);
conf.NDBC.tN=datenum(conf.NDBC.years(end),12,31,23,0,0);

% build a time vector that covers the entire time period
conf.dtime=conf.NDBC.t0:1/24:conf.NDBC.tN;
conf.dvec=datevec(conf.dtime);

conf.season.name={'winter','spring','summer','fall'};
conf.season.months={[12 1 2],[3 4 5],[6 7 8],[9 10 11]};

x_tick_label=[];
x_tick=datenum(conf.NDBC.years,1,1);

conf.Plot.script_path='/Users/hroarty/Documents/MATLAB/HJR_Scripts/Wind_Plots/';
conf.Plot.script_name='plot_NDBC_climatology.m';
conf.Data.Institution='Rutgers University';
conf.Data.Contact='Hugh Roarty hroarty@marine.rutgers.edu';
conf.Data.Info='This data file is seasonal mean of data from an NDBC buoy';




%% loop through each time frame to load the wind data and generate the plot
for jj=1


    %% read in the wind data
    
%     conf.NDBC.Sites={'44004', '44005', '44008', '44009','44011',...
%                     '44014','44017','44020','44025',...                    
%                         '44027','44065','44066',...
%                             'alsn6','brbn4','chlv2','ocim2'};
                        
    conf.NDBC.Sites={'44008', '44025','44009','44014'};

%    conf.NDBC.Sites={'44008'};
   
%     conf.NDBC.measurement_str={'Air Temperature (^{\circ}C)'};
%     conf.NDBC.measurement_var={'atemp'};
%     conf.NDBC.standard_name={'air_temperature'};
%     conf.Save.directory='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/atmp_Climatology/';
%     measurement= 'atemp';%conf.NDBC.measurement_var(1);
    
    conf.NDBC.measurement_str={'Wind Speed (m/s)'};
    conf.NDBC.measurement_var={'wspd'};
    conf.NDBC.standard_name={'wind_speed'};
    conf.Save.directory='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/20170504_Climatology_wspd/';
    measurement= 'wspd';%conf.NDBC.measurement_var(1);
    
%     conf.NDBC.measurement_str={'Water Temperature (^{\circ}C)'};
%     conf.NDBC.measurement_var={'wtemp'};
%     conf.NDBC.standard_name={'sea_surface_temperature'};
%     conf.Save.directory='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/SST_Climatology/';
%     measurement= 'wtemp';%conf.NDBC.measurement_var(1);

    %% loop through each of the data sources
    for ii=1:length(conf.NDBC.Sites)

        buoyData{ii}=load_buoy(conf.NDBC.t0,conf.NDBC.tN,conf.NDBC.Sites{ii});
        
        time.vec=datevec(buoyData{ii}.t);
        time.max(ii)=max(time.vec(:,1));
        time.min(ii)=min(time.vec(:,1));
        
%         %% Loop through each month then year to calculate the mean
%        for kk=1:12
%         
%         for jj=1:length(conf.NDBC.years)
%                   
%              ind=time_vec(:,1)==conf.NDBC.years(jj) & time.vec(:,2)==kk; 
%                
%                
%                var.mean=nanmean(buoyData{ii}.(measurement)(ind));
%                var.std=nanstd(buoyData{ii}.(measurement)(ind));
%                var.N=sum(~isnan(buoyData{ii}.(measurement)(ind)));
%         
%                   string=sprintf('%s %u %02d %2.3g %2.3g %2.3g',conf.NDBC.Sites{ii},conf.NDBC.years(jj),kk,var.mean, var.std, var.N);
%                   disp(string)
%            end
%        end
       
       %% Loop through each season
       for kk=1:length(conf.season.name)
           
           %% find the indices of the rows that match the months of the particular season
           ind=time.vec(:,2)==conf.season.months{kk}(1) |...
               time.vec(:,2)==conf.season.months{kk}(2) |...
               time.vec(:,2)==conf.season.months{kk}(3);
           
           % find the indices of the rows that match the months of the particular season
           % for the time period
           ind2=conf.dvec(:,2)==conf.season.months{kk}(1) |...
               conf.dvec(:,2)==conf.season.months{kk}(2) |...
               conf.dvec(:,2)==conf.season.months{kk}(3);
           
           %% calculate the mean and std of the data based on the indices
           var.mean(kk)=nanmean(buoyData{ii}.(measurement)(ind));
           var.std(kk)=nanstd(buoyData{ii}.(measurement)(ind));
           var.N(kk)=sum(~isnan(buoyData{ii}.(measurement)(ind)));
           var.Npercent(kk)=var.N(kk)/sum(ind2);
           var.error_bar(kk)=var.std(kk)*1.96./sqrt(var.N(kk));
           
           string=sprintf('%s %s %2.3g %2.3g %2.3g %2.3g',conf.NDBC.Sites{ii},conf.season.name{kk},var.mean(kk), var.std(kk), var.N(kk),var.Npercent(kk));
           disp(string)
       

       end
       
       %% plot the climatology for the particular buoy
        hold on
        plot(var.mean,'LineWidth',2)
        %plot(dtime2_daily_mean,vr_daily_mean,'bs')
        %errorbar(1:4,var.mean,var.error_bar,'LineWidth',2)
        
        %% add metadata to mat file that will be saved
        var.name=buoyData{ii}.name;
        var.variable=conf.NDBC.standard_name{1};
        var.season=conf.season.name;
        var.MetaData.Script=conf.Plot.script_name;
        var.MetaData.Institution=conf.Data.Institution;
        var.MetaData.Contact=conf.Data.Contact;
        var.MetaData.Information=conf.Data.Info;
        
        %% save the climatology data in a mat file
        save([conf.Save.directory 'NDBC_' buoyData{ii}.name '_Seasonal_Climatology.mat'], '-struct', 'var');

    end
    
    %% format the figure
    xlim([0.5 4.5])
    set(gca,'xtick',[1 2 3 4])
    set(gca,'xticklabel',conf.season.name)
    box on
    grid on
    ylabel(conf.NDBC.measurement_str)
    legend(conf.NDBC.Sites')
    title([conf.NDBC.measurement_str{1} ' Climatology from MAB NDBC Buoys ' ...
        num2str(min(time.min)) ' to ' num2str(max(time.max)) ])
%    

    

     timestamp(1,conf.Plot.script_name)

     %% create the output directory and filename
    conf.plot.directory = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/';
    conf.plot.filename = ['MAB_Climatology_' measurement '_'  num2str(min(time.min)) '_' num2str(max(time.max)) '.png'];

    %% print the image
     print(1, '-dpng', '-r400', [conf.plot.directory conf.plot.filename]);
    
    

end


toc
