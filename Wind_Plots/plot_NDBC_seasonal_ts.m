
clc
clear all
close all
 
tic

conf.NDBC.years=2006:2016;

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

conf.NDBC.Sites={'44008', '44025','44009','44014'};
% conf.NDBC.Sites={'44009'};

% conf.NDBC.measurement_str={'Air Temperature (^{\circ}C)'};
% conf.NDBC.measurement_str2={'Air Temperature (^{\circ}F)'};
% conf.NDBC.measurement_var={'atmp'};
% measurement= 'atmp';%conf.NDBC.measurement_var(1);

% conf.NDBC.measurement_str={'Water Temperature (^{\circ}C)'};
% conf.NDBC.measurement_var={'wtemp'};
% measurement= 'wtemp';%conf.NDBC.measurement_var(1);

conf.NDBC.measurement_str={'Wind Speed'};
conf.NDBC.measurement_str2={'Wind From Direction'};
conf.NDBC.measurement_var={'u','v'};
measurement= 'wspd';%conf.NDBC.measurement_var(1);

conf.Plot.temporal_coverage=0.3;

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

    %% Loop through dtime to calculate the mean
   for kk=1:length(dtime)-1

       %% find the indices of the rows that match the time frame we are interested in
         ind=buoyData{ii}.t>dtime(kk) & buoyData{ii}.t<dtime(kk+1);
         
         switch measurement
            case 'atmp'
                % For scalar means
                var.mean(kk)=nanmean(buoyData{ii}.(measurement)(ind));
                var.std(kk)=nanstd(buoyData{ii}.(measurement)(ind));
                var.N(kk)=sum(~isnan(buoyData{ii}.(measurement)(ind)));
                var.error_bar(kk)=var.std(kk)*1.96./sqrt(var.N(kk));
                var.time_mean(kk)=mean([dtime(kk) dtime(kk+1)]);

                % if there is less than the required temporal coverage convert the 
                % mean to a NaN 
                % 2160 is the number of hours in 3 months (3 months*30 days* 24 hours =2160)
                if var.N(kk)<conf.Plot.temporal_coverage*2160
                   var.mean(kk)=NaN;
                   var.std(kk)=NaN;
                   var.error_bar(kk)=NaN;
                end
            
             case 'wspd'
                % For wind means
                var(ii).name=conf.NDBC.Sites{ii};
                var(ii).u(kk)=nanmean(buoyData{ii}.u(ind));
                var(ii).v(kk)=nanmean(buoyData{ii}.v(ind));
                var(ii).N(kk)=sum(~isnan(buoyData{ii}.u(ind)));
                var(ii).time_mean(kk)=mean([dtime(kk) dtime(kk+1)]);
                var(ii).wspd(kk)=nanmean(buoyData{ii}.wspd(ind));
                [dir,speed]=uv2compass(var(ii).u(kk),var(ii).v(kk));
                dir=angle360(dir,180);
                var(ii).wfdir(kk)=dir;
                
%                 if var(ii).wfdir(kk)<180
%                     var(ii).wfdir(kk)=  var(ii).wfdir(kk)+360;
%                 end
                

                if var(ii).N(kk)<conf.Plot.temporal_coverage*2160
                   var(ii).u(kk)=NaN;
                   var(ii).v(kk)=NaN;
                   var(ii).N(kk)=NaN;
                   var(ii).wspd(kk)=NaN;
                   var(ii).wfdir(kk)=NaN;
                end
           
         end
           
           

%                   string=sprintf('%s %u %02d %2.3g %2.3g %2.3g',conf.NDBC.Sites{ii},conf.NDBC.years(jj),kk,var.mean, var.std, var.N);
%                   disp(string)
   end

   %% plot the seasonal mean for the particular buoy
    hold on
    % scalar plot
%     plot(var.time_mean,var.mean,'s-','LineWidth',2)
    %plot(dtime2_daily_mean,vr_daily_mean,'bs')
    %errorbar(var.time_mean,var.mean,var.error_bar,'LineWidth',2)
    
    %wind plot
    subplot 211
    hold on
    plot(var(ii).time_mean,var(ii).wspd,'s-','LineWidth',2)
    subplot 212
    hold on
    plot(var(ii).time_mean,var(ii).wfdir,'s-','LineWidth',2)


end

%% format the figure
%     xlim([0.5 4.5])
%     set(gca,'xtick',[1 2 3 4])
%     set(gca,'xticklabel',datestr(datenum(conf.NDBC.years,1,1),'yyyy'))

for mm=1:2
    subplot (2,1,mm)
    datetick('x','yyyy')
    box on
    grid on
