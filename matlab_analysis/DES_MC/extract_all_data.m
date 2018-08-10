function extract_all_data(names,out)
%To load ImaSim data from a saved simulation into matlab


% msgbox('To load data from saved simulation into matlab, select the saved simulation directory. For example if you saved your simulation under the name TEST, then select the TEST directory','modal');

p = dir(names);

for ii = 1:length(p)
% open the log.sim file which contains info on simulation

dir_name = strcat(p(ii).folder,'\',p(ii).name);
fid=fopen([dir_name filesep 'log.sim']);

% Read in first line from log.sim which describes the simulation type.
tline=fgetl(fid);


s1 = strfind(tline,':');
sim_type=tline(s1+1:s1+1);
% sim_type can be 1,2,3 or 4 (x-ray, CT, CBCT,mv planar image)

% get spectrum file name
spectrum_name=fgetl(fid);

%check for kV or MV spectrum
tline=fgetl(fid);
s1 = strfind(tline,':');
% t means MV, f means kV for spectrum_type
spectrum_type=tline(s1+1:s1+1);

% read in geometry file name
geom_name=fgetl(fid);

% read in setup file name
setup_name=fgetl(fid);
setup_fid=fopen([dir_name filesep setup_name]);
% read in detector file name
det_name=fgetl(fid);



if sim_type=='1'
    
    images=dir([dir_name filesep 'Images']);
    for i=1:size(images)
       name=images(i).name;
       check = strfind(name,'.im');
       if size(check)~=0
           break
       end
    end
    image_fid=fopen([dir_name filesep 'Images' filesep name]);
    s1=strfind(name,'_');
    s2=strfind(name,'X');
    Nx=name(s1+1:s2-1);
    s1=strfind(name,'X');
    s2=strfind(name,'.');
    Ny=name(s1+1:s2-1);
    Nx=str2num(Nx);
    Ny=str2num(Ny);
    image_kV = fread(image_fid,[Ny,Nx],'int32','b');
    image_kV = image_kV./10000;
    newName = p(ii).name;
    N = matlab.lang.makeValidName(newName);
    S.(N) = image_kV;
    save(out, '-struct', 'S')
    dump=fread(image_fid,[1,3],'int32','b');
    pixelwidth=fread(image_fid,[1,1],'int32','b');
    pixelwidth=pixelwidth./10000;
    
    clear check
    clear det_name
    clear dir_name
    clear dump
    clear fid
    clear geom_name
    clear i
    clear image_fid
    clear images
    clear name
    clear s1
    clear s2
    clear setup_fid
    clear setup_name
    clear sim_type
    clear spectrum_name
    clear spectrum_type
    clear tline
    
    
    
    beep
elseif sim_type=='2'
    
%     first read sinograms
    for i=1:9
        dump=fgetl(setup_fid);
    end
    tline=fgetl(setup_fid);
    s1=strfind(tline,':');
    Ndet=tline(s1+1:size(tline,2));
    Ndet=str2num(Ndet);
    
    tline=fgetl(setup_fid);
    s1=strfind(tline,':');
    Nslice=tline(s1+1:size(tline,2));
    Nslice=str2num(Nslice);
    
    tline=fgetl(setup_fid);
    s1=strfind(tline,':');
    Nview=tline(s1+1:size(tline,2));
    Nview=str2num(Nview);
    
    data_fid=fopen([dir_name filesep 'Data']);
    fan_sin_det_angles=fread(data_fid,[1,Ndet],'int32','b')./10000;
    view_angles=fread(data_fid,[1,Nview],'int32','b')./10000;
    
    for i=1:Nslice
        temp=fread(data_fid,[Nview,Ndet+1],'int32','b')./10000;
        fan_sinograms(:,:,i)=temp(1:Nview,2:Ndet+1)';
        dump=fread(data_fid,[1,1],'int32','b')./10000;
    end
    
    par_sin_det_pos=fread(data_fid,[1,Ndet],'int32','b')./10000;
    
    Npad=fread(data_fid,[1,1],'int32','b')./10000;
    for i=1:Nslice
        temp2=fread(data_fid,[Nview+Npad,Ndet+1],'int32','b')./10000;
        par_sinograms(:,:,i)=temp2(1:Nview,2:Ndet+1)';
        dump2=fread(data_fid,[1,1],'int32','b')./10000;
    end
%     then read images
name=uigetfile('*.im','Select an image to load',[dir_name filesep 'Images']);

%     images=dir([dir_name filesep 'Images']);
%     N=0;
%     for i=1:size(images)
%        name=images(i).name;
%        check = strfind(name,'.im');
%        if size(check)~=0
%            N=N+1;
%            image_fid=fopen([dir_name filesep 'Images' filesep name]);
%             s1=strfind(name,'_');
%             s2=strfind(name,'X');
%             Nx=name(s1(1)+1:s2-1);
%             s1=strfind(name,'X');
%             s2=strfind(name,'_');
%             Ny=name(s1+1:s2(2)-1);
%             image_Nx(N)=str2num(Nx);
%             image_Ny(N)=str2num(Ny);
%             image_CT(:,:,N) = fread(image_fid,[image_Ny(N),image_Nx(N)],'int32','b');
%             image_CT(:,:,N)=image_CT(:,:,N)./10000;
%             dump=fread(image_fid,[1,3],'int32','b');
%             image_pixelwidth(N)=fread(image_fid,[1,1],'int32','b');
%             image_pixelwidth(N)= image_pixelwidth(N)./10000;
%        end
%     end
    


       
           
    image_fid=fopen([dir_name filesep 'Images' filesep name]);
    s1=strfind(name,'_');
    s2=strfind(name,'X');
    Nx=name(s1(1)+1:s2-1);
    s1=strfind(name,'X');
    s2=strfind(name,'_');
    Ny=name(s1+1:s2(2)-1);
    image_Nx=str2num(Nx);
    image_Ny=str2num(Ny);
    image_CT = fread(image_fid,[image_Ny,image_Nx],'int32','b');
    image_CT=image_CT./10000;
    dump=fread(image_fid,[1,3],'int32','b');
    image_pixelwidth=fread(image_fid,[1,1],'int32','b');
    image_pixelwidth= image_pixelwidth./10000;
     
    
    clear N
    clear Npad
    clear data_fid
    clear check
    clear det_name
    clear dir_name
    clear dump
    clear dump2
    clear fid
    clear geom_name
    clear i
    clear image_fid
    clear images
    clear name
    clear s1
    clear s2
    clear setup_fid
    clear setup_name
    clear sim_type
    clear spectrum_name
    clear spectrum_type
    clear tline
    clear temp
    clear temp2
    clear Nx
    clear Ny
    
    
    beep
elseif sim_type=='3'

% %     read projections in
%    for i=1:7
%         dump=fgetl(setup_fid);
%     end
%     tline=fgetl(setup_fid);
%     s1=strfind(tline,':');
%     Ndet=tline(s1+1:size(tline,2));
%     Ndet=str2num(Ndet);
%     
%     
%     tline=fgetl(setup_fid);
%     s1=strfind(tline,':');
%     Nview=tline(s1+1:size(tline,2));
%     Nview=str2num(Nview);
%     
%     data_fid=fopen([dir_name filesep 'Data']);
%     det_pos=fread(data_fid,[1,Ndet],'int32','b')./10000;
%     virt_det_pos=fread(data_fid,[1,Ndet],'int32','b')./10000;
%     view_angles=fread(data_fid,[1,Nview],'int32','b')./10000;
%     for i=1:Nview
%         temp=fread(data_fid,[Ndet,Ndet],'int32','b')./10000;
%         if i==1
%         cbct_proj(:,:,i)=temp';
%         end
%         dump=fread(data_fid,[1,1],'int32','b')./10000;
%         dump=fread(data_fid,[1,1],'int32','b')./10000;
%         
%     end
%     Npad=fread(data_fid,[1,1],'int32','b')./10000;
%     for i=1:Nview
%         temp=fread(data_fid,[Ndet,Ndet],'int32','b')./10000;
%         cbct_proj_filt(:,:,i)=temp';
%         break
%         dump=fread(data_fid,[1,1],'int32','b')./10000;
%         dump=fread(data_fid,[1,1],'int32','b')./10000;
%         
%     end
%     
%     %     then read images
% 
% %     images=dir([dir_name filesep 'Images']);
% %     N=0;
% %     for i=1:size(images)
% %        name=images(i).name;
% %        check = strfind(name,'.im');
% %        if size(check)~=0
% %            N=N+1;
% %            image_fid=fopen([dir_name filesep 'Images' filesep name]);
% %             s1=strfind(name,'_');
% %             s2=strfind(name,'X');
% %             Nx=name(s1(1)+1:s2-1);
% %             s1=strfind(name,'X');
% %             s2=strfind(name,'_');
% %             Ny=name(s1+1:s2(2)-1);
% %             Nx=str2num(Nx);
% %             Ny=str2num(Ny);
% %             image_CBCT(:,:,N) = fread(image_fid,[Ny,Nx],'int32','b');
% %             image_CBCT(:,:,N)=image_CBCT(:,:,N)./10000;
% %             dump=fread(image_fid,[1,3],'int32','b');
% %             pixelwidth=fread(image_fid,[1,1],'int32','b');
% %             pixelwidth=pixelwidth./10000;
% %        end
% %     end
% 
%     name=uigetfile('*.im','Select an image to load',[dir_name filesep 'Images']);
%        
%     image_fid=fopen([dir_name filesep 'Images' filesep name]);
%     s1=strfind(name,'_');
%     s2=strfind(name,'X');
%     Nx=name(s1(1)+1:s2-1);
%     s1=strfind(name,'X');
%     s2=strfind(name,'_');
%     Ny=name(s1+1:s2(2)-1);
%     image_Nx=str2num(Nx);
%     image_Ny=str2num(Ny);
%     image_CBCT = fread(image_fid,[image_Ny,image_Nx],'int32','b');
%     image_CBCT=image_CBCT./10000;
%     dump=fread(image_fid,[1,3],'int32','b');
%     image_pixelwidth=fread(image_fid,[1,1],'int32','b');
%     image_pixelwidth= image_pixelwidth./10000;
% 
%     
%     clear N
%     clear Npad
%     clear data_fid
%     clear check
%     clear det_name
%     clear dir_name
%     clear dump
%     clear dump2
%     clear fid
%     clear geom_name
%     clear i
%     clear image_fid
%     clear images
%     clear name
%     clear s1
%     clear s2
%     clear setup_fid
%     clear setup_name
%     clear sim_type
%     clear spectrum_name
%     clear spectrum_type
%     clear tline
%     clear temp
%     clear temp2
%     clear Nx
%     clear Ny
%    beep
else
    images=dir([dir_name filesep 'Images']);
    for i=1:size(images)
       name=images(i).name;
       check = strfind(name,'.im');
       if size(check)~=0
           break
       end
    end
    image_fid=fopen([dir_name filesep 'Images' filesep name]);
    s1=strfind(name,'_');
    s2=strfind(name,'X');
    Nx=name(s1+1:s2-1);
    s1=strfind(name,'X');
    s2=strfind(name,'.');
    Ny=name(s1+1:s2-1);
    Nx=str2num(Nx);
    Ny=str2num(Ny);
    image_MV = fread(image_fid,[Ny,Nx],'int32','b');
    image_MV=image_MV./10000;
    dump=fread(image_fid,[1,3],'int32','b');
    pixelwidth=fread(image_fid,[1,1],'int32','b');
    pixelwidth=pixelwidth./10000;
    clear check
    clear det_name
    clear dir_name
    clear dump
    clear fid
    clear geom_name
    clear i
    clear image_fid
    clear images
    clear name
    clear s1
    clear s2
    clear setup_fid
    clear setup_name
    clear sim_type
    clear spectrum_name
    clear spectrum_type
    clear tline
    
    beep
end
    clear N
    clear Npad
    clear data_fid
    clear check
    clear det_name
    clear dir_name
    clear dump
    clear dump2
    clear fid
    clear geom_name
    clear i
    clear image_fid
    clear images
    clear name
    clear s1
    clear s2
    clear setup_fid
    clear setup_name
    clear sim_type
    clear spectrum_name
    clear spectrum_type
    clear tline
    clear temp
    clear temp2
    clear Nx
    clear Ny
    
    beep
end