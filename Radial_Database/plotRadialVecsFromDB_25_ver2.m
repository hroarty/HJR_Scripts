
clc
clear all
close all
 
tic

javaaddpath('/Users/hroarty/Documents/MATLAB/HJR_Scripts/radial_database/mysql-connector-java-5.1.6-bin.jar');

%% Declare time for multi year plots
% year.num=2012:2014;
% year.str=num2str(year.num);
% t1 = [year.str(1:4) '-1-1 00:00:00'];
% t2 = [year.str(end-4:end) '-12-31 00:00:00'];

%% Declare time for multi year plots
time1=datenum(2012,1:12,1);
time2=datenum(2013,1:12,1);
time3=datenum(2014,1:12,1);
time4=datenum(2015,1:12,1);
time5=datenum(2016,1:12,1);
time6=datenum(2017,1:12,1);
time7=datenum(2018,1:12,1);

% time_all=[time1 time2 time3 time4];
time_all=[time4 time5 time6 time7];

% t1 = '2015-1-1 00:00:00';
% t2 = '2018-1-1 00:00:00';

t1 =datestr(time_all(1), 'yyyy-mm-dd HH:MM:SS');
t2 =datestr(time_all(end), 'yyyy-mm-dd HH:MM:SS');

year.vec=datevec(time_all);
year.start=num2str(year.vec(1,1));
year.end=num2str(year.vec(end,1));


site = {'PORT','PORT','SILD','SILD','OLDB','OLDB'};
pattType = {2, 3, 2, 3,2,3}; %2 = ideal; 3 = measured;
pattTypestr={'Ideal','Measured','Ideal','Measured','Ideal','Measured'};
site_label = {'PORT      ','SILD      ','OLDB      '};
%site = {'NANT'};

smoothFac = 1; %smoothing factor

% switch pattType
%     case 2
%         pattTypestr='Ideal';
%     case 3
%         pattTypestr='Meas';
% end


%Connect to RUCOOL MySQL  database
host = 'mysql1.marine.rutgers.edu';
user = 'coolops';
password = 'SjR9rM';
dbName = 'coolops';
jdbcString = sprintf('jdbc:mysql://%s/%s', host, dbName);
jdbcDriver = 'com.mysql.jdbc.Driver';
dbConn = database(dbName, user , password, jdbcDriver, jdbcString);

%% define colormap for the plot
%cmap = hsv(length(site));
colormap7_light_dark;
cmap=M;

x_tick_label=[];
x_tick=time_all;
x_tick2=datenum(2015:2018,1,1);
% x_tick2=[datenum(2015,1,1),NaN,NaN,NaN]


ymin=0;
ymax=1200;
y_interval=400;

n_minortick=12;
color='k';
enable='on';
my_XMinorTick(n_minortick,color,enable)

% specify the minor grid vector
xg = x_tick;
% specify the Y-position and the height of minor grids
yg = [ymin ymin+(ymax-ymin)*.1];
xx = reshape([xg;xg;NaN(1,length(xg))],1,length(xg)*3);
yy = repmat([yg NaN],1,length(xg));


for t = 1:length(site)
    getSiteId = ['SELECT id from hfrSites where site="' site{t} '"'];
    siteID = get(fetch(exec(dbConn, getSiteId)), 'Data'); siteID = siteID{1}; % get site ID number

    getVectors = ['SELECT TimeStamp,TableRows from hfrRadialFilesMetadata where Site=' num2str(siteID) ...
        ' and PatternType = ' num2str(pattType{t}) ...
        ' and TimeStamp between ''' t1 ''' and ''' t2 ''''];

    vectors = get(fetch(exec(dbConn, getVectors)), 'Data');
    
    plot_handle(t)=subplot(length(site),1,t);
    
    box on
    grid on
    hold on
    ylim([0 1200])
    xlim([datenum(t1) datenum(t2)])
    ylabel({site{t};pattTypestr{t}},'fontsize',10,'rot',00,'HorizontalAlignment','right')
    set(gca,'xtick',x_tick2)
    my_XMinorTick(n_minortick,color,enable)
    set(gca,'xticklabel',x_tick_label)
    set(gca,'ytick',0:400:1200)
    
%     format_axis(plot_handle(t),datenum(t1),datenum(t2),x_tick2,x_tick,'yyyy',ymin,ymax,y_interval)
    
    
    try
        
    timeVecs = datenum(vectors(:,1), 'yyyy-mm-dd HH:MM:SS.0');
    numVecs = cell2mat(vectors(:,2));
    
    %% determine which files have at least 100 vectors in the file
    numVecsMin=numVecs>100;
    
    
    numVecsSmoothed = smooth(numVecs, smoothFac);
    
    %% use this if you wan to plot the number of vectors in the file
    h(t) = plot(timeVecs, numVecs, '.', 'color', cmap(t,:));
    %% use this if you only want to plot if the file is there
    %h(t) = plot(timeVecs, numVecsMin, '.', 'color', 'k','MarkerSize',10);
    %set(gca,'ytick',[ ])
    %text(times(end)+5,1000,num2str(round2(mean(numVecs),1)))
    
    % plot  the minor grid
    h_minorgrid = plot(xx,yy,'k');
    
    catch
    end
    
    %set(gca,'yticklabel',[0 1000])

end

subplot(length(site),1,t)
set(gca,'xticklabel',datestr(x_tick2,'yyyy'),'fontsize',10)



% format_axis(plot_handle(t),datenum(t1),datenum(t2),x_tick2,x_tick,'yyyy',ymin,ymax,y_interval)

subplot(length(site),1,1)
title([' Radial Vector Count ' year.start ' to ' year.end ],'fontsize',12)

%maximizeSubPlots(plot_handle)
%ht = legend (h,site,'Location','Best');

image_filename=['Radial_Vector_Count_25_' year.start '_' year.end '.png'];

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/radial_database/plotRadialVecsFromDB_25_ver2.m')
print('-dpng','-r400',image_filename);

toc
