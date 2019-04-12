tic

% conf.OI.BaseDir='/Volumes/nazzaro/codar_10yr/error0.60/december/';
conf.OI.BaseDir='/Volumes/nazzaro/codar_10yr/error0.90/december/';

yr_time=2007:2016;
% yr_time=2014;
filename='_totals_aggregated_postproc.nc';

% conf.Plot.Path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20171013_Nazzaro_time_series/';
conf.Plot.Path='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20171013_Nazzaro_time_series/20171019_error0.90/';

conf.station.coords=[-73-30/60 40+25/60;-73-55/60 40+05/60;-72-20/60 39+52/60;...
    -71-45/60 39+40/60];
conf.station.name={'A','B','C','D'};

% conf.mean.days=30;
conf.mean.days=0;
conf.mean.length=24*conf.mean.days;

conf.Plot.script_path='/Users/hroarty/Documents/MATLAB/HJR_Scripts/total_plots/';
conf.Plot.script_name='time_series_nazzaro_totals.m';
conf.Data.Institution='Rutgers University';
conf.Data.Contact='Hugh Roarty hroarty@marine.rutgers.edu';
conf.Data.Info=['This data file is the U and V surface velocity from HF radar. ' ...
                'It is derived from the detided and filtered total surface currents that '...
                'Laura Nazzaro generated'];


conf.NDBC.standard_name={'surface_eastward_sea_water_velocity - U','surface_northward_sea_water_velocity - V','Matlab Time - dtime'};
conf.Save.directory='/Users/hroarty/COOL/01_CODAR/MARACOOS/20131211_MAB_currents/20171013_Nazzaro_time_series/';




for jj=1:length(conf.station.name);
    
    U=[];
    V=[];
    dtime2=[];

    for ii=1:length(yr_time)
        f=[conf.OI.BaseDir num2str(yr_time(ii)) filename];

        %% determine the start time of the model
        timeAtt = ncreadatt(f, 'time', 'units');
        timeStr = timeAtt(end-19:end-0);
        % datestr(datenum(timeStr, 'yyyy-mm-ddTHH:MM:SS'))
        timeHFR = datenum(timeStr, 'yyyy-mm-dd HH:MM:SS');
        datestr(timeHFR)

        %% load in the time variable of the model
        dtime = ncread(f, 'time');

        %% convert the model time to matlab time
        dtime1=dtime/(60*60*24)+timeHFR;

        lat=ncread(f,'lat');
        lon=ncread(f,'lon');

        diff1=abs(conf.station.coords(jj,1)-lon);
        diff2=abs(conf.station.coords(jj,2)-lat);

        %% find the closest grid point
        [Y1,I1] = min(diff1);%% find index of closest longitude point
        [Y2,I2] = min(diff2);%% find index of closest latitude point

        Uraw=ncread(f,'u_filtered',[I1 I2 1],[1 1 Inf]);
        Vraw=ncread(f,'v_filtered',[I1 I2 1],[1 1 Inf]);

        Utemp=squeeze(Uraw);
        Vtemp=squeeze(Vraw);

        % concatenate the yearly data
        U=[U;Utemp];
        V=[V;Vtemp];
        dtime2=[dtime2;dtime1];

        clear Utemp Vtemp dtime1

    end

    % compute the running mean
    % U=smooth(U,conf.mean.length,'moving');
    % V=smooth(V,conf.mean.length,'moving');

    %% convention: store velocity time series as complex vector:
    w=U+1i*V;

    %% Convert the matlab time to columns of [yyyy mm dd hh mi sc]
    HFR.datevec=datevec(dtime2);

    %% converth the [yyyy mm dd hh mi sc] to julian date time
    HFR.jd=julian(HFR.datevec);

    % h=timeplt(HFR.jd,[U V abs(w) w],[1 1 2 3 ],[-20 20;0 20;-20 15]);
    h=timeplt(HFR.jd,[U V abs(w) w],[1 1 2 3 ]);

    title_str={[ 'HFR Surface Current Time Series at Point '  conf.station.name{jj} ' ' ]...
       [ 'Lon: ' sprintf('%.2f ',conf.station.coords(jj,1)) ' Lat: ' sprintf('%.2f ',conf.station.coords(jj,1))...
        sprintf('%.0f ',conf.mean.days) ' Day Running Mean']};

    title(title_str)
    stacklbl(h(1),'East(b) + North(r) velocity','cm/s');
    stacklbl(h(2),'Speed','cm/s');
    stacklbl(h(3),'Velocity Sticks','cm/s');

    timestamp(1,'time_series_nazaro_totals.m')
    %print('-dpng','-r200',['Wind_timeplt_5min_Sept' buoy.name '.png'])
    print('-dpng','-r200',[conf.Plot.Path 'HFR_timeseries_' conf.station.name{jj} '_raw.png'])
    
    % add data to the file that will be saved
    var.U=U;
    var.V=V;
    var.dtime=dtime2;

    % add metadata to mat file that will be saved
    var.name=conf.station.name{jj};
    var.variable=conf.NDBC.standard_name;
    var.MetaData.Script=conf.Plot.script_name;
    var.MetaData.Institution=conf.Data.Institution;
    var.MetaData.Contact=conf.Data.Contact;
    var.MetaData.Information=conf.Data.Info;

     %% save the climatology data in a mat file
%     save([conf.Save.directory 'HFR_Station_' conf.station.name{jj} '_Time_Series.mat'], '-struct', 'var');


    close all
    clear U V w
end

toc
    