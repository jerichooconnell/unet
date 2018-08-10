function [im_soft,im_hard,perf] = Analysis_DES_nonlinear(cal,val,evec,noises)
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
    end
         
    for ii = 1:length(cal(1,1,:))
        temp_ML = returnContours(yy(:,:,ii),x,y,t_hard,t_soft);
        if ii ~= 1
            Y_ML = cat(1,Y_ML,temp_ML(end,:));
        else
            Y_ML = temp_ML;
        end
    end 
    
    x = cat(1,Y_ML(3:end,:));
    t = Y_ML(1:2,:);
    
    fun = @(x)5000.*exp(x(1,:).*1.1.*[.212 .177]).*exp(x(2,:).*1.015.*[.209 .178])-Y_ML(3:end,:);
    
    size(x)
    x = cat(2,ones(1,length(x))',x',(x'.^2),x'.^3,x'.^4);
    %x = cat(2,ones(1,length(x))',x',x(1,:)'.*x(2,:)',x(1,:)'.^2.*x(2,:)'.^2,(x'.^2),x'.^3,x'.^4);
    c1 = lsqnonlin(fun,[4 0]);
    %c2 = lsqnonlin(fun,x,t(2,:));
   

    for ii = 1:length(cal(1,1,:))
        
        ratio_ii = 1/(length(evec) - 1);
        
        yy(:,:,ii) = log(cal(:,:,ii)/((ratio_ii)*10000));
    end
    
    Xnew = reshape(yy,numel(yy(:,:,1)),length(yy(1,1,:)));
    
    Xnew = Xnew';
    %Xnew = (Xnew(1:end-1,:)./Xnew(end,:));
    ys1 = cat(2,ones(1,length(Xnew))',Xnew',(Xnew'.^2),Xnew'.^3,Xnew'.^4)*c1;
    ys2 = cat(2,ones(1,length(Xnew))',Xnew',(Xnew'.^2),Xnew'.^3,Xnew'.^4)*c2;
    % ys = net(cat(1,Xnew,Xnew(end,:)./Xnew(end-1,:)));
    ys1 = ys1';
    ys2 = ys2';
    
    im_soft = reshape(ys1,size(yy,1),size(yy,2));
    im_hard = reshape(ys2,size(yy,1),size(yy,2));



    if verbose > -1
        figure(11)
        subplot(131)
        imagesc(im_hard)
        title('Bony')
        caxis([0 8])
        axis image
        colorbar
        colormap gray
        hold on
        subplot(132)
        imagesc(im_soft)
        title('Soft')
        caxis([0 8])
        axis image
        colorbar
        colormap gray
        subplot(133)
        imagesc(original)
        title('Original')
        axis image
        colormap gray
    end
    
    
    %% Making the validation image
    
    for ii = 1:length(val(1,1,:))
        
        ratio_ii = 1/(length(evec) - 1);
        
        yy(:,:,ii) = log(val(:,:,ii)/((ratio_ii)*10000));
    end
    
    Xnew = reshape(yy,numel(yy(:,:,1)),length(yy(1,1,:)));
    
    Xnew = Xnew';
    %Xnew = (Xnew(1:end-1,:)./Xnew(end,:));
    ys1 = cat(2,ones(1,length(Xnew))',Xnew',Xnew(1,:)'.*Xnew(2,:)',Xnew(1,:)'.^2.*Xnew(2,:)'.^2,(Xnew'.^2),Xnew'.^3,Xnew'.^4)*c1;
    ys2 = cat(2,ones(1,length(Xnew))',Xnew',Xnew(1,:)'.*Xnew(2,:)',Xnew(1,:)'.^2.*Xnew(2,:)'.^2,(Xnew'.^2),Xnew'.^3,Xnew'.^4)*c2;
    % ys = net(cat(1,Xnew,Xnew(end,:)./Xnew(end-1,:)));
    ys1 = ys1';
    ys2 = ys2';
    
    im_soft = reshape(ys1,size(yy,1),size(yy,2));
    im_hard = reshape(ys2,size(yy,1),size(yy,2));

    if verbose > -1
        figure(12)
        subplot(131)
        imagesc(im_hard)
        title('Bony')
        caxis([0 8])
        axis image
        colorbar
        colormap gray
        hold on
        subplot(132)
        imagesc(im_soft)
        title('Soft')
        caxis([0 8])
        axis image
        colorbar
        colormap gray
        subplot(133)
        imagesc(original)
        title('Original')
        axis image
        colormap gray
    end
end