function [im_hard, perf, noise] = Analysis_DES_linear_plot_3_2(cal, val, evec)

%% Adding noise combined with MTF

% Script for calculating the signal to noise for the images

global verbose;
global global_n;


% Now we need to scale the image by the correct factor so that the sqrt
% of the image is the noise

%% Generating the thickness with the given Noise

% !! This value is hardcoded and dependant on the spectrum = sqrt(.4319) &
% sqrt(1 - .4319)

%% Initialize
load('x_0_0')
load('y_0_0')
yy = zeros(size(cal(:,:,1:length(evec)-1)));
yy2 = zeros(size(cal(:,:,1:length(evec)-1)));

%% Find the noise
[ROI, noise] = createContours(sum(val,3),148, 133)


t_hard = [4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5, 0, 0, 4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5, 0, 4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5, 0];
t_soft = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 0, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6];
t_v = t_hard;
t_v(t_v ~= 0) = t_v(t_v ~= 0) - 0.1;

energy_names = linspace(16,120,100);
%!! this is a peculiarity of this one run
% energy_names2 = linspace(16,120,200);

cal(cal < 0) = 0.00001;

%% Creating the calibration vector
for ii = 1:length(evec) - 1
    [ ~, idx_lo ] = min( abs( energy_names -evec(ii) ) );
    [ ~, idx_hi ] = min( abs( energy_names -evec(ii + 1) ) );
    yy(:, :, ii) = squeeze(sum(cal(:,:,idx_lo:idx_hi - 1),3));
    yy(:, :, ii) = log(yy(:, :, ii)./max(max(yy(:, :, ii))));
    if verbose > 3
        figure
        mesh(squeeze(sum(cal,3)))
    end
end


for ii = 1:length(evec) - 1
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

%% Performing the calibration step
if length(yy(1, 1, :)) ~= 1
    perms = nchoosek(1:length(yy(1, 1, :)), 2);
    x = cat(2, ones(1, length(x))', x', x(perms(:,1),:)'.*x(perms(:,2),:)', (x'.^2), x'.^3, x'.^4);
elseif length(yy(1, 1, :)) > 2
    perms = nchoosek(1:length(yy(1, 1, :)), 2);
    x = cat(2, ones(1, length(x))', x', x(perms(:,1),:)'.*x(perms(:,2),:)',x'.*x(perms(:,1),:)'.*x(perms(:,2),:)',(x'.^2), x'.^3, x'.^4);
else
    x = cat(2, ones(1, length(x))', x', (x'.^2), x'.^3, x'.^4);
end
c2 = lsqlin(x, t(2, :));

%% Making the validation image
val(val < 0) = 0.00001;

for ii = 1:length(evec) - 1
    [ ~, idx_lo ] = min( abs( energy_names - evec(ii) ) );
    [ ~, idx_hi ] = min( abs( energy_names - evec(ii + 1) ) );
    yy2(:, :, ii) = squeeze(sum(val(:,:,idx_lo:idx_hi - 1),3));
    yy2(:, :, ii) = log(yy2(:, :, ii)./max(max(yy2(:, :, ii))));
end

for ii = 1:length(evec) - 1
    temp_ML = returnContours_3_1(yy2(:, :, ii), x_co, y_co, t_v);
    if ii ~= 1
        Y_ML_val = cat(1, Y_ML_val, temp_ML(end, :));
    else
        Y_ML_val = temp_ML;
    end
end

x_val = Y_ML_val(2:end, :);
t_val = Y_ML_val(1, :);


x = reshape(yy2, numel(yy2(:, :, 1)), length(yy2(1, 1, :)));

x = x';

%% Performing the validation
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

if verbose > -1 && global_n == 1
    figure(1)
    subplot(324)
    imagesc(im_hard)
    title('Linear pencil-beam','FontName','Liberation Serif','FontSize',22)
    caxis([0, 4])
    axis image
    axis off
    %colorbar
    colormap gray
    hold on
end