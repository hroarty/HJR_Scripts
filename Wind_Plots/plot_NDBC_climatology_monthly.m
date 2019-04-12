%% 

clc
clear all
close all
 
tic



 conf.NDBC.years=1982:2014;

conf.NDBC.t0=datenum(conf.NDBC.years(1),1,1);
conf.NDBC.tN=datenum(conf.NDBC.years(end),12,31);

conf.season.name={'winter','spring','summer','fall'};
conf.season.months={[12 1 2],[3 4 5],[6 7 8],[9 10 11]};
conf.season.month_letter={'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'};

x_tick_label=[];
x_tick=datenum(conf.NDBC.years,1,1);

conf.Plot.script_path='/Users/hroarty/Documents/MATLAB/HJR_Scripts/Wind_Plots/';
conf.Plot.script_name='plot_NDBC_climatology_monthly.m';
conf.Data.Institution='Rutgers University';
conf.Data.Contact='Hugh Roarty hroarty@marine.rutgers.edu';
conf.Data.Info='This data file is monthly mean of data from an NDBC buoy';




%% loop through each time frame to load the wind data and generate the plot
for jj=4


    %% read in the wind data
    
%     conf.NDBC.Sites={'44004', '44005', '44008', '44009','44011',...
%                     '44014','44017','44020','44025',...                    
%                         '44027','44065','44066',...
%                             'alsn6','brbn4','chlv2','ocim2'};
                        
    conf.NDBC.Sites={'44008', '44025','44009','44014'};

   % conf.NDBC.Sites={'44008'};
   
    conf.NDBC.measurement_str={'Air Temperature (^{\circ}C)','Water Temperature (^{\circ}C)','Wind Speed (m/s)','Wind Direction From (deg CWN)'};
    conf.NDBC.measurement_var={'atmp','wtmp','wspd','wfdir'};
    conf.NDBC.standard_name={'air_temperature','sea_surface_temperature','wind_speed','wind_direction_from'};
    conf.Save.directory={'/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/Climatology_atmp/',...
                         '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/Climatology_wtmp/',...
                         '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/Climatology_wspd/',...
                         '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/Climatology_wfdir/'};

    

    %% loop through each of the data sources
    for ii=1:length(conf.NDBC.Sites)

        buoyData{ii}=load_buoy(conf.NDBC.t0,conf.NDBC.tN,conf.NDBC.Sites{ii});
        
        time.vec=datevec(buoyData{ii}.time);
        time.max(ii)=max(time.vec(:,1));
        time.min(ii)=min(time.vec(:,1));
        
        %% Loop through each month to calculate the mean
       for kk=1:12
                    
            ind=time.vec(:,2)==kk; 
            
            if jj==4
                               
                %% set the wind data equal to varible data
                data=buoyData{ii}.(conf.NDBC.measurement_var{jj})(ind);
                 %% remove the NaNs
                data(isnan(data)) = [];
                
                %var.mean(kk)=angles_mean(data);%% data will be in degrees
                %% convert from compass angles to math angles
                data=true2math(data);
                
                %% convert degrees to radians
                data=deg2rad(data);
                
                var.mean(kk)=math2true(rad2deg(circ_mean(data)));
                var.std(kk)=math2true(rad2deg(circ_std(data)));
                var.N(kk)=sum(data);
            
            else

            var.mean(kk)=nanmean(buoyData{ii}.(conf.NDBC.measurement_var{jj})(ind));
            var.std(kk)=nanstd(buoyData{ii}.(conf.NDBC.measurement_var{jj})(ind));
            var.N(kk)=sum(~isnan(buoyData{ii}.(conf.NDBC.measurement_var{jj})(ind)));
            end
            


            string=sprintf('%s %02d %2.3g %2.3g %2.3g',conf.NDBC.Sites{ii},kk,var.mean(kk), var.std(kk), var.N(kk));
            disp(string)
          
       end
       
%        %% Loop through each season
%        for kk=1:length(conf.season.name)
%            
%            %% find the indices of the rows that match the months of the particular season
%            ind=time.vec(:,2)==conf.season.months{kk}(1) |...
%                time.vec(:,2)==conf.season.months{kk}(2) |...
%                time.vec(:,2)==conf.season.months{kk}(3);
%            
%            %% calculate the mean and std of the data based on the indices
%            var.mean(kk)=nanmean(buoyData{ii}.(measurement)(ind));
%            var.std(kk)=nanstd(buoyData{ii}.(measurement)(ind));
%            var.N(kk)=sum(~isnan(buoyData{ii}.(measurement)(ind)));
%            var.error_bar(kk)=var.std(kk)*1.96./sqrt(var.N(kk));
%            
%            string=sprintf('%s %s %2.3g %2.3g %2.3g',conf.NDBC.Sites{ii},conf.season.name{kk},var.mean(kk), var.std(kk), var.N(kk));
%            disp(string)
%            
%            
%            
%            %clear ind var
%            
%             
% 
%        end
       
       %% plot the climatology for the particular buoy
        hold on
        plot(var.mean,'LineWidth',2)
        %plot(dtime2_daily_mean,vr_daily_mean,'bs')
        %errorbar(1:4,var.mean,var.error_bar,'LineWidth',2)
        
        %% add metadata to mat file that will be saved
        var.name=buoyData{ii}.name;
        var.variable=conf.NDBC.standard_name{jj};
        var.season=conf.season.name;
        var.MetaData.Script=conf.Plot.script_name;
        var.MetaData.Institution=conf.Data.Institution;
        var.MetaData.Contact=conf.Data.Contact;
        var.MetaData.Information=conf.Data.Info;
        
        %% save the climatology data in a mat file
        save([conf.Save.directory{jj} 'NDBC_' buoyData{ii}.name '_Monthly_Climatology.mat'], '-struct', 'var');

    end
    
    %% format the figure
    xlim([0.5 12.5])
    set(gca,'xtick',[1 2 3 4 5 6 7 8 9 10 11 12])
    set(gca,'xticklabel',conf.season.month_letter)
    box on
    grid on
    ylabel(conf.NDBC.measurement_str{jj})
    legend(conf.NDBC.Sites')
    title([conf.NDBC.measurement_str{jj} ' Climatology from MAB NDBC Buoys ' ...
        num2str(min(time.min)) ' to ' num2str(max(time.max)) ])
%    

    

     timestamp(1,conf.Plot.script_name)

     %% create the output directory and filename
    conf.plot.directory = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/';
    conf.plot.filename = ['MAB_Climatology_Monthly_' conf.NDBC.standard_name{jj} '_'  num2str(min(time.min)) '_' num2str(max(time.max)) '.png'];

    %% print the image
     print(1, '-dpng', '-r400', [conf.plot.directory conf.plot.filename]);
    
    

end


toc
