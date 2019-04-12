
clc
clear all
close all
 
tic

javaaddpath('/Users/hroarty/Documents/MATLAB/HJR_Scripts/radial_database/mysql-connector-java-5.1.6-bin.jar');

 year.num=2017:2017;
 year.str=num2str(year.num);

t1 = [year.str(1:4) '-1-1 00:00:00'];
t2 = [year.str(1:4) '-12-31 00:00:00'];% single year
% t2 = [year.str(end-4:end) '-12-31 00:00:00'];%multiple years

frequency=5;

switch frequency
    case 4
        conf.Diag.Sites={'NAUS','NANT','MVCO','BLCK'};
        conf.Diag.Region='North';
    
    case 5
%         conf.Diag.Sites={'AMAG','MRCH','HEMP','HOOK','LOVE','BRIG','WILD'};
        conf.Diag.Sites={'MRCH'};
         conf.Diag.Region='Central';
        ymax=360;
        ymin=0;
    case 6
        conf.Diag.Sites={'ASSA','CEDR','LISL','DUCK','HATY','CORE'};
         conf.Diag.Region='South';
        ymax=360;
        ymin=0;
end

% site = {{'NAUS','NANT','MVCO','BLCK'};...
%     {'AMAG','MRCH','HEMP','HOOK','LOVE', 'WILD'};...
%     {'ASSA','CEDR','LISL','DUCK','HATY','CORE'}};
% site_label = {'NAUS      ','ERRA      ','NANT      ','MVCO      ','BLCK      ','AMAG      ','MRCH      ','HEMP      '...
%     ,'HOOK     ','LOVE      ', 'WILD      ','ASSA      ','CEDR      ','LISL      ','DUCK      ','HATY      ','CORE      '};
%site = {'NANT'};
pattType = 3; %2 = ideal; 3 = measured;
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


cmap = hsv(length(unique(conf.Diag.Sites)));

x_tick_label=[];

x_tick=datenum(year.num,1:12,1);

x_tick_minor=[];

for ii=1:length(year.num)
    temp=datenum(year.num(ii),1:12,1);
    x_tick_minor=[x_tick_minor  temp];
end

ymin=0;
ymax=360;

var='AntennaBearing';

for t = 1:length(conf.Diag.Sites)
    getSiteId = ['SELECT id from hfrSites where site="' conf.Diag.Sites{t} '"'];
    siteID = get(fetch(exec(dbConn, getSiteId)), 'Data'); siteID = siteID{1}; % get site ID number

    getVectors = ['SELECT TimeStamp,' var ' from hfrRadialFilesMetadata where Site=' num2str(siteID) ...
        ' and PatternType = ' num2str(pattType) ...
        ' and TimeStamp between ''' t1 ''' and ''' t2 ''''];

    vectors = get(fetch(exec(dbConn, getVectors)), 'Data');
    
    plot_handle(t)=subplot(length(unique(conf.Diag.Sites)),1,t);
    
    box on
    grid on
    hold on
    ylim([ymin ymax])
    xlim([datenum(t1) datenum(t2)])
    ylabel(conf.Diag.Sites(t),'fontsize',10,'rot',90,'HorizontalAlignment','right')
    
    set(gca,'xtick',x_tick)
    set(gca,'xticklabel',x_tick_label)
    
%     set(gca,'ytick',[ ])
    
    try
        
    times = datenum(vectors(:,1), 'yyyy-mm-dd HH:MM:SS.0');
    numVecs = cell2mat(vectors(:,2));
    
    %% determine which files have at least 100 vectors in the file
%     numVecsMin=numVecs>100;
    
    
%     numVecsSmoothed = smooth(numVecs, smoothFac);
    h(t) = plot(times, numVecs, '.', 'color', 'k','MarkerSize',10);
    text(times(1)+30,300,num2str(unique(numVecs)))
    
    
    catch
    end
    
    %set(gca,'yticklabel',[0 1000])

end

%% format the x axis on the bottom subplot
subplot(length(unique(conf.Diag.Sites)),1,t)
hold on
set(gca,'xticklabel',datestr(x_tick,'mmm'),'fontsize',10)
set(gca,'xminortick','on')
% set(gca,'xtick',x_tick_minor)

% % specify the minor grid vector
% xg = x_tick_minor;
% % specify the Y-position and the height of minor grids
% yg = [ymin ymin+(ymax-ymin)*.1];
% xx = reshape([xg;xg;NaN(1,length(xg))],1,length(xg)*3);
% yy = repmat([yg NaN],1,length(xg));
% h_minorgrid = plot(xx,yy,'k');

%% add the title on the top subplot 
subplot(length(unique(conf.Diag.Sites)),1,1)
% title([pattTypestr ' Radial Vector Count ' year.str(1:4) ' to ' year.str(end-4:end)],'fontsize',12)
title([' Antenna Bearing ' year.str(1:4) ' to ' year.str(1:4)],'fontsize',12)

% maximizeSubPlots(plot_handle)

timestamp(1,'/radial_database/plot_AntennaBearing_FromDB_all.m')

%ht = legend (h,site,'Location','Best');

image_filename=['Radial_' var '_' pattTypestr '_' conf.Diag.Region '_' year.str(1:4) '_'  year.str(1:4) '.png'];
print('-dpng','-r400',image_filename);

toc
