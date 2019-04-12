 function [u,v]=compass2uv(dir,speed)
%
%function [u,v]=compass2uv(dir,speed)
%
%This function converts from speed and compass direction (increasing CW from 
%  north) to east and north vector components (u,v).  The Matlab function
%  pol2cart is used once the directions have been converted to mathematical
%  convention.  The order of input and output arguments is parallel to pol2cart;
%  but unlike pol2cart the angles are in degrees.
%
%This function expects directions (dir) in oceanographic convention (directions
%  indicated where the current is flowing TOWARD).  If the data are winds, the
%  data may be in meteorological convention (directions indicate where wind is 
%  blowing FROM).  If so, convert directions using dir=angle360(dir,180) prior
%  to using dir as a function input.
%
%INPUT:   dir     compass direction       [units: degrees (0 to 360)]
%         speed   vector length           [units: any]
%
%OUTPUT:  u       east  vector component  [units: same as speed]
%         v       north vector component  [units: same as speed]
%
%SEE ALSO: UV2COMPASS, POL2CART

%Mike Whitney
%8/16/02


%Convert directions to mathematical convention (increasing CCW from x-axis)
%  This is done by first changing angles to progress CCW from north (360-dir)
%  then the angles are rotated by +90 degrees ((360-dir)+90).
dir=(360-dir)+90;
dir=angle360(dir,0);


%Convert from polar coordinates to Cartesian coordinates
[u,v]=pol2cart(dir*pi/180,speed);


%Remove any rounding error
roundoff=1e-14;
u=round(u/roundoff)*roundoff;
v=round(v/roundoff)*roundoff;
