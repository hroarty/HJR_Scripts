close all
clear all

tic

%% Irene Time Period
% start_date=datenum(2011,8,23);
% end_date=datenum(2011,9,3);
% hurricane='Irene';

%% Time Period to grab data
year=2017;
year_str=num2str(year);


%% Buoy Info Cell Arrays
buoy.name={'44009','44091','44025','44065'};
buoy.year={2017,2017,2017,2017};

%% loop to go though each buoy

for ii=1:length(buoy.name)
    
    %% decalre the individual buoy
    buoy2.name=buoy.name{ii};
    buoy2.year=buoy.year{ii};

    %% read in the wind data
    [DATA]=ndbc_nc(buoy2);


    %% Save the data
    savefile=['/Users/hroarty/data/NDBC/ndbc_' buoy2.name '_' year_str '.mat'];
    save(savefile,'DATA')
    
end

toc