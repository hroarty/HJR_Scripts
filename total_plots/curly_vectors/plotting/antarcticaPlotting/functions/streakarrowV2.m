function hh=streakarrow(X0,Y0,U,V,np,arrow)

%H = STREAKARROW(X,Y,U,V,np,arrow) creates "curved" vectors, from 
% 2D vector data U and V. All vectors have the same length. The
% magnitude of the vector is color coded.
% The arrays X and Y defines the coordinates for U and V.
% The variable np is a coefficient >0, changing the length of the vectors.
%     np=1 corresponds to a whole meshgrid step. np>1 allows ovelaps like
%     streamlines.
% The parameter arrow defines the type of plot: 
%   arrow=1 draws "curved" vectors
%   arrow=0 draws circle markers with streaks like "tuft" in wind tunnel
%   studies

% Example:
    %load wind
    %N=5; X0=x(:,:,N); Y0=y(:,:,N); U=u(:,:,N); V=v(:,:,N);
    %H=streakarrow(X0,Y0,U,V,1.5,0); box on; 
    
% Bertrand Dano 10-25-08
% Copyright 1984-2008 The MathWorks, Inc. 


    
DX=abs(X0(1,1)-X0(1,2)); 
DY=abs(Y0(1,1)-Y0(2,1)); 

DD=min([DX DY]);

ks=DD/100;      % Size of the "dot" for the tuft graphs
np=np*10;   
% alpha = 5;  % Size of arrow head relative to the length of the vector
% beta = .25; % Width of the base of the arrow head relative to the length


%prepare data for stream2 function
%first check for uniform grid 
dx=abs(diff(X0(1,:)));
dy=abs(diff(Y0(:,1)));
maxDiff=0.01;

%if grid is not regular (like my curvilinear model output),
%reshape into regular grid using grid-cell averaging
if any(diff(dx)>maxDiff) || any(diff(dy)>maxDiff) || ...
        any(isnan(dx)) || any(isnan(dy))
    fprintf(['Non-uniform grid detected, re-binning data ',...
        'onto square grid...\n'])
    
    [m,n]=size(X0);
    minx=min(X0(:));
    maxx=max(X0(:));
    miny=min(Y0(:));
    maxy=max(Y0(:));
    
    %decrease the resolution of the grid by 2
    xi=linspace(minx,maxx,round(n/3));
    yi=linspace(miny,maxy,round(m/3));
    [Xm,Ym]=meshgrid(xi,yi);
    
    Um=bin2mat(X0(:),Y0(:),U(:),Xm,Ym);
    Um(isnan(Um))=0;
    Vm=bin2mat(X0(:),Y0(:),V(:),Xm,Ym);
    Vm(isnan(Vm))=0;
else
    [Um,Vm,Xm,Ym]=deal(U,V,X0,Y0);
end

%replace non-finite velocity with zero
Um(~isfinite(Um))=0;
Vm(~isfinite(Vm))=0;

% XY=stream2(X0,Y0,U,V,X0,Y0);
XY=stream2(Xm,Ym,Um,Vm,Xm,Ym);

%np=15;
Vmag=sqrt(U.^2+V.^2);
Vmin=min(Vmag(:)); Vmax=max(Vmag(:));
Vmag=Vmag(:); x0=X0(:); y0=Y0(:);

%ks=.1;
cmap=colormap;
for k=1:length(XY)
    F=XY(k); [L M]=size(F{1});
        if L<np
            F0{1}=F{1}(1:L,:);
            if L==1
                F1{1}=F{1}(L,:);
            else
                F1{1}=F{1}(L-1:L,:);
            end
            
        else
            F0{1}=F{1}(1:np,:);
            F1{1}=F{1}(np-1:np,:);
        end
    P=F1{1};
    vcol=floor((Vmag(k)-Vmin)./(Vmax-Vmin)*64); if vcol==0; vcol=1; end
%     COL=[cmap(vcol,1) cmap(vcol,2) cmap(vcol,3)];
    hh=streamline(F0);
%     set(hh,'color',COL,'linewidth',.5);

