
%% define the paths and load in the NDBC data
datapath='/Users/hroarty/data/NDBC/44009';
file_extension='txt';
[Data]=NDBC_monthly_readin_func(datapath,file_extension);

%% create a vector that is the number of days long of the data
daily_time=floor(min(Data.time)):1:floor(max(Data.time));
daily_time=daily_time';

%% define thresholds
Hs_thresh=1.5;
Wind_thresh=15;

%% compute size of daily_time
[r,c]=size(daily_time);

%% create variable for wind and wave test
window=NaN(r,c);

%% loop to go through data to see if any 24 hour window meets wind and 
%% wave threshold
for ii=1:length(daily_time)
    ind=find(floor(Data.time)==daily_time(ii));
    wave_test=Data.WVHT(ind)>Hs_thresh;
    wind_test=Data.WSPD(ind)>Wind_thresh;
    if sum(wave_test)+sum(wind_test)<1
        window(ii)=1;
    end
    clear ind wave_test wind_test
end

