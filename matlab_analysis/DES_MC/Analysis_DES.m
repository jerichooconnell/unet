function [im_soft,im_hard,perf] = Analysis_DES(cal,val,evec,noises)
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
    

    load('x_3_0')
    load('y_3_0')
    
    t_hard = [4 3.5 3 2.5 2 1.5 1 0.5 0 0 2 2.5 3 3.5 4 0.5 1 1.5 0 2 2.5 3 3.5 4 0.5 1 1.5 0];
    t_soft = [0 0.5 1 1.5 2 2.5 3 3.5 4 0 6 5.5 5 4.5 4 7.5 7 6.5 8 4 3.5 3 2.5 2 5.5 5 4.5 6];
    nums = length(t_hard);
    
    yy = zeros(size(val));
    Y = zeros(length(t_hard),length(cal(1,1,:)));
    
    cal(cal < 0 ) = 0.00001;     
    
    for ii = 1:length(cal(1,1,:))  
        ratio_ii = 1/(length(evec) - 1);
        yy(:,:,ii) = log(cal(:,:,ii)/((ratio_ii)*10000));
    end%
         
    for ii = 1:length(cal(1,1,:))
        temp_ML = returnContours(yy(:,:,ii),x,y,t_hard,t_soft);
        if ii ~= 1
            Y_ML = cat(1,Y_ML,temp_ML(end,:));
        else
            Y_ML = temp_ML;
        end
    end 
    
%     % Using the method of Alvarez
%     bpu =
%     bdu =
%     
%     f =  - log(Y_ML*exp(-bp*E^(-3) - bd*fKN(E)));
    %x = Y_ML(3:end-1,:)./Y_ML(end,:);
    x = cat(1,Y_ML(3:end,:));%,Y_ML(end,:)./Y_ML(3,:));
    t = Y_ML(1:2,:);
    size(x)
    %% Training Neural Network ************************************************
    %Setting the random number generator, so that can compare results
    % Just loading the neural network, uncomment the next lines to train the
    % network
    %load('net_r6')
    % Initializing a neural network with 30 entries
    net = fitnet(55);%55
    %view(net)
    %Training the network with the training data

    %if global_n == 1
    [net,tr] = train(net,x,t); %JO
     %   save('net','net')
     %   save('tr','tr')
%     else 
%         load('net')
%         load('tr')
%     end
    
%     [net,tr] = train(net,x,t);
% %     %nntraintool
% %     %Plotting the performance
% %     plotperform(tr)
% %     % Testing a random sample of the test data
      testX = x(:,tr.testInd);
      testT = t(:,tr.testInd);
      testY = net(testX);
% %     % Analyzing the performance
      perf = mse(net,testT,testY)
%     y = net(x);
%     % Looking at the regression
%     plotregression(t,y)
%     e = t - y;
%     %Histogram of errors
%     figure
%     ploterrhist(e)

%     if verbose > -1 && noises == 100
%         
%         for ii = 1:length(cal(1,1,:))
%             
%             ratio_ii = 1/(length(evec) - 1);
%             
%             yy(:,:,ii) = log(cal(:,:,ii)/((ratio_ii)*10000));
%         end
%         
%         Xnew = reshape(yy,numel(yy(:,:,1)),length(yy(1,1,:)));
%         
%         Xnew = Xnew';
%         %Xnew = (Xnew(1:end-1,:)./Xnew(end,:));
%         ys = net(Xnew);
%         % ys = net(cat(1,Xnew,Xnew(end,:)./Xnew(end-1,:)));
%         ys = ys';
%         
%         im_soft = reshape(ys(:,1),size(yy,1),size(yy,2));
%         im_hard = reshape(ys(:,2),size(yy,1),size(yy,2));
%     
%         figure(9)
%         subplot(5,4,(length(evec) - 2)+12)
%         imagesc(im_hard)
%         title('Cartilage SNR = 100')
%         caxis([0 8])
%         axis image
%         colorbar
%         colormap gray
%         hold on
% %         subplot(132)
% %         imagesc(im_soft)
% %         title('Soft')
% %         caxis([0 8])
% %         axis image
% %         colorbar
% %         colormap gray
% %         subplot(133)
% %         imagesc(original)
% %         title('Original')
% %         axis image
% %         colormap gray
%     end
    
    
    %% Making the validation image
    
    for ii = 1:length(val(1,1,:))
        
        ratio_ii = 1/(length(evec) - 1);
        
        yy(:,:,ii) = log(val(:,:,ii)/((ratio_ii)*10000));
    end
    
    Xnew = reshape(yy,numel(yy(:,:,1)),length(yy(1,1,:)));
    
    Xnew = Xnew';
    %Xnew = (Xnew(1:end-1,:)./Xnew(end,:));
    ys = net(Xnew);
    %ys = net(cat(1,Xnew,Xnew(end,:)./Xnew(end-1,:)));
    ys = ys';
    
    im_soft = reshape(ys(:,1),size(yy,1),size(yy,2));
    im_hard = reshape(ys(:,2),size(yy,1),size(yy,2));

    if verbose > -1 && noises == 100
        figure(9)
        subplot(4,5,(length(evec) - 1)+15)
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