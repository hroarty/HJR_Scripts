clear all 
close all

NDBC_Dir ='/Users/hroarty/data/NDBC/44009';
NDBC_Files = dir([NDBC_Dir '/*.txt']);



% NDBC_Path = dir2cell(NDBC_Files , NDBC_Dir );
% 
% %% preallocate the variables so you can cat them in the loop
% TME=[];
% 
% 
% for jj = 1:length(NDBC_Path)
%   [tme,data] = load_noaabuoy(NDBC_Path{jj});
%   TME=[TME;tme];
%   if jj == 1
%       DATA=data;
%   end
%   
%   if jj>1
%       %DATA=catstruct(DATA,data);  %% didnt work
%       %DATA = mergestruct(DATA,data) %% didnt work
%       cell2struct( ...
%         cat(1,struct2cell(DATA),struct2cell(data)), ...
%         cat(1,fieldnames(DATA),fieldnames(data)), ...
%         1)
%   end
%   
% end

[Data]=NDBC_monthly_readin_func(NDBC_Dir,'txt');


