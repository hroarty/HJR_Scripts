
%% this m script will generate daily mean surface current plots along with wind

close all
clear all

tic



%% Define some configuration parameters
conf.start_date=datenum(2012,01,01);
conf.end_date=datenum(2012,12,31);
conf.x_interval=30;
conf.date_format='mm/dd';
conf.ymin=-40;
conf.ymax=40;
conf.y_interval=10;
conf.quad={'NE','SE','SW','NW'};

conf.wind.scale=10;
conf.wind.origin=[-74.5 40];
conf.wind.text=[-74.65 39.85];

conf.HourPlot.axisLims= [-75 -73 38.25 41];
conf.HourPlot.CoastFile='/Users/hroarty/data/coast_files/BPU3_coast.mat';
conf.HourPlot.windscale=0.1*30;
conf.HourPlot.ColorTicks=0:3:30;
conf.HourPlot.print_path='/Volumes/hroarty/codar/BPU/totals/Daily_Means/';
conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.DomainName='BPU';
conf.HourPlot.plotData_xargs={2};%% use this for plot_vel
conf.HourPlot.plotData_xargs={'Length',5,'Width',5};%,'Page'};


%% read in the hourly data
hourly=load('/Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data/weatherflow/tuckertonwind.mat');

%% convert the wind direction FROM to TOWARDS
hourly.hourlywinddirTO=angle360(hourly.hourlywinddir,180);

%% convert the magnitude and direction to u and v
[hourly.uhr,hourly.vhr]=compass2uv(hourly.hourlywinddirTO,hourly.hourlywindspd);

%month=1:12;
month=9;
end_day=eomday(2012,month);

for jj =month
    
    
    %dtime=datenum(2012,month,ii,0,0,2):1/24:datenum(2012,month,ii+1,0,0,2)
    
    %% load the total concatenated file
    file_path=['/Volumes/hroarty/codar/BPU/totals/'];
    D=dir([file_path '*.mat']);
    
    load([file_path D(jj).name])
    
    %% get the daily mean 
    
    hour.start=1:24:end_day(1)*24;
    hour.end=24:24:end_day(1)*24;
    
    for ii=1:numel( hour.start)
        
        
        %% find the indices of the wind data that match the surface current time period
        ind=find(hourly.hourlytime >= datenum(2012,jj,ii,0,0,0) & hourly.hourlytime <= datenum(2012,jj,ii,23,0,0));
        
        %% calculate the daily mean wind 
        wind_mean.u=nanmean(hourly.uhr(ind));
        wind_mean.v=nanmean(hourly.vhr(ind));
        wind_mean.mag=sqrt(wind_mean.u.^2+wind_mean.v.^2);
        wind_mean.mag_str=num2str(round2(wind_mean.mag,0.1));
        
        
        
        
        
        
        
        %% get the surface currents that match the indices of the particular wind direction 
        
        try
            TUV.day = TUVcat;
            TUV.day.TimeStamp=TUVcat.TimeStamp(hour.start(ii):hour.end(ii));
            TUV.day.U=TUVcat.U(:,hour.start(ii):hour.end(ii));
            TUV.day.V=TUVcat.V(:,hour.start(ii):hour.end(ii));
            
            %% calculate the percent coverage at aech grid point
            coverage = 100 * sum( isfinite(TUV.day.U+TUV.day.V), 2 ) / size(TUV.day.U,2);

            %% find the grid points less that 50% coverage
            ind=find(coverage<50);

            %% set the velocity in the grid points below 50% coverage to Nans
            TUV.day.U(ind,:)=NaN;
            TUV.day.V(ind,:)=NaN;
            
            
            
            %% calculate the mean only when you have 50% data coverage for the day
            TUV.dayM=nanmeanTotals(TUV.day,2);
            
            mean_vector_plot_fn_03(TUV.dayM,wind_mean,conf);
        catch err
            disp(err.message)
            %break
        end
            
        %% plot the image, the printing is done inside the function
        
%         try
%             mean_vector_plot_fn(TUV.(config.quad{ii}),config.quad{ii}, wind_dir.(config.quad{ii}))
%         catch err
%             disp(err.message)
%         end

    clear wind_mean ind
    end
    
end

toc











