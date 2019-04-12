function [TUV]=convert_HYCOM_NC_to_TUVstruct(file,dtime)
%% function written on April 14, 2015 by Hugh Roarty to convert a HYCOM
%% netCDF file to TUV structured array


%% read in the nc variables
tot.t=ncread(file, 'time');
tot.lat = ncread(file, 'lat');
tot.lon = ncread(file, 'lon');
I = find(tot.lon >= 283 & tot.lon <= 293); % lon in degrees east
J = find(tot.lat >= 34 & tot.lat <= 43); % lat
lons = tot.lon(I); 
lons = lons-360;
lats = tot.lat(J);
[LON,LAT] = meshgrid(lons, lats);
LON=LON';
LAT=LAT';

%% get the time units from the nc variable
time.units=ncreadatt(file,'time','units');
time.str=time.units(end-19:end-1);
time.matlab=datenum(time.str,'yyyy-mm-ddTHH:MM:SS');

%% calculate the time index so you can pull the correct data 
%% convert the hours in the nc file to matlab time, first divide by 24 to 
%% convert hours to days and then add the reference time
t0=tot.t/24+time.matlab;
tDiff = abs(t0 - dtime);
[~,tlen] = min(tDiff);
time_index=tlen;%example of last day;cd

tot.u=ncread(file, 'water_u', [I(1) J(1) 1 time_index], [I(end)-I(1)+1 J(end)-J(1)+1 1 1]);
tot.v=ncread(file, 'water_v', [I(1) J(1) 1 time_index], [I(end)-I(1)+1 J(end)-J(1)+1 1 1]);
tot.u = double(tot.u)*100;
tot.v = double(tot.v)*100;


%% create the empty TUV stuctured array
TUV = TUVstruct( [length(LON(:)) 1], 1 );

%% Populate the TUV struct with the data from the .nc file

TUV.TimeStamp=dtime;
TUV.LonLat(:,1)=LON(:);
TUV.LonLat(:,2)=LAT(:);
TUV.U=tot.u(:);
TUV.V=tot.v(:);

% TUV.ErrorEstimates.Type='OIuncert';
% TUV.ErrorEstimates.Uerr=tot.u_err(:);
% TUV.ErrorEstimates.Verr=tot.v_err(:);
% TUV.ErrorEstimates.UerrUnits='cm2/s2';
% TUV.ErrorEstimates.VerrUnits='cm2/s2';
end
