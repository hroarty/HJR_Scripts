
clc
clear all
close all
 
tic



conf.NDBC.years=1982:2016;

conf.NDBC.t0=datenum(conf.NDBC.years(1),1,1);
conf.NDBC.tN=datenum(conf.NDBC.years(end),12,31,23,0,0);

x_tick_label=[];
x_tick=datenum(conf.NDBC.years,1,1);


%% loop through each time frame to load the wind data and generate the plot
for jj=1


    %% read in the wind data
    
    conf.NDBC.Sites={'44004', '44005', '44008', '44009','44011',...
                    '44014','44017','44020','44025',...                    
                        '44027','44065','44066',...
                            'alsn6','brbn4','chlv2','ocim2'};
%     conf.NDBC.Sites={'44008', '44009','44014','44025'};


    for ii=1:length(conf.NDBC.Sites)

        buoyData{ii}=load_buoy(conf.NDBC.t0,conf.NDBC.tN,conf.NDBC.Sites{ii});

        %% plot the data presence for each buoy in its own subplot
        plot_handle(ii)=subplot(length(conf.NDBC.Sites),1,ii);

        grid on
        hold on
        ylim([0.5 1.5])
        xlim([conf.NDBC.t0 conf.NDBC.tN])
        ylabel(conf.NDBC.Sites(ii),'fontsize',10,'rot',00,'HorizontalAlignment','right')

        set(gca,'xtick',x_tick)
        set(gca,'xticklabel',x_tick_label)
        set(gca,'XTickLabelRotation', 30)

        set(gca,'ytick',[ ])

        % determine if data is there
    %   data_presence=~isnan(buoyData{ii}.wspd);%wind speed
%         measurement='Wind Data';
    %   data_presence=~isnan(buoyData{ii}.wtemp);%water temperature
    %   measurement='Water Temp';
        data_presence=~isnan(buoyData{ii}.atmp);%air temperature
        measurement='Air Temp';

        %% data_presence will be 1s or 0s
        h(ii) = plot(buoyData{ii}.t, data_presence, '.', 'color', 'k','MarkerSize',20);

    end
    
    subplot(length(conf.NDBC.Sites),1,ii)
    set(gca,'xticklabel',datestr(x_tick,'yyyy'),'fontsize',10)



    
    subplot(length(conf.NDBC.Sites),1,1)
    h= title(['MAB ' measurement ' Data from ' num2str(conf.NDBC.years(1)) ' to ' num2str(conf.NDBC.years(end))] ,'FontWeight','bold','FontSize',14);

    %maximizeSubPlots(plot_handle)

    

    

     %% create the output directory and filename
    conf.Plot.script='plot_wind_data_presence.m';
    conf.Plot.print_path = '/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20160106_Wind_Plots/';
    conf.Plot.Filename = ['MAB_' measurement '_'  num2str(conf.NDBC.years(1)) '_' num2str(conf.NDBC.years(end)) '.png'];

    timestamp(1,[conf.Plot.Filename ' / ' conf.Plot.script])
    print(1,'-dpng','-r200',[conf.Plot.print_path  conf.Plot.Filename])
    
    

end












toc
