%% load the images for the loading to happen give 'er a 1
initialize = 0;
%setdemorandstream(487548172)
linear = 1;
nonlinear = 1;
ntrial = 1;

if initialize
    cali_file = '/home/jericho/Downloads/bin/pcd_planar_imaging/Jericho_sim/run_june_28_lowSN/';
    %cali_file = '/home/jericho/topas/run_june_29_lowSN/Scorer*.csv';
    extract_MC_images_all(cali_file, 'Cali_phantom_8cm_0_3.mat')
    %extract_MC_images('../../Saved Simulations/Contrast_Phantom*', 'Data_contrast_cartilage.mat')
    return
end

A = load('Cali_phantom_8cm_0_3.mat');
B = load('Vali_phantom_8cm_0_3.mat');
% C = load('Cali_MC_top_0_1.mat');
% D = load('Vali_MC_low_0_1.mat');
% E = load('Vali_MC_med_0_1.mat');
% F = load('Vali_MC_top_0_1.mat');

%image_cell = cell(10,1);
%image_cell_val = cell(10,1);


image_cell = A.full_image;
image_cell_val = B.full_image;

figure()
imagesc(squeeze(sum(image_cell_val(1,:,:,:),4)))
% image_cell{3} = C.full_image;
%
% image_cell_val{1} = D.full_image;
% image_cell_val{2} = E.full_image;
% image_cell_val{3} = F.full_image;

%% Generate the real images
global verbose;
global global_n;
global radius;
radius = 5;
verbose = 0;
global_n = 1;


% evec(1) = {[16, 120]};
% evec(2) = {[16, 71.5, 120]}; % vector of the energy bins (unused)
% evec(3) = {[16, 64, 82, 120]};
% evec(4) = {[16, 59, 71.5, 88.5, 120]};
% evec(5) = {[16, 58, 66.6, 78, 92.5, 120]};

evec(1) = {[16, 60]};
evec(2) = {[16, 37.5, 60]}; % vector of the energy bins (unused)
evec(3) = {[16, 33, 42, 60]};
evec(4) = {[16, 30.8, 37.5, 45, 60]};
evec(5) = {[16, 29.3, 34.8, 40, 46.6, 60]};

% evec(1) = {[16, 120]};
% evec(2) = {[16, 71, 120]}; % vector of the energy bins (unused)
% evec(3) = {[16, 64, 82, 120]};
% evec(4) = {[16, 59, 71, 88, 120]};
% evec(5) = {[16, 58, 66, 78, 92, 120]};

noise_vec = 1:10;
n_bins = 5;
n_SNR = 10;
MSE_array_lin = zeros(n_SNR, n_bins);

