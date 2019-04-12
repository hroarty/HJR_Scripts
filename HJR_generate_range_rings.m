function [r_ring_x , r_ring_y , r_line_x , r_line_y] = HJR_generate_range_rings(rc_size, num_of_range_cells, angular_coverage, start_angle, radial_spacing, lat, lon)
%   generate_range_rings(rc_size, num_of_range_cells, angular_coverage, start_angle, radial_spacing, lat, lon)
%                   ( km,       #,                  degrees, degrees, degrees,  degrees,        ddd.mmm, ddd.mmm)
%   RETURNS [r_ring_x , r_ring_y , r_line_x , r_line_y]

% range=1.5; %km
% angular_coverage = 160;
% ang = angular_coverage*pi/180; % angular coverage
% counter=angular_coverage/5;
% asp=90;

angular_bins = angular_coverage / radial_spacing;
angular_coverage = angular_coverage * pi / 180;

for i = 1 : angular_bins + 1
	for r = 1 : num_of_range_cells
	    clat(i,r)=lat + ((r*rc_size-rc_size/2) * sin(((start_angle+82.5)*pi/180) + i*angular_coverage/angular_bins)) / 111.12;
        clon(i,r)=lon - ((r*rc_size-rc_size/2) * cos(((start_angle+82.5)*pi/180) + i*angular_coverage/angular_bins) / (111.12 * cos(lat*pi/180)));
	end
end

r_ring_x =clon;
r_ring_y = clat;






% %Standard System %
% range=1.5; %km
% angular_coverage=160;
% ang=angular_coverage*pi/180; % angular coverage
% counter=angular_coverage/5;
% asp=90; %asp = angular start point, where the angular bins start, 45 is 45 degrees cw from true north

for r = 1 : num_of_range_cells
    for i = 1 : angular_bins + 1;
        clat2(r,i) = lat + ((r*rc_size-rc_size/2) * sin(((start_angle + 82.5) * pi/180) + i*angular_coverage/angular_bins)) / 111.12;
        clon2(r,i) = lon - ((r*rc_size-rc_size/2) * cos(((start_angle + 82.5) * pi/180) + i*angular_coverage/angular_bins) / (111.12 * cos(lat*pi/180)));
    end
end


r_line_x = clon2;
r_line_y = clat2;

