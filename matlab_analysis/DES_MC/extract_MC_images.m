function extract_MC_images(parentfolder,out)
%% reshape run into an image for the existing code

%parentfolder = '/home/jericho/Downloads/bin/pcd_planar_imaging/Jericho_sim/run_june_28_lowSN/*.csv';

csv_files = dir(parentfolder);
nImageSets = size(csv_files,1);

Data = zeros(3,88,100,200);

for i=1:nImageSets
    dir_name = strcat(csv_files(i).folder,'/',csv_files(i).name);
    csv_raw = csvread(dir_name,10,0);
    temp = reshape(csv_raw(:,5:204),100,100,200);
    Data(i,:,:,:) = temp(7:94,:,:,:);
end

%imagesc(squeeze(sum(Data(1,:,:,1:100),4)))

left_image = cat(2,Data(2,:,:,:),Data(3,:,:,:));
right_image = cat(2,Data(1,:,:,:),Data(1,:,:,:));

full_image = cat(2,squeeze(left_image),squeeze(right_image));

figure
imagesc(squeeze(sum(full_image,3)))

save(out,'full_image')
end

