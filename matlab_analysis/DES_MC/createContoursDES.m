function [value1,value2,value3] = createContoursDES(imavg,varargin)
%% Changing to HU values (optional)
manualROI = 0; %0 for automatic

% Determine background and foreground values to properly normalized the
% data to range [0,1]
if manualROI == 0
    if strcmp(varargin,'val')
        load('ptROIval')
        load('ptROIval2')
    else
        load('ptROI')
        load('ptROI2')
        load('ptROI3')
    end
else
    figure
    imagesc(imavg)
    xlabel('pixel')
    ylabel('pixel')
    colormap gray
    hold on
    axis image;
    impixelinfo;
    
    fprintf('Click and drag to create a rectangular ROI representing the background.  Double click the ROI when finished.\n\n');
    
    h = imrect;
    ptROI = wait(h);
    
    fprintf('Click and drag to create a rectangular ROI representing the foreground.  Double click the ROI when finished.\n\n');
    
    h = imrect;
    ptROI2 = wait(h);
    
    h = imrect;
    ptROI3 = wait(h);
    

    save('ptROI','ptROI')
    save('ptROI2','ptROI2')
    save('ptROI3','ptROI3')

end

BGxROI1 = round(ptROI(1));
BGxROI2 = BGxROI1 + round(ptROI(3));
BGyROI1 = round(ptROI(2));
BGyROI2 = BGyROI1 + round(ptROI(4));

% force selected ROI to be within the bounds of the image
BGxROI1 = min(BGxROI1,size(imavg,2));
BGxROI2 = min(BGxROI2,size(imavg,2));
BGyROI1 = min(BGyROI1,size(imavg,1));
BGyROI2 = min(BGyROI2,size(imavg,1));
BGxROI1 = max(BGxROI1,1);
BGxROI2 = max(BGxROI2,1);
BGyROI1 = max(BGyROI1,1);
BGyROI2 = max(BGyROI2,1);

value1 = mean(mean(imavg(BGyROI1:BGyROI2,BGxROI1:BGxROI2)));

FGxROI1 = round(ptROI2(1));
FGxROI2 = FGxROI1 + round(ptROI2(3));
FGyROI1 = round(ptROI2(2));
FGyROI2 = FGyROI1 + round(ptROI2(4));

% force selected ROI to be within the bounds of the image
FGxROI1 = min(FGxROI1,size(imavg,2));
FGxROI2 = min(FGxROI2,size(imavg,2));
FGyROI1 = min(FGyROI1,size(imavg,1));
FGyROI2 = min(FGyROI2,size(imavg,1));
FGxROI1 = max(FGxROI1,1);
FGxROI2 = max(FGxROI2,1);
FGyROI1 = max(FGyROI1,1);
FGyROI2 = max(FGyROI2,1);

value2 = mean(mean(imavg(FGyROI1:FGyROI2,FGxROI1:FGxROI2)));

FGxROI1 = round(ptROI3(1));
FGxROI2 = FGxROI1 + round(ptROI3(3));
FGyROI1 = round(ptROI3(2));
FGyROI2 = FGyROI1 + round(ptROI3(4));

% force selected ROI to be within the bounds of the image
FGxROI1 = min(FGxROI1,size(imavg,2));
FGxROI2 = min(FGxROI2,size(imavg,2));
FGyROI1 = min(FGyROI1,size(imavg,1));
FGyROI2 = min(FGyROI2,size(imavg,1));
FGxROI1 = max(FGxROI1,1);
FGxROI2 = max(FGxROI2,1);
FGyROI1 = max(FGyROI1,1);
FGyROI2 = max(FGyROI2,1);

value3 = mean(mean(imavg(FGyROI1:FGyROI2,FGxROI1:FGxROI2)));

% figure()
% imagesc(imavg)
% hold on
% plot([BGxROI1,BGxROI2,BGxROI2,BGxROI1,BGxROI1],[BGyROI1,BGyROI1,BGyROI2,BGyROI2,BGyROI1],'r-')
% plot([FGxROI1,FGxROI2,FGxROI2,FGxROI1,FGxROI1],[FGyROI1,FGyROI1,FGyROI2,FGyROI2,FGyROI1],'r-')

% Normalize averaged image such that values are [0,1]

%figure
%imagesc(HU)
end