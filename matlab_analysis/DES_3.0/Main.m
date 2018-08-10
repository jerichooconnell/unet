
%% Main
close all

%% load the images
initialize = 0;
setdemorandstream(487548172)
linear = 0;
nonlinear = 1;

if initialize
    extract_all_data('../../Saved Simulations/Three*', 'Three_Contrast.mat')
    extract_all_data('../../Saved Simulations/Contrast_Phantom*', 'Data_contrast_cartilage.mat')
    return
end

Q = load('Contrast_3_1_val.mat');
P = load('Contrast_3_2.mat');

fields = fieldnames(P);

cal = P.(fields{1});

for ii = 2:length(fields)
    
    cal = cat(3, cal, P.(fields{ii}));
    
end

field = fieldnames(Q);

val = Q.(field{1});

for ii = 2:length(field)
    
    val = cat(3, val, Q.(field{ii}));
    
end

%% Generate the real images
global verbose;
global global_n;
verbose = 0;
global_n = 1;

% for ii = 1:10
%     figure
%     imagesc(cal(:,:,ii))
% end
evec(1) = {[16, 120]};
evec(2) = {[16, 71.5, 120]}; % vector of the energy bins (unused)
evec(3) = {[16, 64, 82, 120]};
evec(4) = {[16, 59, 71.5, 88.5, 120]};
evec(5) = {[16, 58, 66.6, 78, 92.5, 120]};

inds(1) = {[1]};
inds(2) = {[1, 6]}; % controls which of the calibration images to use
inds(3) = {[1, 4, 8]};
inds(4) = {[1, 3, 6, 9]};
inds(5) = {[1, 2, 4, 7, 10]};

%Analysis_DES_factor(cal(:,:,cell2mat(inds(jj))),val(:,:,cell2mat(inds(jj))'),cell2mat(evec(jj)),noise);

colors = [[141, 211, 199]; [255, 237, 111]; [190, 186, 218]; [251, 128, 114]; [128, 177, 211]; [253, 180, 98]; [179, 222, 105]; [188, 128, 189]; [217, 217, 217]; [204, 235, 197]; [252, 205, 229]; [255, 255, 179]] ./ 255;


if linear
for jj = 1:5
    
    n = 1;
    
    for noise = 260:-50:10
        [imcart_2, MSE] = Analysis_DES_linear(cal(:, :, cell2mat(inds(jj))), val(:, :, cell2mat(inds(jj))'), cell2mat(evec(jj)), noise);
        %[imsoft_2, imcart_2,MSE] = Analysis_DES(cal(:,:,cell2mat(inds(jj))),val(:,:,cell2mat(inds(jj))'),cell2mat(evec(jj)),noise);
        
        load('x_3_0')
        load('y_3_0')
        
        x2 = x(1:9);
        y2 = y(1:9);
        x2 = x2(x2 ~= 0);
        y2 = y2(y2 ~= 0);
        
        [ROI, SD] = createContoursSD(imcart_2, x2, y2);
        [ROI_w, SD_w] = createContoursSD(imcart_2, 201, 198);
        
        npts = length(x2);
        CNR = zeros(npts, 2);
        
        %Diff = ROI(1:end);
        Diff = [3.9, 3.4, 2.9, 2.4, 1.9, 1.4, 0.9, 0.4, 0];
        for ii = 1:length(Diff)
            CNR(ii, 1:2) = (ROI(ii) - ROI_w) ./ sqrt(SD(ii, :).^2+mean(SD_w)^2);
        end
        
        
        diff_vec = linspace(0.4, 3.9, 80);
        CNR_1 = pchip(Diff(1:8), CNR(1:8, 1)', diff_vec);
        CNR_2 = pchip(Diff(1:8), CNR(1:8, 2)', diff_vec);
        
        figure(10)
        subplot(3, 5, jj+5)
        h = plot(noise, MSE, 'o');
        set(h, 'MarkerFaceColor', get(h, 'Color'));
        hold on
        legendInfo2{n} = sprintf('SNR = %d', noise);
        title('Error (MSE) [cm cartilage]')
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
        
        MSE_array_lin(noise/10, jj) = MSE;
        
        n = n + 1;
        global_n = global_n + 1;
    end
    %legend(legendInfo2)
    %subplot(3, 5, jj+5)
    %legend(legendInfo2)
    subplot(3, 5, jj)
    legend(legendInfo)
    camlight;
    lighting gouraud;
    alpha(.75)
end
end
% these are the layers for the neural network
layers = [1, 12, 14, 12, 2; 5, 12, 10, 13, 2; 3, 20, 20, 15, 17; 4, 13, 19, 8, 17; 5, 13, 13, 12, 12];
layers2 = [4, 12, 21, 12, 6; 3, 16, 16, 10, 8; 5, 16, 16, 15, 16; 5, 14, 15, 11, 15; 2, 15, 17, 16, 12; 3, 20, 13, 9, 10; 3, 21, 12, 9, 15; 6, 11, 19, 10, 10; 1, 16, 9, 15, 16; 1, 16, 9, 16, 11; 1, 19, 16, 14, 11; 1, 17, 13, 10, 4; 6, 13, 12, 13, 17; 6, 17, 17, 14, 12; 1, 15, 14, 14, 15; 4, 11, 12, 16, 18; 1, 19, 17, 15, 10; 5, 18, 19, 14, 3; 2, 14, 14, 9, 15; 4, 12, 19, 12, 2; 4, 13, 10, 12, 18; 4, 11, 20, 11, 9; 6, 13, 9, 9, 5; 5, 19, 16, 7, 6];
ind_layers = [10, 12, 14, 16, 18, 20];

average_layers = [3, 15, 15, 12, 11];

diary on
if nonlinear
for jj = 1:5
    
    n = 1;
    
    for noise = 260:-50:10
        [CNR, MSE] = Analysis_DES_3_1(cal(:, :, cell2mat(inds(jj))), cal(:, :, cell2mat(inds(jj))'), cell2mat(evec(jj)), noise, average_layers(jj));
        
        %         load('x_3_0')
        %         load('y_3_0')
        %
        %         x2 = x(1:9);
        %         y2 = y(1:9);
        %
        %         x2 = x2(x2 ~= 0);
        %         y2 = y2(y2 ~= 0);
        %
        %         [ROI,SD] = createContoursSD(imcart_2,x2,y2);
        %         [ROI_w,SD_w] = createContoursSD(imcart_2,201,198);
        %
        %         npts = length(x2);
        %         CNR = zeros(npts,2);
        %
        %         %Diff = ROI(1:end);
        Diff = [3.9, 3.4, 2.9, 2.4, 1.9, 1.4, 0.9, 0.4, 0];
        %         for ii = 1:length(Diff)
        %             CNR(ii,1:2) = (ROI(ii)-ROI_w) ./ sqrt(SD(ii,:).^2 + mean(SD_w)^2);
        %         end
        %
        diff_vec = linspace(0.4, 3.9, 80);
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
        
        MSE_array(noise, jj) = MSE;
        
        n = n + 1;
        global_n = global_n + 1;
    end
    %legend(legendInfo2)
    subplot(3, 5, jj+5)
    legend(legendInfo2)
    %subplot(3,5,jj)
    %legend(legendInfo)
    camlight;
    lighting gouraud;
    alpha(.75)
end
end