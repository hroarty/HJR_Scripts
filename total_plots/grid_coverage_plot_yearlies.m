tic

clear all; close all; 

%% This m script was written to read in the yearly netcdf files that Mike 
%% Smith created at
%% /home/michaesm/codar/codar_means/yearly_means

%% -----------------------------------------------------------
%% Declare the time over which you want to process the data
%% now is local time of the machine
    
%% specific period
% start_time = datenum(2012,1,1,00,0,2);
% end_time=datenum(2012,1,1,23,0,2);
% dtime = start_time:1/24:end_time;
% time_str=datestr(dtime,'yyyy_mm_dd_HHMM');

%% now minus 24 hours
% end_time   = floor(now*24-1)/24 + 2/(24*60*60); %add some slop to handle rounding
% start_time = end_time - 24/24;
% dtime = [start_time:1/24:end_time]; 




years.num=2007:2013;


for ii=1:length(years.num)

%% -----------------------------------------------------------
%% the location of the total data
input_file = ['/Volumes/michaesm/codar/codar_means/yearly_means/RU_5MHz_'...
    num2str(years.num(ii)) 'yearcomposite_' num2str(years.num(ii)) '_01_01_0000.nc']; 


%% get the time from the file
 dtime = ncread(input_file,'time');


%% extract the lat and lon from the nc file
lat = ncread(input_file,'lat');
lon = ncread(input_file,'lon');

%% read the coverage at each grid point
coverage = ncread(input_file,'perCov');

%% replace the fill values of -999 with NaN
logInd=coverage==-999;
coverage(logInd)=NaN;
coverage=coverage';

%% create a new variable with lon lat and coverage
[LON LAT]=meshgrid(lon,lat);
 data2=[LON(:) LAT(:) coverage(:)];
 
 %pcolor(LON,LAT,coverage)

%% ------------------------------------------------------------------------
%% This section of the code separates and uses only the distance of 150 km
%% and the 15 meter isobath to define the coverage grid

%% load the table and eastCoat variables
%load ('/Volumes/boardwalk_home/lemus/MARCOOS/maps/bathy/orig_table.mat'); 


%% load hugh's file  this contains the lat and lon of the nc files, the associated 
%% depth and distance to shore of each grid point
hugh_file=load ('/Users/hroarty/data/grid_files/MARACOOS_Coverage_Grid.mat');

%% load the land mask
eastCoast=load('/Users/hroarty/data/mask_files/MARACOOS_6kmMask.txt');

%% cat the coverage grid with the coverage data
data3=[hugh_file.table data2];


%% find the indices for the points in water depths  more than -15m and
%% within 150 km of the coast
ind1=data3(:,5) <=150 & data3(:,4)<=-15 ...
    & data3(:,3)>=35 & data3(:,3)<=42;
pctGrid=data3(ind1,:);

%% there are some points inside Long Island Sound filter those out
ind2 = ~inpolygon (pctGrid(:,2),pctGrid(:,3),eastCoast(:,1),eastCoast(:,2));

%% final grid to calculate coverage on
finalGrid = pctGrid(ind2,:); 

%% ------------------------------------------------------------------------
% Calculate the temporal spatial coverage
% temporal_prct_coverage=finalGrid(:,8)*100/length(files);
% div=0:5:100;
% n_elements=histc(temporal_prct_coverage,0:5:100);
% c_elements=cumsum(n_elements)*100/length(finalGrid);
% plot(div,flipud(c_elements),'b-x')

[n,xout]=hist(finalGrid(:,8),100);
 tpc=flipud(n');
 div=1:1:100;
 
 for jj=1:length(tpc)
     spc(jj)=tpc(jj)*100/length(finalGrid);
     spc=spc';
 end
 
plot(div,flipud(cumsum(spc)),'LineWidth',2)

 hold on

%% plot the lines for the 80/80 coverage
plot([80 0],[80 80],'--k','LineWidth',3)
plot ([80 80],[0 80],'--k','LineWidth',3)

axis([0 100 0 100])
axis square
grid on
box on

title({'MARACOOS HF Radar Data Coverage from';datestr(dtime+datenum(2001,01,01),'yyyy') },'FontWeight','bold','FontSize',14)
xlabel({''; 'Temporal Coverage (%)'},'FontSize',12)
ylabel({'Spatial Coverage (%)'; ''},'FontSize',12)
legend('Optimal Interpolation','Location','SouthWest')

%timestamp(1,'/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/grid_coverage_plot.m')

%% create the output directory and filename
output_directory = '/Users/hroarty/COOL/01_CODAR/Visualization/Coverage_Plot/';
output_filename = ['MARACOOS_Coverage_' datestr(dtime+datenum(2001,01,01),'yyyy') '.png'];

%% print the image
print(1, '-dpng', '-r200', [output_directory output_filename]);

close all;

end


%clear all;

toc
