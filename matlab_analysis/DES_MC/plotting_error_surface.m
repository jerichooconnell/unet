%Making surface plot 

 %Z2 = MSE_array_lin;
 Z2 = MSE_array;
 
 yvec = [45 55 70 78 84 92 101 112 120 124];
 xvec = 1:5;
 
 YY = repmat(yvec',[1,5]);
 XX = repmat(xvec,[10,1]);
 
 figure
 surf(XX,YY,Z2)
 
 [x,y] = meshgrid(1:0.05:5,125:-1:45);
 z = griddata(XX,YY,Z2,x,y,'cubic');
 
 figure
 surf(x,y,z)
 hold on
 plot3(XX,YY,Z2,'k*')
 
 
 
 % get the corners of the domain in which the data occurs.
min_x = min(min(x));
min_y = min(min(y));
max_x = max(max(x));
max_y = max(max(y));
 
% the image data you want to show as a plane.
planeimg = abs(z);
 
% scale image between [0, 255] in order to use a custom color map for it.
minplaneimg = min(min(planeimg)); % find the minimum
scaledimg = (floor(((planeimg - minplaneimg) ./ ...
    (max(max(planeimg)) - minplaneimg)) * 255)); % perform scaling
 
% convert the image to a true color image with the jet colormap.
colorimg = ind2rgb(scaledimg,jet(256));
 
 % set hold on so we can show multiple plots / surfs in the figure.
figure(3); hold on;
plot3(XX,YY,Z2,'kp') 
 
% do a normal surface plot.
surf(x,y,z,'edgecolor','none');
 
% set a colormap for the surface
colormap(jet(256));
 
% % desired z position of the image plane.
% imgzposition = -0.2;
%  
% % plot the image plane using surf.
% surf([min_x max_x],[max_y min_y],repmat(imgzposition, [2 2]),...
%     colorimg,'facecolor','texture')
 
% set the view.
view(139,20);
 
% label the axes
xlabel('# Energy Bins','FontName','Times');
ylabel('SNR','FontName','Times');
zlabel('RMSE [cm cartilage]','FontName','Times');
title('Error Surface','FontName','Palatino')

camlight; lighting gouraud;
alpha(.75)

xticks([1 2 3 4 5])