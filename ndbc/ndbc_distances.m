%% m script written January 21, 2014 to read in the location of NDBC sites 
%% calculate the distance between the stations

clear all

%% read in the NDBC sites
dir='/Users/hroarty/data/';
file='NDBC_13MHz_sites.txt';
[G]=read_in_maracoos_sites(dir,file);


%% calculate the combinations of distances between the staions
c = combnk(1:length(G{2}),2);

for ii=1:length(c)
    
    d=distance(G{4}(c(ii,1)),G{3}(c(ii,1)),G{4}(c(ii,2)),G{3}(c(ii,2)));
    %[dist(i) az(i)] = distance('gc', [RxLat,RxLon], [Ylat(i),Xlon(i)], [6378.137*1000 0]);
    
    
    %% convert the degrees to km
    d=deg2km(d);
    
    %% get the buoy names out of the cell array so you can use sprintf
    buoy1=char(G{2}(c(ii,1)));
    buoy2=char(G{2}(c(ii,2)));
    string=sprintf('The distance between station %s and %s is: %d (km)',buoy1,buoy2,round(d));
    disp(string)
    
end





