axesm utm
h = getm(gca);
h.zone

setm(gca,'zone','18t')
h = getm(gca);
setm(gca,'grid','on','meridianlabel','on','parallellabel','on')

load coastlines
plotm(coastlat,coastlon)