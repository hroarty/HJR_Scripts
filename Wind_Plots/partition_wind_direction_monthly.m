close all
clear all

tic

%% read in the weatherflow data
%% path for the script  /Users/hroarty/COOL/01_CODAR/BPU/20130102_Wind_Data
read_weatherflow_data
buoy.name='37558';
yyyy0=2012;

%% read in the hourly data
hourly=load('tuckertonwind.mat');

%% Define some configuration parameters
config.start_date=datenum(2012,01,01);
config.end_date=datenum(2012,12,31);
config.x_interval=30;
config.date_format='mm/dd';
config.ymin=-40;
config.ymax=40;
config.y_interval=10;
config.quad={'NE','SE','SW','NW'};


[u,v]=compass2uv(buoy.wfdir,buoy.wspd);
[uhr,vhr]=compass2uv(hourly.hourlywinddir,hourly.hourlywindspd);


month=1:12;
%month=2;
end_day=eomday(2012,month);

for jj =month
    ind=find(hourly.hourlytime >= datenum(2012,jj,1,0,0,0) & hourly.hourlytime <= datenum(2012,jj,end_day(jj),23,0,0));
    ind=ind';
    disp(jj)
    disp(length(ind))
    
    monthly.time=hourly.hourlytime(ind);
    monthly.windspd=hourly.hourlywindspd(ind);
    monthly.winddir=hourly.hourlywinddir(ind);
    
    wind_dir.NE=find(monthly.winddir > 0 & monthly.winddir < 90)';
    wind_dir.SE=find(monthly.winddir > 90 & monthly.winddir < 180)';
    wind_dir.SW=find(monthly.winddir > 180 & monthly.winddir < 270)';
    wind_dir.NW=find(monthly.winddir > 270 & monthly.winddir < 360)';
    
    %% load the total concatenated file
    file_path=['/Volumes/hroarty/codar/BPU/totals/'];
    D=dir([file_path '*.mat']);
    
    load([file_path D(jj).name])
    
    %% get the mean of the four quadrants
    
    for ii=1:numel(config.quad)
        
        %% get the surface currents that match the indices of the particular wind direction 
        
        try
            TUV.(config.quad{ii}) = TUVcat;
            TUV.(config.quad{ii}).TimeStamp=TUVcat.TimeStamp(wind_dir.(config.quad{ii}));
            TUV.(config.quad{ii}).U=TUVcat.U(:,wind_dir.(config.quad{ii}));
            TUV.(config.quad{ii}).V=TUVcat.V(:,wind_dir.(config.quad{ii}));
            TUV.(config.quad{ii})=nanmeanTotals(TUV.(config.quad{ii}),2);
            
            mean_vector_plot_fn(TUV.(config.quad{ii}),config.quad{ii}, wind_dir.(config.quad{ii}))
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
    end
    
end

toc











