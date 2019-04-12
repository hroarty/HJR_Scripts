
clc
clear all
close all
 
tic

conf.NDBC.years=2006:2014;

conf.NDBC.t0=datenum(conf.NDBC.years(1),1,1);
conf.NDBC.tN=datenum(conf.NDBC.years(end),12,31);

conf.season.name={'winter','spring','summer','fall'};
conf.season.months={[12 1 2],[3 4 5],[6 7 8],[9 10 11]};

x_tick_label=[];
x_tick=datenum(conf.NDBC.years,1,1);

%% read in the wind data

%     conf.NDBC.Sites={'44004', '44005', '44008', '44009','44011',...
%                     '44014','44017','44020','44025',...                    
%                         '44027','44065','44066',...
%                             'alsn6','brbn4','chlv2','ocim2'};

%conf.NDBC.Sites={'44008', '44025','44009','44014'};
conf.NDBC.Sites={'44009'};

% conf.NDBC.measurement_str={'Air Temperature (^{\circ}C)'};
% conf.NDBC.measurement_var={'atemp'};
% measurement= 'atemp';%conf.NDBC.measurement_var(1);
% conf.file.directory='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/atmp_Climatology/';

conf.NDBC.measurement_str={'Water Temperature (^{\circ}C)'};
conf.NDBC.measurement_var={'wtemp'};
measurement= 'wtemp';%conf.NDBC.measurement_var(1);
conf.file.directory='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/SST_Climatology/';

conf.Plot.temporal_coverage=0.8;

%% Build the time vector
dtime=[];% define the vector so you can write to it in the loop

for ii=1:length(conf.NDBC.years)
    dtime=[dtime; datenum(conf.NDBC.years(ii),3:3:12,1)'];
end

%% remove the first three rows of dtime so we start in the winter
dtime(1:3)=[];
    
    %% loop through each of the data sources
for ii=1:length(conf.NDBC.Sites)

    buoyData{ii}=load_buoy(conf.NDBC.t0,conf.NDBC.tN,conf.NDBC.Sites{ii});

    time.vec=datevec(buoyData{ii}.t);
    time.max(ii)=max(time.vec(:,1));
    time.min(ii)=min(time.vec(:,1));
    
    %% Load the seasonal mean data
    seasonal_mean=load([conf.file.directory 'NDBC_' conf.NDBC.Sites{ii} '_Seasonal_Climatology.mat']);
    
    %% replicate the means to the same size of dtime
    seasonal_mean_var=repmat(seasonal_mean.mean',ceil(length(dtime)/4),1);

    %% Loop through dtime to calculate the mean
   for kk=1:length(dtime)-1

       %% find the indices of the rows that match the time frame we are interested in
         ind=buoyData{ii}.t>dtime(kk) & buoyData{ii}.t<dtime(kk+1); 

           var.mean(kk)=nanmean(buoyData{ii}.(measurement)(ind))-seasonal_mean_var(kk);
           var.std(kk)=nanstd(buoyData{ii}.(measurement)(ind));
           var.N(kk)=sum(~isnan(buoyData{ii}.(measurement)(ind)));
           var.error_bar(kk)=var.std(kk)*1.96./sqrt(var.N(kk));
           var.time_mean(kk)=mean([dtime(kk) dtime(kk+1)]);
           
           %% if there is less than the required temporal coverage convert the 
           %% mean to a NaN 
           %% 2160 is the number of hours in 3 months 
%             if var.N(kk)<conf.Plot.temporal_coverage*2160
%                var.mean(kk)=NaN;
%                var.std(kk)=NaN;
%                var.error_bar(kk)=NaN;
%             end

%                   string=sprintf('%s %u %02d %2.3g %2.3g %2.3g',conf.NDBC.Sites{ii},conf.NDBC.years(jj),kk,var.mean, var.std, var.N);
%                   disp(string)
   end

   %% plot the seasonal mean for the particular buoy
    hold on
    plot(var.time_mean,var.mean,'LineWidth',2)
    %plot(dtime2_daily_mean,vr_daily_mean,'bs')
    %errorbar(var.time_mean,var.mean,var.error_bar,'LineWidth',2)  



end

%% format the figure
%     xlim([0.5 4.5])
%     set(gca,'xtick',[1 2 3 4])
%     set(gca,'xticklabel',datestr(datenum(conf.NDBC.years,1,1),'yyyy'))
datetick('x','yyyy')
box on
grid on
ylabel(conf.NDBC.measurement_str)
legend(conf.NDBC.Sites')
title([conf.NDBC.measurement_str{1} ' Anomaly from MAB NDBC Buoys '])
%    



 timestamp(1,'plot_NDBC_seasonal_anomaly_ts.m')

 %% create the output directory and filename
output_directory = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/44009_Only/';
output_filename = ['MAB_Seasonal_Anomaly_' measurement '_'  num2str(min(time.min)) '_' num2str(max(time.max)) '.png'];

%% print the image
 print(1, '-dpng', '-r400', [output_directory output_filename]);
   


toc
