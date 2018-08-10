function extract_MC_images_all_200(parentfolder,out)
%% reshape run into an image for the existing code

%parentfolder = '/home/jericho/Downloads/bin/pcd_planar_imaging/Jericho_sim/run_june_28_lowSN/*.csv';

csv_files_2cm = dir(strcat(parentfolder,'*2cm*.csv'));
csv_files_3cm = dir(strcat(parentfolder,'*3cm*.csv'));
csv_files_4cm = dir(strcat(parentfolder,'*4cm*.csv'));

nImageSets = size(csv_files_2cm,1);

Data = zeros(3,88,100,200);

full_image = zeros(nImageSets,176,200,200);

for i=1:nImageSets
    dir_name_2cm = strcat(csv_files_2cm(i).folder,'/',csv_files_2cm(i).name);
    csv_raw_2cm = csvread(dir_name_2cm,10,0);
    temp = reshape(csv_raw_2cm(:,5:204),100,100,200);
    Data(1,:,:,:) = temp(7:94,:,:,:);
    dir_name_3cm = strcat(csv_files_3cm(i).folder,'/',csv_files_3cm(i).name);
    csv_raw_3cm = csvread(dir_name_3cm,10,0);
    temp = reshape(csv_raw_3cm(:,5:204),100,100,200);
    Data(2,:,:,:) = temp(7:94,:,:,:);
    dir_name_4cm = strcat(csv_files_4cm(i).folder,'/',csv_files_4cm(i).name);
    csv_raw_4cm = csvread(dir_name_4cm,10,0);
    temp = reshape(csv_raw_4cm(:,5:204),100,100,200);
    Data(3,:,:,:) = temp(7:94,:,:,:);


    %imagesc(squeeze(sum(Data(1,:,:,1:100),4)))

    left_image = cat(2,Data(2,:,:,:),Data(3,:,:,:));
    right_image = cat(2,Data(1,:,:,:),Data(1,:,:,:));

    full_image(i,:,:,:) = cat(2,squeeze(left_image),squeeze(right_image));

end
% figure
% imagesc(squeeze(sum(full_image,3)))

save(out,'full_image')
end