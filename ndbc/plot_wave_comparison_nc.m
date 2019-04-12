close all
clear all

tic

%% Irene Time Period
% start_date=datenum(2011,8,23);
% end_date=datenum(2011,9,3);
% hurricane='Irene';

%% Sandy Time Period
% start_date=datenum(2016,9,1);
% end_date=datenum(2016,9,8);
% hurricane='Sandy';

%% Sandy Time Period
start_date=datenum(2017,1,1);
end_date=datenum(2017,6,1);
hurricane='Sandy';

time.yr=9999;
time.yr=2017;


x_interval=30;
x_minor_interval=7;

% conf.NDBC.Sites={'44009','44025','44065','44091','44066'};
conf.NDBC.Sites={'44025','44065','44091'};
% conf.NDBC.Sites={'44025'};

for ii=1:length(conf.NDBC.Sites)
    
    buoy.name=conf.NDBC.Sites{ii};
    buoy.year=time.yr;
    Data{ii}=ndbc_nc2(buoy);
    
end


%% determine which range cell to use for the codar data
%ind=find(RCLL==2);

%% plot the codar wave data
%h1=plot(time(ind),MWHT(ind),'b.-','Markersize',6);

data_column=5;

% s=jet(length(conf.NDBC.Sites));
s=colormap7;

%% plot the NDBC data
subplot(2,1,1)
hold on 

for ii=1:length(conf.NDBC.Sites)
    plot(Data{ii}(:,1),Data{ii}(:,data_column),'Color',s(ii,:),'LineWidth',2)
end

legend(conf.NDBC.Sites,'Location','NorthWest')
%legend('44009','44025','44065','44008','44097','44014')
%legend('Wave Height','Average Wave Period')


ymin=0;
ymax=5;
y_interval=1;

date_format='mm/dd';
AX2=gca;
format_axis(AX2,start_date,end_date,x_interval,x_minor_interval,date_format,ymin,ymax,y_interval)
xlabel('mm/dd')
ylabel('Wave Height (m)')


data_column2=6;

subplot(2,1,2)

hold on

for ii=1:length(conf.NDBC.Sites)
    plot(Data{ii}(:,1),Data{ii}(:,data_column2),'Color',s(ii,:),'LineWidth',2)
end


xlabel('mm/dd')
ylabel('Dominant Wave Period (s)')
AX3=gca;
format_axis(AX3,start_date,end_date,x_interval,x_minor_interval,date_format,ymin,15,3)


conf.Plot.Filename='Waves_multiple_2017.png';
conf.Plot.script='plot_wave_comparison_nc.m';
% conf.Plot.print_path='/Users/hroarty/Consulting/Monmouth_County_Prosecutors';
conf.Plot.print_path='/Users/roarty/COOL/Talks/20180531_MTS_Waves/';

timestamp(1,[conf.Plot.Filename ' / ' conf.Plot.script])
print(1,'-dpng','-r300',[conf.Plot.print_path  conf.Plot.Filename])

toc