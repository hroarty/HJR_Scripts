
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

time_all=[time1 time2 time3 time4];

t1 = '2016-3-15 00:00:00';
t2 = '2016-3-21 00:00:00';

year.vec=datevec(time_all);
year.start=num2str(year.vec(1,1));
year.end=num2str(year.vec(end,1));


site = {'PORT','PORT','SILD','SILD'};
pattType = {2, 3, 2, 3}; %2 = ideal; 3 = measured;
pattTypestr={'Ideal','Measured','Ideal','Measured'};
site_label = {'PORT      ','SILD      '};
%site = {'NANT'};
systemTypeId='3';

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

% x_tick_label=[];
% x_tick=time_all;
x_tick2=datenum(t1):1:datenum(t2);
% x_tick_label
% for t = 1:length(site)
    getSystemTypeId = ['SELECT radialTimestamp, numRadials from hfrTotals where systemTypeId="' systemTypeId '"'];
    vectors = get(fetch(exec(dbConn, getSystemTypeId)), 'Data'); 
    %siteID = siteID{1}; % get site ID number

%     getNumRadials = ['SELECT TimeStamp,TableRows from hfrRadialFilesMetadata where Site=' num2str(siteID) ...
%         ' and PatternType = ' num2str(pattType{t}) ...
%         ' and TimeStamp between ''' t1 ''' and ''' t2 ''''];
% 
%     vectors = get(fetch(exec(dbConn, getVectors)), 'Data');
    
%     plot_handle(t)=subplot(length(site),1,t);
    
    box on
    grid on
    hold on
%     ylim([0 8])
    xlim([datenum(t1) datenum(t2)])
    %ylabel({site{t};pattTypestr{t}},'fontsize',10,'rot',00,'HorizontalAlignment','right')
    set(gca,'xtick',x_tick2)
%     set(gca,'xticklabel',x_tick_label)
    %set(gca,'ytick',0:400:1200)
    
    
    
    try
        
    timeVecs = datenum(vectors(:,1), 'yyyy-mm-dd HH:MM:SS.0');
    numVecs = cell2mat(vectors(:,2));
    
    %% determine which files have at least 100 vectors in the file
%     numVecsMin=numVecs>100;
    
    
    numVecsSmoothed = smooth(numVecs, smoothFac);
    
    %% use this if you wan to plot the number of vectors in the file
    h(t) = plot(timeVecs, numVecs, '*', 'color','red' );
    %% use this if you only want to plot if the file is there
    %h(t) = plot(timeVecs, numVecsMin, '.', 'color', 'k','MarkerSize',10);
    %set(gca,'ytick',[ ])
    %text(times(end)+5,1000,num2str(round2(mean(numVecs),1)))
    
    
    catch
    end
    
    %set(gca,'yticklabel',[0 1000])

% end

% subplot(length(site),1,t)
 set(gca,'xticklabel',datestr(x_tick2,'mm/dd'),'fontsize',10)

%subplot(length(site),1,1)
title([' Radial Site Count ' datestr(datenum(t1), 'mmm yyyy')],'fontsize',12)

%maximizeSubPlots(plot_handle)
%ht = legend (h,site,'Location','Best');

image_filename=['Total_Radial_Site_Count_13_' year.start '_' year.end '.png'];

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/radial_database/plot_numRadialsFromDB_13.m')
print('-dpng','-r400',image_filename);

toc
