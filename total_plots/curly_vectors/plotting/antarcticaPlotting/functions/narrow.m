function h=narrow(lon,lat,scale)
% Plots a North Arrow at the specified location.  
% Scale is used to size the arrow

p1 = reckon(lat,lon,km2deg(3*scale),0);
p2 = reckon(lat,lon,km2deg(5*scale),90);
p3 = reckon(lat,lon,km2deg(12*scale),0);
p4 = reckon(lat,lon,km2deg(5*scale),270);

ar = [p1; p2; p3; p4;];

h = patch(ar(:,2),ar(:,1),[1 1 1]*.2);
