
ZZ = [
    0.4523




     4




    0.4488




     3




    0.4287




     5




    0.4365




     5




    0.4459




     2




    0.4356




     3




    0.4254




     3




    0.4222




     6




    0.4284




     1




    0.4151




     1




    0.4433




     1




    0.4293




     1




    0.4230




     6




    0.4370




     6




    0.4371




     1




    0.4486




     4




    0.4413




     1




    0.4748




     5




    0.5129




     2




    0.5373




     4




    0.5780




     4




    0.6514




     4




    0.8016




     6




    1.0704




     5




    0.3755




    12




    0.3898




    16




    0.3924




    16




    0.3836




    14




    0.3892




    15




    0.3649




    20




    0.3929




    21




    0.4008




    11




    0.3791




    16




    0.3951




    16




    0.3904




    19




    0.3926




    17




    0.3921




    13




    0.4108




    17




    0.4090




    15




    0.4235




    11




    0.4376




    19




    0.4338




    18




    0.4773




    14




    0.5128




    12




    0.5453




    13




    0.6693




    11




    0.8347




    13




    1.0944




    19




    0.3204




    21




    0.3218




    16




    0.3310




    16




    0.3203




    15




    0.3230




    17




    0.3200




    13




    0.3121




    12




    0.3215




    19




    0.3270




     9




    0.3357




     9




    0.3361




    16




    0.3307




    13




    0.3420




    12




    0.3667




    17




    0.3665




    14




    0.3937




    12




    0.3989




    17




    0.4190




    19




    0.4372




    14




    0.4915




    19




    0.5376




    10




    0.6341




    20




    0.7193




     9




    1.0272




    16




    0.2662




    12




    0.2693




    10




    0.2683




    15




    0.2782




    11




    0.2639




    16




    0.2673




     9




    0.2616




     9




    0.2730




    10




    0.2632




    15




    0.2679




    16




    0.2726




    14




    0.2790




    10




    0.2713




    13




    0.2662




    14




    0.2855




    14




    0.2997




    16




    0.3085




    15




    0.3465




    14




    0.3552




     9




    0.3891




    12




    0.4551




    12




    0.5441




    11




    0.6800




     9




    0.9599




     7




    0.2900




     6




    0.2837




     8




    0.2996




    16




    0.2889




    15




    0.2893




    12




    0.2906




    10




    0.2933




    15




    0.3087




    10




    0.3104




    16




    0.3077




    11




    0.3107




    11




    0.3135




     4




    0.3115




    17




    0.3334




    12




    0.3233




    15




    0.3438




    18




    0.3482




    10




    0.3855




     3




    0.3930




    15




    0.4403




     2




    0.4531




    18




    0.5321




     9




    0.6670




     5




    0.9334




     6];
 
 ZZ = reshape(ZZ,2,120);
 Z2 = reshape(ZZ(1,:),24,5);
 Z3 = reshape(ZZ(2,:),24,5);
 
 yvec = 250:-10:20;
 xvec = 1:5;
 
 YY = repmat(yvec',[1,5]);
 XX = repmat(xvec,[24,1]);
 
 figure
 surf(XX,YY,Z2)
 
 [x,y] = meshgrid(1:0.1:5,250:-1:20);
 z = griddata(XX,YY,Z2,xq,yq,'cubic');
 
 figure
 surfc(x,y,z)
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
 