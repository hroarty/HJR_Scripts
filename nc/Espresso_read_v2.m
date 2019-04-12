clear all;close all;
file='http://tds.marine.rutgers.edu:8080/thredds/dodsC/roms/espresso/2013_da/his_Best/ESPRESSO_Real-Time_v2_History_Best_Available_best.ncd';
ncdisp(file);


% time=ncread(file,'ocean_time'); % seconds since 2006-01-01 00:00:00
% datetime=(time./(60*60*24))+datenum(datevec('2006-01-01 00:00:00'));

%% determine the start time of the model
timeAtt = ncreadatt(file, 'time', 'units');
timeStr = timeAtt(end-19:end-1);
% datestr(datenum(timeStr, 'yyyy-mm-ddTHH:MM:SS'))
timeESPRESSO = datenum(timeStr, 'yyyy-mm-ddTHH:MM:SS');
datestr(timeESPRESSO)

%% load in the time variable of the model
time = ncread(file, 'time');

%% convert the model time to matlab time
time1=time/24+timeESPRESSO;

%% declare the time that you are interested in
dtime=datenum(2015,01,01):1/24:datenum(2015,6,1);

timeDiff=abs(time1-dtime(1));


%% decalre the grid point that you are interested in
ind_lat=40+30/60;
ind_lon=-74;





%ncread(filename,parameter,start indices, count indices);
temp=ncread(file,'temp',[1 1 1 1000],[Inf Inf Inf 1]); % Type help ncread

temp_series=ncread(file,'temp',[84 74 1 1000],[1 1 1 100]);
lat=ncread(file,'lat_rho');
lon=ncread(file,'lon_rho');
test=squeeze(double(temp(:,:,:,1)));
pcolor(lon,lat,test(:,:,1));

shading flat

%% ----------------------------
figure(2)
hold on
lims=[-80 -66 33 43];
coastFileName = '/Users/hroarty/data/coast_files/ESPRESSO_coast.mat';
hold on
%figure
plotBasemap(lims(1:2),lims(3:4),coastFileName,'mercator','patch',[240,230,140]./255);

m_plot(lon,lat,'b.')



m_plot(lon(84,:),lat(84,:),'ks')
%% get the size of lon
[r,c]=size(lon);

%% create matix of point that we want that is same size of lon and lat
B=repmat(ind_lon,r,c);
C=repmat(ind_lat,r,c);


lat_vector=lat(:);
lon_vector=lon(:);

%ind_distance=distance(lat_vector,lon_vector,C(:),B(:));
%% calculate the distance from each of the ESPRESSO grid (lat,lon) points 
%% to the grid point we are interested in
ind_distance=distance(lat,lon,C,B);

[Y,I]=min(ind_distance);

%% get the row and column of the grid point closest to the point we are interested in
[Y,Irow]=min(min(ind_distance,[],2));
[Y,Icolumn]=min(min(ind_distance,[],1));

m_plot(lon(Irow,Icolumn),lat(Irow,Icolumn),'r*')

print(2,'-r200','-dpng','ESPRESSO_Grid.png')