 function [dir,speed]=uv2compass(u,v)
%
%function [dir,speed]=uv2compass(u,v)
%
%This function converts from east and north vector components (u,v) to speed 
%  and compass direction (increasing CW from north).  After the Matlab function
%  cart2pol is used, the directions are converted from mathmetical convention to
%  compass convention.  The order of input and output arguments is parallel to 
%  cart2pol; but unlike pol2cart the angles are in degrees.
%
%This function gives directions (dir) in oceanographic convention (directions
%  indicated where the current is flowing TOWARD).  If the data are winds, 
%  meteorological convention (directions indicate where wind is blowing FROM)
%  may be desired.  To convert from this function's output, use the command
%  dir=angle360(dir,180).
%
%Any data point with a speed of zero will have a direction of 0 degrees.  If the
%  directions are converted to meteorological convention after the function has
%  been executed (see above paragraph), zero speeds with have directions of 180
%  degrees.  To change this, use the command dir(speed==0)=0.
%
%INPUT:   u       east  vector component  [units: any]
%         v       north vector component  [units: same as u]
%
%OUTPUT:  dir     compass direction       [units: degrees (0 to 360)]
%         speed   vector length           [units: same as u,v]
%
%SEE ALSO: COMPASS2UV, CART2POL

%Mike Whitney
%8/16/02


%Convert from Cartesian coordinates to polar coordinates
[dir,speed]=cart2pol(u,v);


%Convert angles to degrees (mathmetical convention: increasing CCW from x-axis)
dir=dir*180/pi;


%Convert directions to compass convention (increasing CW from north)
%  This is done by first rotating angles by -90 degrees (dir-90)
%  then by changing the angles so they progress CCW from north (360-(dir-90))
dir=360-(dir-90);
dir=angle360(dir,0);


%Remove any rounding error 
%  Roundoff error occurred for dir in radians the conversion 180/pi equals 57.29
%  so when rounding dir use roundoff*100
roundoff=1e-14;
dir=  round( dir/(roundoff*100) ) * (roundoff*100);
speed=round( speed/roundoff ) * roundoff;


%If speed is zero set direction to zero
dir(speed==0)=0;
