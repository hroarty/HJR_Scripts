function [wp,wp2,rot]=fn_region_geometry(variable)
%variable='region4';

switch variable
    case 'region4'
        %% region 4 starting point
        wp(1,:)=[40.5 -74];
        %% range and bearing numbers for the alongshelf line
        range_km=500;
        range_step=6;
        bearing=217;
        %% range_km and bearing for the end points of the cross shelf lines
        wp2=[];
        range2=300;
        bearing2=127;
        %% rotation angle for the current vectors
        rot=360-37;
    case 'region4N'
        %% region 4 starting point
        wp(1,:)=[40.5 -74];
        %% range_km and bearing numbers for the alongshelf line
        range_km=300;
        range_step=6;
        bearing=217;
        %% range_km and bearing for the end points of the cross shelf lines
        wp2=[];
        range2=300;
        bearing2=127;
        %% rotation angle for the current vectors
        rot=360-37;
    case 'region4C'
        %% region 4 starting point
        wp(1,:)=[38.75 -75];
        %% range_km and bearing numbers for the alongshelf line
        range_km=300;
        range_step=6;
        bearing=217;
        %% range_km and bearing for the end points of the cross shelf lines
        wp2=[];
        range2=300;
        bearing2=127;
        %% rotation angle for the current vectors
        rot=360-37;
    case 'region4S'
        %% region 4 starting point
        wp(1,:)=[37 -76];
        %% range_km and bearing numbers for the alongshelf line
        range_km=300;
        range_step=6;
        bearing=217;
        %% range_km and bearing for the end points of the cross shelf lines
        wp2=[];
        range2=300;
        bearing2=127;
        %% rotation angle for the current vectors
        rot=360-37;
    case 'region3'
        %% region 3 starting point
%         wp(1,:)=[41.5 -70];% removed 20171003 HJR
        wp(1,:)=[41.0 -72];
        %% range_km and bearing numbers for the alongshelf line
        range_km=350;
        range_step=6;
        bearing=250;
        %% range_km and bearing for the end points of the cross shelf lines
        wp2=[];
        range2=300;
        bearing2=160;
        %% rotation angle for the current vectors
        rot=360-70;
    case 'region2'
        %% region 2 starting point
        wp(1,:)=[42 -70];
        %% range_km and bearing numbers for the alongshelf line
        range_km=100;
        range_step=6;
        bearing=217;
        %% range_km and bearing for the end points of the cross shelf lines
        wp2=[];
        range2=200;
        bearing2=127;
        %% rotation angle for the current vectors
        rot=360-37;
end

%% calculate the lat and lon of the alongshelf line pts
for ii=2:range_km/range_step
    wp(ii,:)=course2ll([wp(ii-1,1) wp(ii-1,2) bearing range_step]);
end

%% calculate the lat and lon of the end points for the cross shelf lines
for ii=1:length(wp)
    wp2(ii,:)=course2ll([wp(ii,1) wp(ii,2) bearing2 range2]);
end