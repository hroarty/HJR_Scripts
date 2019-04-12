function [ang]=angle360(ang,shift)
%
%function [ang]=angle360(ang,shift)
%
%This function ensures angles (in degrees) range from 0 to 360.  An angle shift
%  can be added.

%Mike Whitney
%3/28/01

if exist('shift')~=1
  shift=0;
end
ang=ang+shift;
ang(ang<0)=ang(ang<0)+360;
ang(ang>=360)=ang(ang>=360)-360;