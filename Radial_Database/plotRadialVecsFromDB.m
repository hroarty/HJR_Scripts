
clc
clear all
close all
 
tic

javaaddpath('/Users/hroarty/Documents/MATLAB/HJR_Scripts/radial_database/mysql-connector-java-5.1.6-bin.jar');

% Declare time for a single year plot
% year.num=2014;
% year.str=num2str(year.num);
% t1 = [year.str '-1-1 00:00:00'];
% t2 = [year.str '-12-31 00:00:00'];

%% Declare time for multi year plots
year.num=2004:2018;
year.str=num2str(year.num);

time_all=[];

for ii=1:length(year.num)
    time1=datenum(year.num(ii),1:12,1);
    time_all=[time_all time1];
end

t1 = '2004-1-1 00:00:00';
t2 = '2017-12-1 00:00:00';



site = {'NAUS','ERRA','NANT','BLCK','MVCO','AMAG','MRCH','HEMP','HOOK','LOVE','GRHD','BRIG' 'WILD','ASSA','CEDR','LISL','DUCK','HATY','CORE'};
% site = {'PORT','SILD'};
pattType = 2; %2 = ideal; 3 = measured;
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

y_scale=0:100:1000;

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
    ylim([y_scale(1) y_scale(end)])
    xlim([datenum(t1) datenum(t2)])
    ylabel(site(t),'fontsize',15)
    
    set(gca,'xtick',x_tick)
    set(gca,'xticklabel',x_tick_label,'fontsize',10)
    
    set(gca,'ytick',y_scale,'fontsize',10)
    %set(gca,'yticklabel',0:500:1000,'fontsize',10)
    try
        
    times = datenum(vectors(:,1), 'yyyy-mm-dd HH:MM:SS.0');
    numVecs = cell2mat(vectors(:,2));
    numVecsSmoothed = smooth(numVecs, smoothFac);
    h(t) = plot(times, numVecs, '.', 'color', cmap(t,:));
    text(times(end)+5,1000,num2str(round2(mean(numVecs),1)))
    
    
    catch
    end
    
    %set(gca,'yticklabel',[0 1000])

end

subplot(length(unique(site)),1,t)
set(gca,'xticklabel',datestr(x_tick,'mmm'))

subplot(length(unique(site)),1,1)
title([pattTypestr ' Radial Vector Count for ' year.str],'fontsize',12)

%maximizeSubPlots(plot_handle)

%timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/radial_database/plotRadialVecsFromDB.m')

%ht = legend (h,site,'Location','Best');

image_filename=['Radial_Vector_Count_25_' pattTypestr '_' year.str '.png'];

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/radial_database/plotRadialVecsFromDB.m')

print('-dpng','-r200',image_filename);

toc
