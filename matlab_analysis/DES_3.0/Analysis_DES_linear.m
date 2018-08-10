function [im_hard, perf] = Analysis_DES_linear(cal, val, evec, target_SNR)

%% Adding noise combined with MTF

% Script for calculating the signal to noise for the images

global verbose;
global count2;
count2 = 1;

load('flood_3_0.mat');

corr = (10000 - Flood_3_0);

cal = cal + corr;
val = val + corr;
original = cal(:, :, 1);
ratio_ii = 1 / (length(evec) - 1);

for ii = 1:length(cal(1, 1, :))
    
    % This is the total percentage of the fluence in the image
    cal(:, :, ii) = cal(:, :, ii) .* (1 - ratio_ii * (ii - 1));
    val(:, :, ii) = val(:, :, ii) .* (1 - ratio_ii * (ii - 1));
    
    for jj = ii + 1:length(cal(1, 1, :))
        
        % This is the total percentage of the fluence in the energy bin
        % ratio_jj = integrate_spec([evec(jj) evec(jj+1)]);
        
        cal(:, :, ii) = cal(:, :, ii) - cal(:, :, jj) .* ratio_ii;
        val(:, :, ii) = val(:, :, ii) - val(:, :, jj) .* ratio_ii;
        
    end
end

%% Getting the signal to noise in the validation
% Using the signal to noise in water

y = 205;
x = 201;

% figure
% imagesc(cal(:,:,1))

% Finding the singnal in water that will be the basis for the noise
signal = createContours(original, x, y)
% Finding the target noise
sigma = signal / target_SNR;
% Finding the signal strength that would give the correct poisson noise
correct_signal = (signal / sigma)^2;

% Now we need to scale the image by the correct factor so that the sqrt
% of the image is the noise

%% Generating the thickness with the given Noise

% !! This value is hardcoded and dependant on the spectrum = sqrt(.4319) &
% sqrt(1 - .4319)

for ii = 1:length(cal(1, 1, :))
    
    val(:, :, ii) = val(:, :, ii) .* correct_signal / signal + (normrnd(0, sqrt(val(:, :, ii) ...
        .*correct_signal/signal), [300, 300]));
    cal(:, :, ii) = cal(:, :, ii) .* correct_signal / signal + (normrnd(0, sqrt(cal(:, :, ii) ...
        .*correct_signal/signal), [300, 300]));
end


% load('x_3_0')
% load('y_3_0')
% 
% t_v = [3.9, 3.4, 2.9, 2.4, 1.9, 1.4, 0.90, 0.40, 0, 0, 1.9, 2.4, 2.9, 3.4, 3.9, 0.40, 0.90, 1.4, 0, 1.9, 2.4, 2.9, 3.4, 3.9, 0.40, 0.90, 1.4, 0];
% t_hard = [4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5, 0, 0, 2, 2.5, 3, 3.5, 4, 0.5, 1, 1.5, 0, 2, 2.5, 3, 3.5, 4, 0.5, 1, 1.5, 0];
 t_soft = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 0, 6, 5.5, 5, 4.5, 4, 7.5, 7, 6.5, 8, 4, 3.5, 3, 2.5, 2, 5.5, 5, 4.5, 6];
% nums = length(t_hard);

load('x_3_1')
load('y_3_1')

t_hard = [4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5, 0, 0, 4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5, 0, 4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5, 0];   
t_v = t_hard;
t_v(t_v ~= 0) = t_v(t_v ~= 0) - 0.1;


x(17:18) = 10;
y(17:18) = 10;
x(end-2:end -1) = 10;
y(end-2:end -1) = 10;

t_hard(17:18) = 0;
t_v(17:18) = 0;
t_hard(end-2:end -1) = 0;
t_v(end-2:end -1) = 0;

yy = zeros(size(val));
Y = zeros(length(t_hard), length(cal(1, 1, :)));

cal(cal < 0) = 0.00001;

for ii = 1:length(cal(1, 1, :))
    ratio_ii = 1 / (length(evec) - 1);
    yy(:, :, ii) = log(cal(:, :, ii)/((ratio_ii) * 10000));
end