if linear
    for jj = 4
        
        n = 1;
        
        for quality = 8
            
            cal = squeeze(sum(image_cell(1:quality, :, :, :), 1));
            val = squeeze(sum(image_cell_val(1:quality, :, :, :), 1));
            
            [imcart_2, MSE, noise] = Analysis_DES_linear_plot_3_2(cal, val, cell2mat(evec(jj)));
            
            noise = round(noise);
            
            load('x_0_0')
            load('y_0_0')
            
            x2 = x(1:9);
            y2 = y(1:9);
            x2 = x2(x2 ~= 0);
            y2 = y2(y2 ~= 0);
            
            [ROI, SD] = createContoursSD(imcart_2, x2, y2);
            [ROI_w, SD_w] = createContoursSD(imcart_2, 148, 133);
            
            npts = length(x2);
            CNR = zeros(npts, 2);
            
            %Diff = ROI(1:end);
            Diff = [3.9, 3.4, 2.9, 2.4, 1.9, 1.4, 0.9, 0.4, 0];
            for ii = 1:length(Diff)
                CNR(ii, 1:2) = (ROI(ii) - ROI_w) ./ sqrt(SD(ii, :).^2+mean(SD_w)^2);
            end
            
            
            diff_vec = linspace(0.2, 3.9, 80);
            CNR_1 = pchip(Diff(1:8), CNR(1:8, 1)', diff_vec);
            CNR_2 = pchip(Diff(1:8), CNR(1:8, 2)', diff_vec);
            
            figure(10)
            subplot(3, 5, jj+5)
            h = plot(noise, sqrt(MSE), 'o');
            set(h, 'MarkerFaceColor', get(h, 'Color'));
            hold on
            legendInfo2{n} = sprintf('SNR = %d', noise);
            title('Error (MSE) [cm^2 cartilage]')
            xlabel('SNR')
            ylabel('MSE')
            
            figure(10)
            subplot(3, 5, jj)
            legendInfo{n} = sprintf('SNR = %d', noise);
            title(sprintf('%d Energies Contrast', jj))
            xlabel('Amount of Cartilage [cm]')
            ylabel('CNR (relative to water)')
            xlim([0, 5])
            ylim([0, 30])
            %ciplot(CNR(1:8,1)',CNR(1:8,2)',Diff(1:8),colors(n,:))
            ciplot(CNR_1, CNR_2, diff_vec, get(h, 'Color'))
            hold on
            
            MSE_array_lin(quality, jj) = MSE;
            n = n + 1;
            global_n = global_n + 1;
        end
        %legend(legendInfo2)
        %subplot(3, 5, jj+5)
        %legend(legendInfo2)
        subplot(3, 5, jj)
        %legend(legendInfo)
        camlight;
        lighting gouraud;
        alpha(.75)
        global_n = 0
    end
    subplot(3, 5, jj)
    legend(legendInfo)
end

% these are the layers for the neural network
layers = [1, 12, 14, 12, 2; 5, 12, 10, 13, 2; 3, 20, 20, 15, 17; 4, 13, 19, 8, 17; 5, 13, 13, 12, 12];
layers2 = [4, 12, 21, 12, 6; 3, 16, 16, 10, 8; 5, 16, 16, 15, 16; 5, 14, 15, 11, 15; 2, 15, 17, 16, 12; 3, 20, 13, 9, 10; 3, 21, 12, 9, 15; 6, 11, 19, 10, 10; 1, 16, 9, 15, 16; 1, 16, 9, 16, 11; 1, 19, 16, 14, 11; 1, 17, 13, 10, 4; 6, 13, 12, 13, 17; 6, 17, 17, 14, 12; 1, 15, 14, 14, 15; 4, 11, 12, 16, 18; 1, 19, 17, 15, 10; 5, 18, 19, 14, 3; 2, 14, 14, 9, 15; 4, 12, 19, 12, 2; 4, 13, 10, 12, 18; 4, 11, 20, 11, 9; 6, 13, 9, 9, 5; 5, 19, 16, 7, 6];
ind_layers = [10, 12, 14, 16, 18, 20];

average_layers = [3, 15, 15, 12, 11];
global_n = 1;

n_bins = 5;
n_SNR = 10;
MSE_array = zeros(n_SNR, n_bins);

if nonlinear
    for jj = 4
        
        n = 1;
        
        for quality =8
            
            cal = squeeze(sum(image_cell(1:quality, :, :, :), 1));
            val = squeeze(sum(image_cell_val(1:quality, :, :, :), 1));

%             figure()
%             imagesc(sum(val,3)-sum(cal,3))
            [CNR, MSE, noise] = Analysis_DES_plot_3_2(cal, val, cell2mat(evec(jj)), average_layers(jj), ntrial);
            
            noise = round(noise);
            %Diff =[1.9,1.65,1.4,1.15,0.9,0.65,0.4,0.15];
            %Diff = ROI(1:end);
            Diff = [3.9, 3.4, 2.9, 2.4, 1.9, 1.4, 0.9, 0.4, 0];
            
            
            diff_vec = linspace(0.2, 3.9, 80);
            CNR_1 = pchip(Diff(1:8), CNR(1:8, 1)', diff_vec);
            CNR_2 = pchip(Diff(1:8), CNR(1:8, 2)', diff_vec);
            
            figure(15)
            subplot(3, 5, jj+5)
            h = plot(noise, MSE, 'o');
            set(h, 'MarkerFaceColor', get(h, 'Color'));
            hold on
            legendInfo2{n} = sprintf('SNR = %d', noise);
            title(sprintf('%d Energies Neural Network MSE', jj))
            xlabel('SNR')
            ylabel('MSE [cm^2 cartilage]')
            %xlim([49 251])
            %ylim([0.2, 0.6])
            
            figure(15)
            subplot(3, 5, jj)
            hold on
            legendInfo{n} = sprintf('SNR = %d', noise);
            title(sprintf('%d Energies Contrast', jj))
            xlabel('Amount of Cartilage [cm]')
            ylabel('CNR (relative to water)')
            xlim([0, 5])
            ylim([0, 30])
            %ciplot(CNR(1:8,1)',CNR(1:8,2)',Diff(1:8),colors(n,:))
            ciplot(CNR_1, CNR_2, diff_vec, get(h, 'Color'))
            
            MSE_array(quality, jj) = MSE;
            
            n = n + 1;
            global_n = global_n + 1;
        end
        
        %legend(legendInfo2)
        subplot(3, 5, jj+5)
        %legend(legendInfo2)
        %subplot(3,5,jj)
        %legend(legendInfo)
        camlight;
        lighting gouraud;
        alpha(.75)
        global_n = 0;
    end
    subplot(3, 5, jj)
    legend(legendInfo)
end