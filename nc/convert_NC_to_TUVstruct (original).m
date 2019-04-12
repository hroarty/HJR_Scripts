function [TUV]=convert_NC_to_TUVstruct(file,errorflag)



%% read in the nc variables
tot.t=nc_varget(file,'time');
tot.lat = nc_varget(file,'lat');
tot.lon = nc_varget(file,'lon');
tot.u=nc_varget(file,'u');
tot.v=nc_varget(file,'v');

%% replace fill values -999 with NaNs
ind.u=tot.u==-999;
tot.u(ind.u)=NaN;
ind.v=tot.v==-999;
tot.v(ind.v)=NaN;

if errorflag
    tot.u_err=nc_varget(file,'u_err');
    tot.v_err=nc_varget(file,'v_err');
end

[LON,LAT]=meshgrid(tot.lon,tot.lat);

%% get the time units from the nc variable
time.units=nc_attget(file,'time','units');
time.str=time.units(end-18:end);
time.matlab=datenum(time.str);

%% create the empty TUV stuctured array
TUV = TUVstruct( [length(LON(:)) 1], 1 );

%% Populate the TUV struct with the data from the .nc file

TUV.TimeStamp=time.matlab+tot.t;
TUV.LonLat(:,1)=LON(:);
TUV.LonLat(:,2)=LAT(:);
TUV.U=tot.u(:);
TUV.V=tot.v(:);

if errorflag
    TUV.ErrorEstimates.Type='OIuncert';
    TUV.ErrorEstimates.Uerr=tot.u_err(:);
    TUV.ErrorEstimates.Verr=tot.v_err(:);
    TUV.ErrorEstimates.UerrUnits='cm2/s2';
    TUV.ErrorEstimates.VerrUnits='cm2/s2';
end

end
