
clc
clear all
close all
 
tic



 conf.NDBC.years=2007:2014;

conf.NDBC.t0=datenum(conf.NDBC.years(1),1,1);
conf.NDBC.tN=datenum(conf.NDBC.years(end),12,31);

x_tick_label=[];
x_tick=datenum(conf.NDBC.years,1,1);


%% loop through each time frame to load the wind data and generate the plot
for jj=1


    %% read in the wind data
    
%     conf.NDBC.Sites={'44004', '44005', '44008', '44009','44011',...
%                     '44014','44017','44020','44025',...                    
%                         '44027','44065','44066',...
%                             'alsn6','brbn4','chlv2','ocim2'};
                        
    conf.NDBC.Sites={'44008', '44025','44009','44014'};
    
     measurement='Air Temperature';   

    for ii=1:length(conf.NDBC.Sites)

        buoyData{ii}=load_buoy(conf.NDBC.t0,conf.NDBC.tN,conf.NDBC.Sites{ii});
        
        %% plot the data presence for each buoy in its own subplot
%         plot_handle(ii)=subplot(length(conf.NDBC.Sites),1,ii);

        grid on
        hold on
        
        
%         ylim([0.5 1.5])


        xlim([conf.NDBC.t0 conf.NDBC.tN])
        ylabel(measurement,'fontsize',10,'rot',90,'HorizontalAlignment','right')

        set(gca,'xtick',x_tick)
        set(gca,'xticklabel',datestr(x_tick,'yyyy'),'fontsize',10)

%         set(gca,'ytick',[ ])
        
        %% determine if data is there
        %data_presence=~isnan(buoyData{ii}.wspd);%wind speed
        %data_presence=~isnan(buoyData{ii}.wtemp);%wind speed
        data_presence=~isnan(buoyData{ii}.atemp);%wind speed

        %% data_presence will be 1s or 0s
%         h(ii) = plot(buoyData{ii}.t, data_presence, '.', 'color', 'k','MarkerSize',20);
        plot(buoyData{ii}.t,buoyData{ii}.atemp)

    end
    
    h= title(['MAB ' measurement ' Data from ' num2str(conf.NDBC.years(1)) ' to ' num2str(conf.NDBC.years(end))] ,'FontWeight','bold','FontSize',14);
    
    timestamp(1,'plot_NDBC_ts.m')

     %% create the output directory and filename
    output_directory = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/';
    output_filename = ['MAB_' measurement '_'  num2str(conf.NDBC.years(1)) '_' num2str(conf.NDBC.years(end)) '.png'];

    %% print the image
    print(1, '-dpng', '-r200', [output_directory output_filename]);
    
    

end












toc
