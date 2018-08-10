function [im_soft,im_hard,perf] = Analysis_DES_factor(cal,val,evec,noises)
%% Adding noise combined with MTF

% Script for calculating the signal to noise for the images

global verbose;
global count2;
global global_n;

%% Making the images
% im1 = load('step_high.mat');
% im2 = load('step_low.mat');
% load('Data_MTF.mat');
% im3 = MTF_high;
% im4 = MTF_low;
%
% im1 = im1.image_kV;
% im2 = im2.image_kV;
%
% cal = cat(3,im1,im2);
% val = cat(3,im3,im4);
% evec = [16 60 120];

load('flood_3_0.mat');

corr = (10000 - Flood_3_0);

cal = cal + corr;
val = val + corr;
original = cal(:,:,1);
ratio_ii = 1/(length(evec) - 1)

for ii = 1:length(cal(1,1,:))
    
    % This is the total percentage of the fluence in the image
    cal(:,:,ii) = cal(:,:,ii) .* (1 - ratio_ii*(ii - 1));
    val(:,:,ii) = val(:,:,ii) .* (1 - ratio_ii*(ii - 1));
    
    for jj = ii+1:length(cal(1,1,:))
        
        % This is the total percentage of the fluence in the energy bin
        % ratio_jj = integrate_spec([evec(jj) evec(jj+1)]);
        
        cal(:,:,ii) = cal(:,:,ii) - cal(:,:,jj).*ratio_ii;
        val(:,:,ii) = val(:,:,ii) - val(:,:,jj).*ratio_ii;
        
        
    end
end

%% Getting the signal to noise in the validation
% Using the signal to noise in water

y = 205; x = 201;

count2 = 1;

for target_SN = noises
    % Finding the singnal in water that will be the basis for the noise
    signal = createContours(original,x,y);
    % Finding the target noise
    sigma = signal/target_SN;
    % Finding the signal strength that would give the correct poisson noise
    correct_signal = (signal/sigma)^2;

    % Now we need to scale the image by the correct factor so that the sqrt
    % of the image is the noise 
    
    
    

    %% Generating the thickness with the given Noise
    
    % !! This value is hardcoded and dependant on the spectrum = sqrt(.4319) &
    % sqrt(1 - .4319)
    
    for ii = 1:length(cal(1,1,:))

        val(:,:,ii) = val(:,:,ii) .* correct_signal/signal + (normrnd(0,sqrt(val(:,:,ii)...
            .* correct_signal/signal),[300,300]));
        cal(:,:,ii) = cal(:,:,ii) .* correct_signal/signal +(normrnd(0,sqrt(cal(:,:,ii)...
            .* correct_signal/signal),[300,300]));       
    end
    
    IH = abs(val(:,:,1));
    IL = abs(val(:,:,2));
    
    figure
    imagesc(IH)
    
    wb = 0.232/0.38
    wt = (0.232 - 0.255) /(0.38 - 0.42)
    im_hard = IH ./IL.^(wb);
    im_soft = IH ./IL.^(wt);
    
    im_hard

    if verbose > -1 && noises == 100
        
    
%         figure(9)
%         subplot(5,4,(length(evec) - 2)+12)
%         imagesc(im_hard)
%         title('Cartilage SNR = 100')
%         caxis([0 8])
%         axis image
%         colorbar
%         colormap gray
%         hold on
%         subplot(132)
%         imagesc(im_soft)
%         title('Soft')
%         caxis([0 8])
%         axis image
%         colorbar
%         colormap gray
%         subplot(133)
%         imagesc(original)
%         title('Original')
%         axis image
%         colormap gray
    end
    
    
    %% Making the validation image

    if verbose > -1
        figure(22)
        %subplot(5,4,(length(evec) - 2)+16)
        imagesc(im_hard)
        title('Cartilage SNR = 100')
        caxis([0 8])
        axis image
        colorbar
        colormap gray
        hold on
%         subplot(132)
%         imagesc(im_soft)
%         title('Soft')
%         caxis([0 8])
%         axis image
%         colorbar
%         colormap gray
    end
end