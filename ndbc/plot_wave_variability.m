
load 2017_NDBC_Data.mat


dtime=datenum(2017,1,1):1/24:datenum(2018,1,1);

data_column=5;


D1 = interp1(Data{1}(:,1),Data{1}(:,data_column),dtime);
D2 = interp1(Data{2}(:,1),Data{2}(:,data_column),dtime);
D3 = interp1(Data{3}(:,1),Data{3}(:,data_column),dtime);

X=vertcat(D1,D2,D3);

S=mean(X);
V=std(X);

hold on
plot(dtime,D1)
plot(dtime,D2)
plot(dtime,D3)

