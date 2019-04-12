function plot_shipping_lanes_m_map(gcf)


% Plot the shipping lanes off the coast of NJ

%%%%%% Barnegat to Ambrose %%%%% (long lat)

%axes(handles.axes_map)
A=[40 20.613 73 49.783;...
   40 20.682 73 48.407;...
   40 20.871 73 47.090;...
   40 21.231 73 45.871;...
   39 45.821 73 54.549;...
   39 45.671 73 48.175;...
   39 45.671 73 44.255;...
   39 45.659 73 37.507];

Alat=A(:,1)+A(:,2)/60;
Alon=-A(:,3)-A(:,4)/60;

% yes (shaded)
SZlat=[Alat(2);Alat(3);Alat(7);Alat(6)];
SZlon=[Alon(2);Alon(3);Alon(7);Alon(6)];
SZ = [SZlon SZlat]; clear SZl*

% Ambrose to Barnegat Traffic Lane (yes)
BAlat1=[Alat(1);Alat(5)];
BAlon1=[Alon(1);Alon(5)];
BA1 = [BAlon1 BAlat1]; clear BAl*

% Barnegat to Ambrose Traffic Lane (yes)
BAlat2=[Alat(4);Alat(8)];
BAlon2=[Alon(4);Alon(8)];
BA2 = [BAlon2 BAlat2]; clear BAl*

%%%%% Ambrose Channel %%%%%
B=[40 31.432 74 00.830;...
      40 29.541 73 55.979;...
      40 29.791 73 55.711;...
      40 31.691 74 00.549];

% yes
Blat=B(:,1)+B(:,2)/60;
Blon=-B(:,3)-B(:,4)/60;
B = [Blon Blat]; clear Bl*

%%%%%% Hudson Canyon to Ambrose %%%%%
C=[40 21.704 73 44.648;...
   40 22.373 73 43.418;...
   40 23.128 73 42.613;...
   40 23.890 73 41.981;...
   39 59.492 73 22.820;...
   40 03.054 73 18.150;...
   40 05.330 73 15.517;...
   40 09.055 73 11.311];

Clat=C(:,1)+C(:,2)/60;
Clon=-C(:,3)-C(:,4)/60;

% yes (filled)
SZlat1=[Clat(2);Clat(3);Clat(7);Clat(6)];
SZlon1=[Clon(2);Clon(3);Clon(7);Clon(6)];
SZ1 = [SZlon1 SZlat1]; clear SZl*

% Ambrose to Hudson Canyon Traffic Lane (yes)
HAlat1=[Clat(1);Clat(5)];
HAlon1=[Clon(1);Clon(5)];
HA1 = [HAlon1 HAlat1]; clear HAl*

% Hudson Canyon to Ambrose Traffic Lane (yes)
HAlat2=[Clat(4);Clat(8)];
HAlon2=[Clon(4);Clon(8)];
HA2 = [HAlon2 HAlat2]; clear HAl*

%%%%% Pilot's Area %%%%%
D=[40 27.538 73 49.819;... %Ambrose Light
      40 26.535 73 55.015;...
      40 28.805 73 53.608;...
   	40 27.538 73 49.819];
% yes
Dlat=D(:,1)+D(:,2)/60;
Dlon=-D(:,3)-D(:,4)/60;
D = [Dlon Dlat]; clear Dl*

%%%%%% Nantucket to Ambrose %%%%%
E=[40 24.948 73 41.271;...
   40 25.916 73 40.870;...
   40 26.931 73 40.620;...
   40 27.933 73 40.664;...
   40 19.191 73 12.252;...
   40 24.103 73 11.966;...
   40 27.211 73 12.037;...
   40 32.113 73 12.394];

Elat=E(:,1)+E(:,2)/60;
Elon=-E(:,3)-E(:,4)/60;

% (yes) filled
SZlat2=[Elat(2);Elat(3);Elat(7);Elat(6)];
SZlon2=[Elon(2);Elon(3);Elon(7);Elon(6)];
SZ2 = [SZlon2 SZlat2]; clear SZl*

% Ambrose to Nantucket Traffic Lane (yes)
NAlat1=[Elat(1);Elat(5)];
NAlon1=[Elon(1);Elon(5)];
NA1 = [NAlon1 NAlat1]; clear NAl*

% Nantucket to Ambrose Traffic Lane (yes)
NAlat2=[Elat(4);Elat(8)];
NAlon2=[Elon(4);Elon(8)];
NA2 = [NAlon2 NAlat2]; clear NAl*, clear El*

% aa = axis;
% % don't plot if all pts. are outside of the current scale
% dum = [SZ
%        BA1
%        BA2
%        B
%        SZ1
%        HA1
%        HA2
%        D
%        SZ2
%        NA1
%        NA2];
% if ~any((dum(:,1) >= aa(1) & dum(:,1) <= aa(2)) & (dum(:,2) >= aa(3) & ...
%                                                 dum(:, 2) <= aa(4)))
% 
%   return; % no pts. is inside axis lim.
% end, clear dum

lite_gray = [.9 .9 .9]; % light gray for edges
cc = [.8 1 0]; % light green
%cc2 = [.9 .9 .9]; % edge color (very light grey so it stands out
                  % better against another shaded area
                  % (unavail. music sector), but can't use white
                  % bcs. it becomes black when printing on b&w)
                  

%% location of put_plot_obj_at_bottom
addpath /Users/roarty/Documents/GitHub/HJR_Scripts/maps/
                  
                  
%% Barnegat to Ambrose
h = m_patch(SZ(:, 1), SZ(:, 2), cc, 'edgecolor', lite_gray); hold on
put_plot_obj_at_bottom(h)
h = m_plot([BA1(:, 1)' nan BA2(:, 1)'], [BA1(:, 2)' nan BA2(:, 2)'], ...
         'color', cc, 'linewidth', 2); put_plot_obj_at_bottom(h)
%% Hudson canyon to Ambrose
h = m_patch(SZ1(:, 1), SZ1(:, 2), cc, 'edgecolor', lite_gray);
put_plot_obj_at_bottom(h)
h = m_plot([HA1(:, 1)' nan HA2(:, 1)'], [HA1(:, 2)' nan HA2(:, 2)'], ...
         'color', cc, 'linewidth', 2); put_plot_obj_at_bottom(h)
%% Nantucket to Ambrose
h = m_patch(SZ2(:, 1), SZ2(:, 2), cc, 'edgecolor', lite_gray);
put_plot_obj_at_bottom(h)
h = m_plot([NA1(:, 1)' nan NA2(:, 1)'], [NA1(:, 2)' nan NA2(:, 2)'], ...
         'color', cc, 'linewidth', 2); put_plot_obj_at_bottom(h)

h = m_plot(D(:, 1), D(:, 2), 'g'); put_plot_obj_at_bottom(h) % pilot's area
h = m_plot(B(:, 1), B(:, 2), 'g'); put_plot_obj_at_bottom(h) % Ambrose channel

%clear A*, clear B*, clear C*, clear H*
%clear S*, clear N*, clear D*, clear E*

%axis(aa); % keep the same scale


