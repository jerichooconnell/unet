function [CNR, perf, noise] = Analysis_DES_3_1(cal, val, evec, layer, varargin)

%% Adding noise combined with MTF

% Script for calculating the signal to noise for the images

global verbose;
global global_n;

if nargin > 4
    n_runs = cell2mat(varargin)
else
    n_runs = 1;
end

load('x_0_0')
load('y_0_0')

[~, noise] = createContours(sum(cal,3),48, 133);


t_hard = [4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5, 0, 0, 4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5, 0, 4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5, 0]./2;
t_soft = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 0, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6]./2;
t_v = t_hard;
t_v(t_v ~= 0) = t_v(t_v ~= 0) - 0.1;

energy_names = linspace(16,120,200);

yy = zeros(size(cal(:,:,1:length(evec)-1)));
yy2 = zeros(size(cal(:,:,1:length(evec)-1)));
Y = zeros(length(t_hard), length(cal(1, 1, :)));

cal(cal < 0) = 0.00001;

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

x_train = cat(1, Y_ML(3:end, :));
t = Y_ML(2, :);

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


%% Training Neural Network ************************************************
%Setting the random number generator, so that can compare results
% Just loading the neural network, uncomment the next lines to train the
% network
%load('net_r6')
% Initializing a neural network with 30 entries\
Xnew = reshape(yy2, numel(yy2(:, :, 1)), length(yy2(1, 1, :)));
Xnew = Xnew';
%Xnew = (Xnew(1:end-1,:)./Xnew(end,:));
x2 = x(1:8);
y2 = y(1:8);

%x2 = x2(x2 ~= 0);
%y2 = y2(y2 ~= 0);


lll = zeros(1, 5);
npts = length(x2);
CNR = zeros(n_runs, npts, 2);
%     %     lly = zeros(1,10);
%     for layer = max(min(layers)-1,1):1:max(layers)+1
layer5 = layer * 5;
for runs = 1:n_runs
    
    net = cascadeforwardnet(layer5); %55
    if verbose < 2  
        net.trainParam.showWindow = 0;
    end
    [net, ~] = train(net, x_train, t); %JO
    
    testY = net(x_val);
    perf = mse(net, t_val, testY);
    
    lll(runs) = perf;
    
    ys = net(Xnew);
    %ys = net(cat(1,Xnew,Xnew(end,:)./Xnew(end-1,:)));
    ys = ys';
    
    im_hard = reshape(ys(:, 1), size(yy, 1), size(yy, 2));
    
    [ROI, SD] = createContoursSD(im_hard, x2, y2);
    [ROI_w, SD_w] = createContoursSD(im_hard, 48, 133);
    
    
    for pp = 1:8
        
        CNR(runs, pp, 1:2) = (ROI(pp) - ROI_w) ./ sqrt(SD(pp, :).^2+mean(SD_w)^2);
    end
    
    %lly(runs,ind) = I(1);
end
%         ind = ind + 1;


perf = mean(lll);
if n_runs > 1
    CNR = squeeze(mean(CNR));
else
    CNR = squeeze(CNR);
end

%% Making the validation image

if verbose > -1 && global_n == 2
    figure(15)
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
end