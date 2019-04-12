function put_plot_obj_at_bottom(h)
% put_plot_obj_at_bottom(int* plot_handle)
%
% put the plot obj. (handle) @ bottom (as if it was plotted first).  useful
% if you want to to move a patch or fill plot which is plotted later to be
% _below_ s.t. it does NOT obcure other plots

hall = get(gca, 'children');

Nh = length(h);
for n = 1 : Nh
  ind = (hall == h(n));
  hall = [hall(~ind)
          h(n)]; % move this to bottom of the stack
end, clear ind

% put grids on top
try set(gca, 'children', hall, 'layer', 'top'), catch, end