clear all
close all

tic

conf.NDBC.years=1974:2016;

conf.NDBC.t0=datenum(conf.NDBC.years(1),1,1);
conf.NDBC.tN=datenum(conf.NDBC.years(end),12,31,23,0,0);

yr_start=1974;
% yr_start=2004;
yr_end=2016;
yr_vec=(yr_start:yr_end)';
yr_str=num2str(yr_vec);
yr_range=yr_end-yr_start;

start_date=datenum(yr_start,01,1);
end_date=datenum(yr_end,12,31);
x_interval=365;

% %% read in data from the thredds server
% buoy.name='acyn4';
% buoy.year=2004:1:2016;
% % buoy.year=2013;
% 
% %% read in the wind data
% [Data]=ndbc_nc(buoy);

%% read in data from the text files downloaded to my computer
% buoy.name='SDHN4';

% buoy.name='ACYN4';

conf.NDBC.Sites={'44025'};
buoy.name='44025';
% buoy.name='bzbm3';
% buoy.name='acyn4';
buoy.year=9999;


ndbc_data=['/Users/hroarty/data/NDBC/' buoy.name];
[Data]=NDBC_monthly_readin_func(ndbc_data,'txt');

% buoyData{ii}=load_buoy(conf.NDBC.t0,conf.NDBC.tN,conf.NDBC.Sites{ii});

time_vec=datevec(Data.time);


%% read in the most recent year from the Thredds server
% buoy.name='sdhn4';


%% read in the current year
[DATA]=ndbc_nc(buoy);

figure(1)
hold on

%% define the colormap for the data
% range_color=(jet(length(yr_vec)));
% range_color=(lines(length(yr_vec)));
colormap19;
range_color=jet(yr_range);
% range_color=winter(yr_range);

water_temp=[];

month= eomday(2003,1:12);

kk=1;

for ii=1:12
    for jj=1:month(ii)
        
        ind=time_vec(:,2)==ii & time_vec(:,3)==jj;
        
        water_temp(kk)=nanmean(Data.WTMP(ind)*1.8+32);
        N(kk)=sum(ind);
        std_dev(kk)=nanstd(Data.WTMP(ind)*1.8+32);
        
        kk=kk+1;
        clear ind
        
    end
end

water_temp_smooth=smooth(water_temp,10);

% plot(1:365,water_temp_smooth*1.8+32)

x=1:365;
x=x';
y=water_temp_smooth;

std_error=std_dev./sqrt(N);

[Y,I] = max(y);
[Y2,I2] = min(y);

% H(1) = shadedErrorBar(x, y, {@mean, @(x) 2*std(x)  },'lineprops', '-r');

shadedErrorBar(x,y,3*std_dev,'lineprops','r');
shadedErrorBar(x,y,2*std_dev,'lineprops','y');
shadedErrorBar(x,y,std_dev,'lineprops','g');

text(61,70,['Warmest Day of Year is: ' datestr(datenum(2003,1,I),'mmm dd')]);
text(122,40,['Coldest Day of Year is: ' datestr(datenum(2003,1,I2),'mmm dd')]);

%h2=plot(((1:length(ind_summer))/24),smooth(Data.WTMP(ind_summer),30),'color',range_color(ii-2004,:),'LineWidth',1.5);
% h2=plot(year_day,Data.WTMP(ind)*1.8 + 32,'color',range_color(ii-(yr_start-1),:),'LineWidth',1.5);





%% Plot the current year
yr_now=2016;
year_day2=DATA(:,1)-datenum(yr_now,12,31,23,0,0);

vector_date=datevec(DATA(:,1));
ind=vector_date(:,1)==yr_now+1;

h2=plot(year_day2(ind),DATA(ind,11)*1.8 + 32,'color','k','LineWidth',3);

% legend(yr_str,'Location','NorthEast');


%% plot the NDBC data
%subplot(2,1,1)
%h2=plot(Data.time,Data.WTMP,'g.-');



%legend('SPRK CODAR Data','44009 NDBC Data')
%legend('Wave Height','Average Wave Period')

% Celsius Scale
% ymin=0;
% ymax=30;
% y_interval=10;

% Farenheit Scale
ymin=20;
ymax=90;
y_interval=10;

date_format='mm/dd/yy';

%AX2=gca;
%format_axis(AX2,start_date,end_date,x_interval,date_format,ymin,ymax,y_interval)

xlabel('Year Day')
ylabel('Water Temp (deg F)')
title(['Daily Mean from NDBC Station ' buoy.name ': ' num2str(yr_start) ' to ' num2str(yr_end)])
% title('Data from NDBC Station SDHN4 Sandy Hook, NJ')
axis([0 365 ymin ymax])

set(gca,'XTick',[1 32 61 92 122 153 183 214 245 275 306 336])
set(gca,'XTickLabel',{'Jan', 'Feb', 'Mar', 'Apr','May', 'Jun', 'Jul', 'Aug','Sep','Oct', 'Nov', 'Dec'})


box on
grid on


conf.HourPlot.script='plot_water_temp_year_mean.m';
conf.Plot.Filename=['Water_Temp_Mean_' buoy.name '_' num2str(yr_start) '_' num2str(yr_end) '_v3.png'];
conf.HourPlot.print_path='/Users/hroarty/Documents/MATLAB/HJR_Scripts/ndbc/';

timestamp(1,[conf.Plot.Filename ' / ' conf.HourPlot.script])
print(1,'-dpng','-r200',[conf.HourPlot.print_path  conf.Plot.Filename])
%% --------------------------
% fit a curve to the data
figure(2)

f = fit( x, y, 'sin2')

y2=feval(f,x);

[Y3,I3] = max(y2);
[Y4,I4] = min(y2);

plot(f,x,y)

text(61,70,['Warmest Day of Year is: ' datestr(datenum(2003,1,I3),'mmm dd')]);
text(122,40,['Coldest Day of Year is: ' datestr(datenum(2003,1,I4),'mmm dd')]);

xlabel('Year Day')
ylabel('Water Temp (deg F)')
title(['Daily Mean from NDBC Station ' buoy.name ': '  num2str(yr_start) ' to ' num2str(yr_end)])
% title('Data from NDBC Station SDHN4 Sandy Hook, NJ')
axis([0 365 ymin ymax])

set(gca,'XTick',[1 32 61 92 122 153 183 214 245 275 306 336])
set(gca,'XTickLabel',{'Jan', 'Feb', 'Mar', 'Apr','May', 'Jun', 'Jul', 'Aug','Sep','Oct', 'Nov', 'Dec'})

box on
grid on

conf.Plot.Filename=['Water_Temp_Mean_Fit_' buoy.name '_' num2str(yr_start) '_' num2str(yr_end) '.png'];


timestamp(2,[conf.Plot.Filename ' / ' conf.HourPlot.script])
print(2,'-dpng','-r200',[conf.HourPlot.print_path  conf.Plot.Filename])

toc