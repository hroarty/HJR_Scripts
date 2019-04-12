
clc
clear all
close all
 
tic

javaaddpath('/Users/hroarty/Documents/MATLAB/HJR_Scripts/radial_database/mysql-connector-java-5.1.6-bin.jar');

year.num=2007;
year.str=num2str(year.num);

t1 = [year.str '-6-3 00:00:00'];
t2 = [year.str '-6-5 00:00:00'];



site = {'NAUS','NANT','BLCK','MVCO','MRCH','HEMP','HOOK','LOVE', 'WILD','ASSA','CEDR','LISL','DUCK','HATY','CORE'};
%site = {'PORT','SILD'};
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
month=1:12;
%x_tick=datenum(year.num,month,1);
x_tick=datenum(t1):6/24:datenum(t2);

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
    ylim([0 2000])
    xlim([datenum(t1) datenum(t2)])
    ylabel(site(t),'fontsize',6)
    
    set(gca,'xtick',x_tick)
    set(gca,'xticklabel',x_tick_label)
    
    set(gca,'ytick',[0 1000],'fontsize',6)
    
    try
        
    times = datenum(vectors(:,1), 'yyyy-mm-dd HH:MM:SS.0');
    numVecs = cell2mat(vectors(:,2));
    numVecsSmoothed = smooth(numVecs, smoothFac);
    h(t) = plot(times, numVecs, '.-', 'color', cmap(t,:),'markersize',8);
    text(times(end)+5,1000,num2str(round2(mean(numVecs),1)))
    
    
    catch
    end
    
    %set(gca,'yticklabel',[0 1000])

end

subplot(length(unique(site)),1,t)
set(gca,'xticklabel',datestr(x_tick,'mm/dd HH:MM'))

subplot(length(unique(site)),1,1)
title([pattTypestr ' Radial Vector Count for ' year.str],'fontsize',12)

% maximizeSubPlots(plot_handle)

%timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/radial_database/plotRadialVecsFromDB.m')

%ht = legend (h,site,'Location','Best');

image_filename=['Radial_Vector_Count_5_Arthur_' pattTypestr '_' year.str '.png'];

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/radial_database/plotRadialVecsFromDB_daily.m')

print('-dpng','-r200',image_filename);

toc
