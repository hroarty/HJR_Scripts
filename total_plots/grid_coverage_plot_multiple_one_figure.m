tic

clear all; close all; 

%% -----------------------------------------------------------
%% Declare the time over which you want to process the data
%% now is local time of the machine

time_matrix=[   2011 6 1 0 0 0;2011 12 1 0 0 0;...
                2012 6 1 0 0 0;2012 12 1 0 0 0;...
                2013 6 1 0 0 0;2013 12 1 0 0 0;...
                2014 6 1 0 0 0;2014 12 1 0 0 0;...
                2015 6 1 0 0 0;2015 12 1 0 0 0];
         
[r,c]= size(time_matrix);        

cmap = distinguishable_colors(r);

%% create the output directory and filename
output_directory = '/Users/hroarty/COOL/01_CODAR/Visualization/Coverage_Plot/';




for jj=1:r-1

%% specific period
start_time = datenum(time_matrix(jj,:));
end_time=datenum(time_matrix(jj+1,:));
dtime = start_time:1/24:end_time;

time_str=datestr(dtime,'yyyy_mm_dd_HHMM');

%% -----------------------------------------------------------
%% the location of the total data
input_dir = '/Volumes/codaradm/data/totals/maracoos/oi/nc/5MHz/'; 

%% loop to get all the file names

files=cell(length(dtime),1);

for ii = 1:length (dtime)
files{ii,1} =[input_dir, 'RU_5MHz_' time_str(ii,:) '.totals.nc']; 
end

%% loop to grab info on the total files
for ii = 1:length(files) ; % length(files):-1:length(files)-24 %length(files)-24:length(files)
    try 
        fprintf('Loading Total file: %s\n',files{ii})
        t = nc_varget(files{ii},'time');
        %lat = nc_varget(files{ii},'lat');
        %lon = nc_varget(files{ii},'lon');%lon=double(lon);
        u = nc_varget(files{ii},'u');%u = double(u);
        v = nc_varget(files{ii},'v');%v = double(v);
        rad = nc_varget(files{ii},'num_radials');
        
        % u_err = nc_varget(files(i).name,'u_err');u_err = double(u_err);
        % v_err = nc_varget(files(i).name,'v_err');v_err = double(v_err);
        % id(i).id = files(i).name;
 
        
        data.t(ii) = t;
        data.u(:,:,ii) = u;% Saves u component
        data.v(:,:,ii) = v; %  Saves v Component
        data.rad(:,:,ii) = rad;% 
        % monthly.v_err(i,:,:) = v_err;
        % monthly.total(i,:,:) = total;
        
    catch
        fprintf('Total file not present %s\n',files{ii})
        data.u(:,:,ii)=NaN; 
        data.v(:,:,ii)=NaN;
        data.t(ii)=dtime(ii)-datenum(2001,1,1);
        data.rad(:,:,ii) = NaN;
    end

 clear t u v rad
end

%% extract the lat and lon from the nc file
lat = nc_varget(files{ii},'lat');
lon = nc_varget(files{ii},'lon');

%% calculate the coverage at each grid point
coverage=~isnan(data.u);
coverage2=sum(coverage,3);
coverage2=squeeze(coverage2);

%% create a new variable with lon lat and coverage
[LON LAT]=meshgrid(lon,lat);
 data2=[LON(:) LAT(:) coverage2(:)];

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
ind1=find((data3(:,5) <=150) & (data3(:,4)<=-15) ...
    & data3(:,3)>=35 & data3(:,3)<=42);
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
 
 for ii=1:length(tpc)
     spc(ii)=tpc(ii)*100/length(finalGrid);
     spc=spc';
 end
 
plot(div,flipud(cumsum(spc)),'LineWidth',2,'color',cmap(jj,:))

 hold on



%% save the data

file_str=datestr(start_time,'yyyymmdd');

savefile=[output_directory 'MARACOOS_Coverage_'  file_str '.mat'];
save(savefile,'n','xout','tpc','spc','div')





end

%% plot the lines for the 80/80 coverage
plot([80 0],[80 80],'--k','LineWidth',3)
plot ([80 80],[0 80],'--k','LineWidth',3)

axis([0 100 0 100])
axis square
grid on
box on

%title({'MARACOOS HF Radar Data Coverage from';[datestr(data.t(1)+datenum(2001,01,01),'yyyy/mm/dd HH:MM') ' to ' datestr(data.t(end)+datenum(2001,01,01),'yyyy/mm/dd HH:MM')]},'FontWeight','bold','FontSize',14)
title('MARACOOS HF Radar Data Coverage','FontWeight','bold','FontSize',14)
xlabel({''; 'Temporal Coverage (%)'},'FontSize',12)
ylabel({'Spatial Coverage (%)'; ''},'FontSize',12)

legend(datestr(time_matrix),'mmm-yyyy')

timestamp(1,'/total_plots/grid_coverage_plot_multiple_one_figure.m')

output_filename = ['MARACOOS_Coverage_2010_2015.png'];
%% print the image
print(1, '-r400','-dpng', [output_directory output_filename]);

toc