for ii = 1:length(cal(1, 1, :))
    temp_ML = returnContours(yy(:, :, ii), x, y, t_hard, t_soft);
    if ii ~= 1
        Y_ML = cat(1, Y_ML, temp_ML(end, :));
    else
        Y_ML = temp_ML;
    end
end

x_co = x;
y_co = y;

x = cat(1, Y_ML(3:end, :));
t = Y_ML(1:2, :);

if length(yy(1, 1, :)) ~= 1
    perms = nchoosek(1:length(yy(1, 1, :)), 2);
    
    x = cat(2, ones(1, length(x))', x', x(perms(:,1),:)'.*x(perms(:,2),:)', (x'.^2), x'.^3, x'.^4);
    %x = cat(2,ones(1,length(x))',x',x(1,:)'.*x(2,:)',x(1,:)'.^2.*x(2,:)'.^2,(x'.^2),x'.^3,x'.^4);
elseif length(yy(1, 1, :)) > 2
    perms = nchoosek(1:length(yy(1, 1, :)), 2);
    
    x = cat(2, ones(1, length(x))', x', x(perms(:,1),:)'.*x(perms(:,2),:)',x'.*x(perms(:,1),:)'.*x(perms(:,2),:)',(x'.^2), x'.^3, x'.^4);
    %x = cat(2,ones(1,length(x))',x',x(1,:)'.*x(2,:)',x(1,:)'.^2.*x(2,:)'.^2,(x'.^2),x'.^3,x'.^4);
else
    x = cat(2, ones(1, length(x))', x', (x'.^2), x'.^3, x'.^4);
end
%c1 = lsqlin(x, t(1, :));
c2 = lsqlin(x, t(2, :));

%% Making the validation image
val(val < 0) = 0.00001;

for ii = 1:length(val(1, 1, :))
    
    ratio_ii = 1 / (length(evec) - 1);
    
    yy(:, :, ii) = log(val(:, :, ii)/((ratio_ii) * 10000));
end

for ii = 1:length(cal(1, 1, :))
    temp_ML = returnContours_3_1(yy(:, :, ii), x_co, y_co, t_v);
    if ii ~= 1
        Y_ML_val = cat(1, Y_ML_val, temp_ML(end, :));
    else
        Y_ML_val = temp_ML;
    end
end

x_val = Y_ML_val(2:end, :);
t_val = Y_ML_val(1, :);


x = reshape(yy, numel(yy(:, :, 1)), length(yy(1, 1, :)));

x = x';
if length(yy(1, 1, :)) ~= 1
    ys1 = cat(2, ones(1, length(x_val))', x_val', x_val(perms(:,1),:)'.*x_val(perms(:,2),:)', (x_val'.^2), x_val'.^3, x_val'.^4) * c2;
    ys2 = cat(2, ones(1, length(x))', x', x(perms(:,1),:)'.*x(perms(:,2),:)', (x'.^2), x'.^3, x'.^4) * c2;
    
elseif length(yy(1, 1, :)) > 2
    ys1 = cat(2, ones(1, length(x_val))', x_val', x_val(perms(:,1),:)'.*x_val(perms(:,2),:)',x_val'.*x_val(perms(:,1),:)'.*x_val(perms(:,2),:)', (x_val'.^2), x_val'.^3, x_val'.^4) * c2;
    ys2 = cat(2, ones(1, length(x))', x', x(perms(:,1),:)'.*x(perms(:,2),:)',x'.*x(perms(:,1),:)'.*x(perms(:,2),:)',(x'.^2), x'.^3, x'.^4) * c2;
    
else
    ys1 = cat(2, ones(1, length(x_val))', x_val', (x_val'.^2), x_val'.^3, x_val'.^4) * c2;
    ys2 = cat(2, ones(1, length(x))', x', (x'.^2), x'.^3, x'.^4) * c2;
end

%% Validating to find MSE

ys2 = ys2';

perf = mean((t_val' - ys1).^2)

%im_soft = reshape(ys1, size(yy, 1), size(yy, 2));
im_hard = reshape(ys2, size(yy, 1), size(yy, 2));

if verbose > -1 && target_SNR == 100
    figure(10)
    subplot(3, 5, (length(evec) - 1)+10)
    imagesc(im_hard)
    title('Cartilage SNR = 100')
    caxis([0, 8])
    axis image
    axis off
    colorbar
    colormap gray
    hold on
end