end

    subplot 211
    ylabel(conf.NDBC.measurement_str)
    legend(conf.NDBC.Sites')
    title([conf.NDBC.measurement_str{1} ' Seasonal Means from MAB NDBC Buoys '])
    subplot 212
    ylabel(conf.NDBC.measurement_str2)
%     ylim([0 360])


 %% create the output directory and filename
conf.Plot.script='plot_NDBC_seasonal_ts.m'; 
conf.Plot.print_path = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/';
conf.Plot.Filename = ['MAB_Seasonal_' measurement '_'  num2str(min(time.min)) '_' num2str(max(time.max)) '.png'];

%% print the image
timestamp(1,[conf.Plot.Filename ' / ' conf.Plot.script])
print(1, '-dpng', '-r400', [conf.Plot.print_path  conf.Plot.Filename]);

% fileID = fopen('Seasonal_Temperatures.txt','w');
% for kk=1:length(var.mean)
%     fprintf(fileID,'%s %f\n',datestr(var.time_mean(kk),'mm-dd-yyyy'),var.mean(kk));
% end
% fclose(fileID);

%% ------------------------------------------------------------------------ 
figure(2)



switch measurement
    case 'atmp'
        
        % determine the indices of a particular season
        var.time_mean_vec=datevec(var.time_mean);  
        conf.season.num=1;
        ind=var.time_mean_vec(:,2)==conf.season.num;
 
        hold on 
   
        season.time=var.time_mean(ind);
        season.mean=var.mean(ind);

        % convert temp from C to F
        season.mean=season.mean*9/5+32;

        % remove NaNs from the data set
        ind2=~isnan(season.mean);
        season.time=season.time(ind2);
        season.mean=season.mean(ind2);

        P=polyfit(season.time,season.mean,1);

        plot(season.time,season.mean,'s-','LineWidth',2)

        X=datenum(1983:2016,1,1);
        Y=polyval(P,X);

        plot(X,Y,'k:')

        str=sprintf('Warming of %.2f degrees per decade',P(1)*365.25*10);
        text(datenum(1987,1,1),44.5,str)
        box on
        grid on
        datetick('x','yyyy')
        % ylim([0 25])
        ylabel(conf.NDBC.measurement_str2)
        legend(conf.NDBC.Sites')
        title([conf.NDBC.measurement_str{1} ' ' conf.season.name{conf.season.num} ' Means from MAB NDBC Buoys '])

        conf.Plot.Filename2 = ['MAB_Seasonal_' measurement '_'  conf.season.name{conf.season.num} '_' num2str(min(time.min)) '_' num2str(max(time.max)) '.png'];
        timestamp(2,[conf.Plot.Filename ' / ' conf.Plot.script])

        print(2,'-dpng','-r200',[conf.Plot.print_path  conf.Plot.Filename2])
        
    case 'wspd'
        
        % determine the indices of a particular season
        var(1).time_mean_vec=datevec(var(1).time_mean);  
        conf.season.num=4;% 
        ind=var(1).time_mean_vec(:,2)==conf.season.months{conf.season.num}(2);
        
        y=zeros(1,length(var(1).time_mean(ind)));
        
        for ii=1:length(conf.NDBC.Sites)
           subplot(4,1,ii)
%            quiver(var(ii).time_mean(ind),y,var(ii).u(ind),var(ii).v(ind))
           h=feather(var(ii).u(ind),var(ii).v(ind));
%            stickplot_new(tt,x,y,tlen,units,labels)
%             offset=0;
%            [h] = stickplot(var(ii).time_mean(ind),var(ii).u(ind),var(ii).v(ind),offset);
           set(gca,'XTickLabel',2007:2016)
           ylim([-3 1])
           xlim([1 10])
           box on
           grid on
%            datetick('x','yyyy')
           ylabel(conf.NDBC.Sites{ii})
        end
        
        subplot 411
        title([conf.NDBC.measurement_str{1} ' ' conf.season.name{conf.season.num} ' Means from MAB NDBC Buoys '])

        conf.Plot.Filename2 = ['MAB_Seasonal_' measurement '_'  conf.season.name{conf.season.num} '_' num2str(min(time.min)) '_' num2str(max(time.max)) '.png'];
        timestamp(2,[conf.Plot.Filename2 ' / ' conf.Plot.script])

        print(2,'-dpng','-r200',[conf.Plot.print_path  conf.Plot.Filename2])
        
        
        M=colormap7;
        
        figure(3)
        hold on
         for ii=1:length(conf.NDBC.Sites)
             plot(var(ii).time_mean(ind),var(ii).wfdir(ind),'o-','color',M(ii,:),'LineWidth',2)
         end
          box on
          grid on
         title([conf.NDBC.measurement_str{1} ' ' conf.season.name{conf.season.num} ' Means from MAB NDBC Buoys '])
         legend(conf.NDBC.Sites)
         datetick('x','yyyy')
          ylabel('Wind Direction From (deg from N)')
          xlim([datenum(2007,1,1) datenum(2017,1,1)])
          ylim([0 360])
          set(gca,'ytick',0:60:360)
          
        conf.Plot.Filename3 = ['MAB_Seasonal_ts_' measurement '_'  conf.season.name{conf.season.num} '_' num2str(min(time.min)) '_' num2str(max(time.max)) '.png'];
        timestamp(3,[conf.Plot.Filename3 ' / ' conf.Plot.script])

        print(3,'-dpng','-r200',[conf.Plot.print_path  conf.Plot.Filename3])
        
end
       
        
toc
