A = load('Test_energy_bin.mat');
B = load('Cali_MC_top_0_1.mat');

energy_dep = mean(A.full_image,3);
counts = mean(B.full_image,3);

figure
imagesc(energy_dep)
figure
imagesc(counts)

energy_dep = energy_dep(1:88,1:100);
counts = counts(89:end,101:end);

% energy_dep = energy_dep(94:end - 5,105:end -5);
% counts = counts(94:end - 5,105:end -5);

energy_dep_flat = reshape(energy_dep,numel(energy_dep),1);
counts_flat = reshape(counts,numel(counts),1);

energy_dep_flat = normalize(energy_dep_flat);
counts_flat = normalize(counts_flat);

energy_dep = reshape(energy_dep_flat,size(energy_dep,1),size(energy_dep,2));
counts = reshape(counts_flat,size(energy_dep,1),size(energy_dep,2));

figure
subplot(121)
mesh(energy_dep - counts)
subplot(122)
imagesc(energy_dep - counts)
title("Normalized Energy Deposition - Counts")
