
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
year.num=2015;
year.str=num2str(year.num);

time1=datenum(2015,6:11,1);
time2=datenum(2015,12,1);
time_all=[time1 time2];

t1 = datestr(min(time1),'yyyy-mm-dd HH:MM:SS');
t2 = datestr(max(time2),'yyyy-mm-dd HH:MM:SS');
% t1= '2013-7-14 00:00:00';
% t2 = '2014-7-15 00:00:00';

dtime=min(time1):1/24:max(time2);

site = {'GCAP'};
pattType = 2; %2 = ideal; 3 = measured;
site_label = {'PORT      ','SILD      '};
%site = {'NANT'};

smoothFac = 1; %smoothing factor

switch pattType
    case 2
        pattTypestr='Ideal';
    case 3
        pattTypestr='Meas';
end


%Connect to MySQL cool_ais database
host = 'mysql1.marine.rutgers.edu';
user = 'coolops';
password = 'SjR9rM';
dbName = 'coolops';
jdbcString = sprintf('jdbc:mysql://%s/%s', host, dbName);
jdbcDriver = 'com.mysql.jdbc.Driver';
dbConn = database(dbName, user , password, jdbcDriver, jdbcString);


cmap = hsv(length(unique(site)));

x_tick_label=[];

x_tick=time_all;

for t = 1:length(site)
    getSiteId = ['SELECT id from hfrSites where site="' site{t} '"'];
    siteID = get(fetch(exec(dbConn, getSiteId)), 'Data'); siteID = siteID{1}; % get site ID number

    getVectors = ['SELECT TimeStamp,TableRows from hfrRadialFilesMetadata where Site=' num2str(siteID) ...
        ' and PatternType = ' num2str(pattType) ...
        ' and TimeStamp between ''' t1 ''' and ''' t2 ''''];

    vectors = get(fetch(exec(dbConn, getVectors)), 'Data');
    
    plot_handle(t)=subplot(length(unique(site)),1,t);
    
    grid on
    hold on
    ylim([0.5 1.5])
    xlim([datenum(t1) datenum(t2)])
    ylabel(site(t),'fontsize',10,'rot',00,'HorizontalAlignment','right')
    
    set(gca,'xtick',x_tick)
    set(gca,'xticklabel',x_tick_label)
    
    set(gca,'ytick',[ ])
    
    try
        
    times = datenum(vectors(:,1), 'yyyy-mm-dd HH:MM:SS.0');
    numVecs = cell2mat(vectors(:,2));
    
    %% determine which files have at least 100 vectors in the file
    numVecsMin=numVecs>100;
    Data_Percent=sum(numVecsMin)/length(dtime)
    
    numVecsSmoothed = smooth(numVecs, smoothFac);
    h(t) = plot(times, numVecsMin, '.', 'color', 'k','MarkerSize',10);
    %text(times(end)+5,1000,num2str(round2(mean(numVecs),1)))
    
    
    catch
    end
    
    %set(gca,'yticklabel',[0 1000])

end

subplot(length(unique(site)),1,t)
set(gca,'xticklabel',datestr(x_tick,'mmm'),'fontsize',10)

subplot(length(unique(site)),1,1)
title([pattTypestr ' Radial Vector Count'],'fontsize',12)

%maximizeSubPlots(plot_handle)

%timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/radial_database/plotRadialVecsFromDB.m')

%ht = legend (h,site,'Location','Best');

image_filename=['Radial_Vector_Present_25_' pattTypestr '_' datestr(min(time1),'yyyymmdd') '_' datestr(min(time2),'yyyymmdd') '.png'];

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/radial_database/plotRadialVecsFromDB_25.m')
print('-dpng','-r400',image_filename);

toc
