%% m script written January 21, 2014 to read in the location of NDBC sites 
%% calculate the distance between the stations

clear all

%% read in the NDBC sites
dir='/Users/hroarty/data/';
file='antarctic_Codar_sites.txt';
[G]=read_in_maracoos_sites(dir,file);


%% calculate the combinations of distances between the staions
c = combnk(5:length(G{2}),2);

for ii=1:length(c)
    
    d=distance(G{4}(c(ii,1)),G{3}(c(ii,1)),G{4}(c(ii,2)),G{3}(c(ii,2)));
    [LAT,LON,DISTANCE,BEARING]=loxodrome(G{4}(c(ii,1)),G{3}(c(ii,1)),G{4}(c(ii,2)),G{3}(c(ii,2)));
    
    
    %% convert the degrees to km
    d=deg2km(d);
    
    %% get the buoy names out of the cell array so you can use sprintf
    buoy1=char(G{2}(c(ii,1)));
    buoy2=char(G{2}(c(ii,2)));
    %% use this when using the dist function
    %string=sprintf('The distance between station %s and %s is: %d (km)',buoy1,buoy2,round(d));
    %% use this when using the loxodrome function
    string=sprintf('The distance between station %s and %s is: %d (km)',buoy1,buoy2,round(DISTANCE(end)));
    disp(string)
    string=sprintf('The bearing from station %s to station %s is: %d (deg true)',buoy1,buoy2,round(BEARING));
    disp(string)
end





