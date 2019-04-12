close all
clear all

tic

%% Juaquin Time Period
% start_date=datenum(2015,9,30);
% end_date=datenum(2015,10,8);
% hurricane='Juaquin';
% time.yr=2015;

%% Jonas Time Period
start_date=datenum(2016,1,23);
end_date=datenum(2016,1,25);
hurricane='Jonas';
time.yr=9999;

x_interval=2;
x_minor_interval=1;

%% Load in the NDBC data
conf.NDBC.Sites={'44065','44025','44091','44009'};

for ii=1:length(conf.NDBC.Sites)
    
    buoy.name=conf.NDBC.Sites{ii};
    buoy.year=time.yr;
    Data{ii}=ndbc_nc(buoy);
    
end

%% Load in the CODAR data
conf.Radials.Sites= {'BRAD','SPRK','BRNT','BRMR','RATH','WOOD'};
conf.Radials.RangeCell= 3;

for ii=1:length(conf.Radials.Sites)
try    
datapath=['/Volumes/codaradm/data/waves/' conf.Radials.Sites{ii}];
[wave{ii}]=Codar_WVM7_readin_func(datapath,'wls');
ind{ii}=find(wave{ii}.RCLL==conf.Radials.RangeCell);

catch
end
end


%% determine which range cell to use for the codar data
%ind=find(RCLL==2);

%% plot the codar wave data
%h1=plot(time(ind),MWHT(ind),'b.-','Markersize',6);

data_column=5;
data_column2=6;

sites= [conf.NDBC.Sites(1:2) conf.Radials.Sites(1:2) conf.NDBC.Sites(3) conf.Radials.Sites(3:6) conf.NDBC.Sites(3)];
% s=jet(length(sites));
colormap17
s=M;




hold on 

%% plot the NDBC data
for ii=1:length(conf.NDBC.Sites(1:2))
    %subplot(2,1,1)
    hold on
    plot(Data{ii}(:,1),Data{ii}(:,data_column),'Color',s(ii,:),'LineWidth',2)
%     subplot(2,1,2)
%     hold on
%      plot(Data{ii}(:,1),Data{ii}(:,data_column2),'Color',s(ii,:),'LineWidth',2)
end

%% plot the CODAR data
for ii=1:2
    %subplot(2,1,1)
    hold on
    plot(wave{ii}.time(ind{ii}),wave{ii}.MWHT(ind{ii}),'Color',s(ii+2,:),'LineWidth',2)
%     subplot(2,1,2)
%     hold on
%     plot(wave{ii}.time(ind{ii}),wave{ii}.MWPD(ind{ii}),'Color',s(ii+2,:),'LineWidth',2)
    
    %% calculate the temporal coverage
    temporal_coverage=sum(~isnan(wave{ii}.MWHT))/length(wave{ii}.MWHT);
    disp(['The temporal coverage of station ' conf.Radials.Sites{ii} ' is: ',num2str(temporal_coverage)]);
end

%% plot the NDBC data at 44091
%for ii=1:length(conf.NDBC.Sites(3))
    for ii=3
    %subplot(2,1,1)
    plot(Data{ii}(:,1),Data{ii}(:,data_column),'Color',s(ii+6,:),'LineWidth',2)
%     subplot(2,1,2)
%      plot(Data{ii}(:,1),Data{ii}(:,data_column2),'Color',s(ii+6,:),'LineWidth',2)
    end
    
    %% plot the CODAR data
for ii=3:6
    %subplot(2,1,1)
    hold on
    plot(wave{ii}.time(ind{ii}),wave{ii}.MWHT(ind{ii}),'Color',s(ii+2,:),'LineWidth',2)
%     subplot(2,1,2)
%     hold on
%     plot(wave{ii}.time(ind{ii}),wave{ii}.MWPD(ind{ii}),'Color',s(ii+2,:),'LineWidth',2)
    
    %% calculate the temporal coverage
    temporal_coverage=sum(~isnan(wave{ii}.MWHT))/length(wave{ii}.MWHT);
    disp(['The temporal coverage of station ' conf.Radials.Sites{ii} ' is: ',num2str(temporal_coverage)]);
end

%% plot the NDBC data at 44009
%for ii=1:length(conf.NDBC.Sites(3))
    for ii=4
    %subplot(2,1,1)
    plot(Data{ii}(:,1),Data{ii}(:,data_column),'Color',s(ii+6,:),'LineWidth',2)
%     subplot(2,1,2)
%      plot(Data{ii}(:,1),Data{ii}(:,data_column2),'Color',s(ii+6,:),'LineWidth',2)
    end

%% Format the wave height subplot
ymin=0;
ymax=9;
y_interval=1;

date_format='mm/dd HH:MM';
%subplot(2,1,1)
AX2=gca;
format_axis(AX2,start_date,end_date,x_interval,x_minor_interval,date_format,ymin,ymax,y_interval)
ylabel('Wave Height (m)')

%title(['Wave Height and Period During Storm' hurricane ' ' num2str(start_date,'yyyy')])
title(['Wave Height During Storm' hurricane ' ' datestr(start_date,'yyyy')])
legend(sites,'Location','NorthEast')
%legend('44009','44025','44065','44008','44097','44014')
%legend('Wave Height','Average Wave Period')

%% Format the wave period subplot
% subplot(2,1,2)
% ylabel('Dominant Wave Period (s)')
% AX3=gca;
% format_axis(AX3,start_date,end_date,x_interval,x_minor_interval,date_format,ymin,15,2)


timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/plot_wave_comparison_nc.m')

print(1,'-dpng','-r400',['Waves_multiple_' datestr(start_date,'yyyymmdd') '_to_' datestr(end_date,'yyyymmdd') '.png'])

toc