%     if arrow==1&L>1
       x1=P(1,1); y1=P(1,2); x2=P(2,1); y2=P(2,2);
       u=x1-x2; v=y1-y2; u=-u; v=-v; 
       ialpha = ones(length(x2),1) .* 2.75;
       ibeta = ones(length(x2),1) .* 0.194444444444444;
       xa1=x2+u-alpha*(u+ibeta*(v+eps)); xa2=x2+u-ialpha*(u-ibeta*(v+eps));
       ya1=y2+v-alpha*(v-ibeta*(u+eps)); ya2=y2+v-ialpha*(v+ibeta*(u+eps));
       plot([xa1 x2 xa2],[ya1 y2 ya2],'color','black'); hold on
%     else
%         rectangle('position',[x0(k)-ks/2 y0(k)-ks/2 ks ks],'curvature',[1 1],'facecolor',COL, 'edgecolor',COL)
%     end
    
            
     
end

axis image

%%%%-subfunction-----------------------------------------------------------
function ZG = bin2mat(x,y,z,XI,YI,varargin)
% BIN2MAT - create a matrix from scattered data without interpolation
% 
%   ZG = BIN2MAT(X,Y,Z,XI,YI) - creates a grid from the data 
%   in the (usually) nonuniformily-spaced vectors (x,y,z) 
%   using grid-cell averaging (no interpolation). The grid 
%   dimensions are specified by the uniformily spaced vectors
%   XI and YI (as produced by meshgrid). 
%
%   ZG = BIN2MAT(...,@FUN) - evaluates the function FUN for each
%   cell in the specified grid (rather than using the default
%   function, mean). If the function FUN returns non-scalar output, 
%   the output ZG will be a cell array.
%
%   ZG = BIN2MAT(...,@FUN,ARG1,ARG2,...) provides aditional
%   arguments which are passed to the function FUN. 
%
%   EXAMPLE
%    
%   %generate some scattered data
%    [x,y,z]=peaks(150);
%    ind=(rand(size(x))>0.9);
%    xs=x(ind); ys=y(ind); zs=z(ind);
%
%   %create a grid, use lower resolution if 
%   %no gaps are desired
%    xi=min(xs):0.25:max(xs);
%    yi=min(ys):0.25:max(ys);
%    [XI,YI]=meshgrid(xi,yi);
%
%   %calculate the mean and standard deviation
%   %for each grid-cell using bin2mat
%    Zm=bin2mat(xs,ys,zs,XI,YI); %mean 
%    Zs=bin2mat(xs,ys,zs,XI,YI,@std); %std
%  
%   %plot the results 
%    figure 
%    subplot(1,3,1);
%    scatter(xs,ys,10,zs,'filled')
%    axis image
%    title('Scatter Data')    
%
%    subplot(1,3,2);
%    pcolor(XI,YI,Zm)
%    shading flat
%    axis image
%    title('Grid-cell Average')
%
%    subplot(1,3,3);
%    pcolor(XI,YI,Zs)
%    shading flat
%    axis image
%    title('Grid-cell Std. Dev.')   
%   
% SEE also RESHAPE ACCUMARRAY FEVAL   

% A. Stevens 3/10/2009
% astevens@usgs.gov

%check inputs
error(nargchk(5,inf,nargin,'struct'));

%make sure the vectors are column vectors
x = x(:);
y = y(:);
z = z(:);

if all(any(diff(cellfun(@length,{x,y,z}))));
    error('Inputs x, y, and z must be the same size');
end

%process optional input
fun=@mean;
test=1;
if ~isempty(varargin)
    fun=varargin{1};
    if ~isa(fun,'function_handle');
        fun=str2func(fun);
    end
    
    %test the function for non-scalar output
    test = feval(fun,rand(5,1),varargin{2:end});
    
end

%grid nodes
xi=XI(1,:);
yi=YI(:,1);
[m,n]=size(XI);

%limit values to those within the specified grid
xmin=min(xi);
xmax=max(xi);
ymin=min(yi);
ymax=max(yi);

gind =(x>=xmin & x<=xmax & ...
    y>=ymin & y<=ymax);

%find the indices for each x and y in the grid
[junk,xind] = histc(x(gind),xi);
[junk,yind] = histc(y(gind),yi);

%break the data into a cell for each grid node
blc_ind=accumarray([yind xind],z(gind),[m n],@(x){x},{NaN});

%evaluate the data in each grid using FUN
if numel(test)>1
    ZG=cellfun(@(x)(feval(fun,x,varargin{2:end})),blc_ind,'uni',0);
else
    ZG=cellfun(@(x)(feval(fun,x,varargin{2:end})),blc_ind);
end
%colorbar vert
%h=colorbar; 
%set(h,'ylim',[Vmin Vmax])

