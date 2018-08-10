%% Reading in the Monte Carlo code
% 
% filename = '/home/jericho/topas/Jericho_sims/phantomDose_test120kVp_3.csv';
% 
% Data = csvread(filename,10,0);
% 
% Data(:,[2 3]) = Data(:,[2 3]) + 1;
% all_counts = sum(Data(:,4:end),2);
% 
% MC_image = reshape(Data(:,4),100,100);
% ac_image = reshape(all_counts,100,100);
% 
% figure(2)
% mesh(MC_image)
% 
% figure(3)
% imagesc(MC_image)
% 
% figure(4)
% mesh(ac_image)


% filename = '/home/jericho/topas/Jericho_sims/phantomDose_test120kVp_4.csv';
% 
% Data = csvread(filename,8,0);
% 
% Data(:,[2 3]) = Data(:,[2 3]) + 1;
% all_counts = sum(Data(:,4:end),2);
% 
% MC_image = reshape(Data(:,4),3,3);
% ac_image = reshape(all_counts,3,3);
% 
% figure(2)
% mesh(MC_image)
% 
% figure(3)
% imagesc(MC_image)
% 
% figure(4)
% mesh(ac_image)

% filename = '/home/jericho/topas/Jericho_sims/phantomDose_test120kVp_5.csv';
% 
% Data = csvread(filename,8,0);
% 
% Data(:,[2 3]) = Data(:,[2 3]) + 1;
% all_counts = sum(Data(:,4:end),2);
% 
% MC_image = reshape(Data(:,4),10,10);
% ac_image = reshape(all_counts,10,10);
% 
% figure(2)
% mesh(MC_image)
% 
% figure(3)
% imagesc(MC_image)
% 
% figure(4)
% surf(ac_image)

% filename = '/home/jericho/topas/Jericho_sims/phantomDose_test120kVp_6.csv';
% 
% Data = csvread(filename,8,0);
% 
% Data(:,[2 3]) = Data(:,[2 3]) + 1;
% all_counts = sum(Data(:,4:end),2);
% 
% MC_image = reshape(Data(:,4),10,10);
% ac_image = reshape(all_counts,10,10);
% 
% figure(2)
% mesh(MC_image)
% 
% figure(3)
% imagesc(MC_image)
% 
% figure(4)
% surf(ac_image)

%% Reading in the Monte Carlo code

filename = '/home/jericho/Downloads/bin/pcd_planar_imaging/Jericho_sim/phantomDose_test120kVp_32.csv';

Data = csvread(filename,10,0);

Data(:,[2 3]) = Data(:,[2 3]) + 1;
all_counts = sum(Data(:,4:end),2);

%MC_image = reshape(Data(:,4),100,100);
ac_image = reshape(all_counts,100,100);

% figure(2)
% mesh(MC_image)
% 
% figure(3)
% imagesc(MC_image)

figure(4)
surf(ac_image)


figure
imagesc(ac_image)


nbins = length(Data(1,4:end));
figure
hold on

for ii = 1:nbins
    subplot(2,ceil(nbins/2),ii)
    energy_image = reshape(Data(:,3 + ii),100,100);
    imagesc(energy_image)
    axis image
    axis off
    %colormap gray
    title(sprintf('Energy Bin %d',ii))
    colorbar
    caxis([0 2])
end

subplot(2,ceil(nbins/2),8)
imagesc(ac_image)
axis image
axis off
%colormap gray
title('Whole Image (All counts)')
colorbar
caxis([0 2])

[ROI, SD] = createContoursSD(ac_image, 50, 50);

ROI/mean(SD)


