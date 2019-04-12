tic

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
dtime=datenum(2015,03,01):1/24:datenum(2015,4,1);

%% find the absolute difference between the ESPRESSO matlab time and the first 
%% time that we are interested in
timeDiff=abs(time1-dtime(1));

%% find the index of the ESPRESSO matlab time closest to the first time that we are
%% interested in
[~,timeIndex]=min(timeDiff);


%% decalre the grid point that you are interested in
ind_lat=40+30/60;
ind_lon=-74;

%% Load in the grid for the U current
lat_u=ncread(file,'lat_u');
lon_u=ncread(file,'lon_u');

%% Load in the grid for the U current
lat_u=ncread(file,'lat_u');
lon_u=ncread(file,'lon_u');

%% get the size of lon_u
[r_u,c_u]=size(lon_u);

%% create matix of point that we want that is same size of lon and lat
B=repmat(ind_lon,r_u,c_u);
C=repmat(ind_lat,r_u,c_u);

%ind_distance=distance(lat_vector,lon_vector,C(:),B(:));
%% calculate the distance from each of the ESPRESSO grid (lat,lon) points 
%% to the grid point we are interested in
ind_distance=distance(lat_u,lon_u,C,B);

[Y,I]=min(ind_distance);

%% get the row and column of the grid point closest to the point we are interested in
[~,Irow.u]=min(min(ind_distance,[],2));
[~,Icolumn.u]=min(min(ind_distance,[],1));

%% Load in the grid for the U current
lat_v=ncread(file,'lat_v');
lon_v=ncread(file,'lon_v');

%% get the size of lon_v
[r_v,c_v]=size(lon_v);

%% create matix of point that we want that is same size of lon and lat
D=repmat(ind_lon,r_v,c_v);
E=repmat(ind_lat,r_v,c_v);

%ind_distance=distance(lat_vector,lon_vector,C(:),B(:));
%% calculate the distance from each of the ESPRESSO grid (lat,lon) points 
%% to the grid point we are interested in
ind_distance_v=distance(lat_v,lon_v,D,E);

[Y,I]=min(ind_distance);

%% get the row and column of the grid point closest to the point we are interested in
[~,Irow.v]=min(min(ind_distance_v,[],2));
[~,Icolumn.v]=min(min(ind_distance_v,[],1));


%ncread(filename,parameter,start indices, count indices);
%temp=ncread(file,'temp',[1 1 1 1000],[Inf Inf Inf 1]); % Type help ncread
% test=squeeze(double(temp(:,:,:,1)));
% pcolor(lon,lat,test(:,:,1));
% shading flat

%% read in the u and v ESPRESSO data
u_series=ncread(file,'u',[Irow.u Icolumn.u 36 timeIndex],[1 1 1 length(dtime)]);
v_series=ncread(file,'v',[Irow.v Icolumn.v 36 timeIndex],[1 1 1 length(dtime)]);

%% squeeze the data to get a vector
u_series=squeeze(u_series);
v_series=squeeze(v_series);

%% convert the current in m/s to cm/s
U=100*u_series;
V=100*v_series;

%% rotation angle, this is the same rotation angle for region 4 of MAB
rot=360-37;

%% rotate the u and v into a cross channel (v) and along channel (u)
[ur, vr] = dg_rotate_refframe(U,V,rot);

%% low pass the along channel velocity
per=32;
om=2*pi/per;
ns=2*per;

    
%% calculate the low pass of the data    
[tlow,xlow,xhi]=lowpassbob(dtime,ur,om,ns);

figure(1)
plot(dtime,ur,'r')
hold on
plot(tlow,xlow,'g','linewidth',2)
%datetick('x','mm/dd')
% box on
% grid on
%% plot a black line across zero
plot([dtime(1) dtime(end)],[0 0],'k','linewidth',3)
ylabel('Velocity (cm/s)','Fontsize',16)


set(gca,'FontSize',16)

lower_bound=round(floor(min(ur)*1.1),-1);
upper_bound=round(ceil(max(ur)*1.1),-1);
step=10;

%format_axis(gca,min(dtime),max(dtime),24*7/24,24/24,'mm/dd',lower_bound,upper_bound,step)
format_axis(gca,min(dtime),max(dtime),24*7/24,24/24,'mm/dd',-100,80,20)

timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/nc/Espresso_time_series_plot.m')

print(1,'-r200','-dpng',['ESPRESSO_velocity_ts_' datestr(dtime(1),'yyyymmdd') '_'...
    datestr(dtime(end),'yyyymmdd') '.png'])

toc

%% ----------------------------
% figure(2)
% hold on
% lims=[-80 -66 33 43];
% coastFileName = '/Users/hroarty/data/coast_files/ESPRESSO_coast.mat';
% hold on
% %figure
% plotBasemap(lims(1:2),lims(3:4),coastFileName,'mercator','patch',[240,230,140]./255);
% 
% m_plot(lon,lat,'b.')
% m_plot(lon(84,:),lat(84,:),'ks')
% m_plot(lon(Irow,Icolumn),lat(Irow,Icolumn),'r*')
% 
% print(2,'-r200','-dpng','ESPRESSO_Grid.png')