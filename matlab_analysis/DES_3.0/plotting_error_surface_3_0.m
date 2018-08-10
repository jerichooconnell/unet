%Making surface plot 
% run it twice
close all

 load('MSE_array_0_0.mat')
 load('MSE_lin_0_0.mat')
 
 ZZ = MSE_array_lin';
 Z2 = MSE_array';
 
 yvec = 10:10:250;
 xvec = 1:5;
 
 YY = repmat(yvec',[1,5])';
 XX = repmat(xvec,[25,1])';
 
[x,y] = meshgrid(1:0.05:5,250:-1:10);
z = griddata(XX,YY,Z2,x,y,'cubic');
z2 = griddata(XX,YY,ZZ,x,y,'cubic');
 
 % set hold on so we can show multiple plots / surfs in the figure.
figure(1); hold on;
subplot(131)
p1 = plot3(XX,YY,ZZ,'k+','MarkerSize',2);
hold on
p2 = plot3(XX,YY,Z2,'r+','MarkerSize',2);

% do a normal surface plot.
surf(x,y,z,'edgecolor','none');
hold on
surf(x,y,z2,'edgecolor','none');

legend([p1(1) p2(1)],{'linear','non-linear'},'location','west','FontName','Liberation Serif','FontSize',16);
% set a colormap for the surface
colormap(jet(256));
 
% set the view.
view(136,10);
axis square
 
% label the axes
xlabel('# Energy Bins','FontName','Liberation Serif','FontSize',16);
ylabel('SNR','FontName','Liberation Serif','FontSize',16);
zlabel('MSE [cm^2 cartilage]','FontName','Liberation Serif','FontSize',16);
title('Linear v. non-linear, cone-beam','FontName','Liberation Serif','FontSize',22)

camlight; lighting gouraud;
alpha(.75)

xticks([1 2 3 4 5])

load('../DES_MC/MSE_array.mat')
load('../DES_MC/MSE_array_lin.mat')

 Z3 = MSE_array_lin';
 Z4 = MSE_array';
 
 yvec = [45 55 70 78 84 92 101 112 120 124];
 xvec = 1:5;
 
 YY2 = repmat(yvec',[1,5])';
 XX2 = repmat(xvec,[10,1])';
 
%  figure
%  surf(XX,YY,Z2)
 
 [x,y] = meshgrid(1:0.05:5,125:-1:45);
 z3 = griddata(XX2,YY2,Z3,x,y,'cubic');
 z4 = griddata(XX2,YY2,Z4,x,y,'cubic');
 
 % set hold on so we can show multiple plots / surfs in the figure.
figure(1); hold on;
subplot(132)
p1 = plot3(XX2,YY2,Z3,'ko','MarkerSize',2);
hold on
p2 = plot3(XX2,YY2,Z4,'ro','MarkerSize',2);
 
% do a normal surface plot.
surf(x,y,z3,'edgecolor','none');
hold on
surf(x,y,z4,'edgecolor','none');
 
legend([p1(1) p2(1)],{'linear','non-linear'},'location','west','FontName','Liberation Serif','FontSize',16);
% set a colormap for the surface
colormap(jet(256));

% set the view.
view(136,10);
axis square
 
% label the axes
xlabel('# Energy Bins','FontName','Liberation Serif','FontSize',16);
ylabel('SNR','FontName','Liberation Serif','FontSize',16);
zlabel('MSE [cm^2 cartilage]','FontName','Liberation Serif','FontSize',16);
title('Linear v. non-linear, pencil-beam','FontName','Liberation Serif','FontSize',22)

camlight; lighting gouraud;
alpha(.75)

xticks([1 2 3 4 5])

figure(1); hold on;
subplot(133)
p1 = plot3(XX,YY,Z2,'k+','MarkerSize',4);%,'DisplayName','linear');
hold on
p2 = plot3(XX2,YY2,Z4,'rd','MarkerSize',4);%,'DisplayName','non-linear');

 

hold on
surf(x,y,z4,'edgecolor','none');
% do a normal surface plot.
[x,y] = meshgrid(1:0.05:5,250:-1:10);
surf(x,y,z,'edgecolor','none');
ylim([45,125])
zlim([0,0.4])
 

legend([p1(1) p2(1)],{'Cone-beam','Pencil-beam'},'location','west','FontName','Liberation Serif','FontSize',16);
% set a colormap for the surface
colormap(jet(256));
 
% set the view.
view(134,12);
axis square
 
% label the axes
xlabel('# Energy Bins','FontName','Liberation Serif','FontSize',16);
ylabel('SNR','FontName','Liberation Serif','FontSize',16);
zlabel('MSE [cm^2 cartilage]','FontName','Liberation Serif','FontSize',16);
title('Non-linear comparison','FontName','Liberation Serif','FontSize',22)

camlight; lighting gouraud;
alpha(.75)

xticks([1 2 3 4 5])


%% Litle aside for plotting for REDLEN
load('MSE_array_0_0.mat')
load('MSE_lin_0_0.mat')

 ZZ = MSE_array_lin';
 Z2 = MSE_array';
 
 yvec = 10:10:250;
 xvec = 1:5;
 
 YY = repmat(yvec',[1,5])';
 XX = repmat(xvec,[25,1])';

[x,y] = meshgrid(1:0.05:5,250:-1:10);
z = griddata(XX,YY,Z2,x,y,'cubic');
z2 = griddata(XX,YY,ZZ,x,y,'cubic');
 
figure()
plot(1:5,MSE_array(1,:),'r*')
hold on
plot(1:5,MSE_array(2,:),'b*')
plot(1:5,MSE_array(3,:),'y*')
% plot(1:0.05:5,z(end,:),'r')
% hold on
% plot(1:0.05:5,z(end-10,:),'b')
% plot(1:0.05:5,z(end-20,:),'y')
xticks([1 2 3 4 5])
xlabel('# Energy Bins','FontName','Liberation Serif','FontSize',16);
ylabel('MSE [cm^2 cartilage]','FontName','Liberation Serif','FontSize',16);
legend('SNR = 10','SNR = 20','SNR = 30')
title('Low signal to noise error vs. energy binning')