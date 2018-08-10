function ML_vec = returnContours2(im,x,y,t_hard,t_soft,varargin)
%**************************************************************************
% Creates the regions of interest in the image.
%
% im = image as a double array
% x, y = coordinates of ROIs
% varargin = 'top','bottom' returns semicircular ROIs
% varargin = 'firsthalf', 'secondhalf' returns 5/10 rois
%**************************************************************************
% Create empty mask.
[rr, cc] = meshgrid(1:size(im,2),1:size(im,1));
npts = length(x);
BW = false(size(im));
ROI = zeros(npts,1);
STD = zeros(npts,1);
SNR = zeros(npts,1);
CNR = zeros(npts,npts);
ML_vec = [0;0;0];
%%
% Check input
if(exist('y','var')==0),fprintf('Select the center of insert IN ORDER: 10,5,7,4,8,6,2,3,1,9 \n \n'),fprintf('Press Enter when done');
figure, imshow(im,[]); [y,x]=getpts; y=round(y); x=round(x); end

%%
% radius of the area taken
% if double(varargin) == 4
%     radius = 4;
% elseif double(varargin) == 3
     radius = 5;
% else
%     radius = 5; 
% end
    %%
% Case of first and second halves
if strcmp(varargin,'firsthalf')
    nn = 0;
    oo = 1;
elseif strcmp(varargin,'secondhalf')
    nn = 1;
    oo = 1;
else
    nn = 0;
    oo = 0;
end
%%
for pp = 1+nn:1+oo:npts

    % Making a logical array of values to keep
    if strcmp(varargin,'bottom') %bottom half of the circle
        addedRegion = sqrt(radius.^2 - (rr-x(pp)).^2) + y(pp) >= cc;
        subtractedRegion = y(pp) >=cc;
        addedRegion(subtractedRegion) = 0;
    elseif strcmp(varargin,'top') % tops of circles, takes full circle and subtracts bottom
        addedRegion = sqrt(radius.^2 - (rr-x(pp)).^2) + y(pp) > cc;
        subtractedRegion_b = y(pp) >=cc;
        addedRegion(subtractedRegion_b) = 0;
    else
        addedRegion = sqrt((rr-x(pp)).^2+(cc-y(pp)).^2)<= radius;
    end
    
    BW = BW | addedRegion;
    temp = im(addedRegion);
    temp = squeeze(temp);
    temp2 = ones(size(temp))*t_soft(pp);
    temp4 = ones(size(temp))*t_hard(pp);
    temp3 = cat(2,temp2,temp4,temp);
    ML_vec = cat(2,ML_vec,temp3');
    ROI(pp) = nanmean(temp);
    STD(pp) = std(double(temp));
    SNR(pp) = ROI(pp)/STD(pp);
end
global verbose;
if verbose > 3
    maskedImage = im;
    maskedImage(BW) = 0;
    figure(77), imagesc(maskedImage)
end
end
