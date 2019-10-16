addpath('C:\Users\tca11\Desktop\CNT\Projects\Hyperfine\scripts');
vals = [0.5000    2.5000    1.5000    0.5000]; % values used for image transformation

% get subject for processing
cd('D:\MS_lesion_data\train');
subs = dir('*FLAIR.nii');

% read in HF image for resizing images
HF = dir('C:\Users\tca11\Desktop\CNT\Projects\Hyperfine\tmp\P001_clinical\HF_BrainExtractionBrain.nii.gz');
HF = niftiread(fullfile(HF.folder,HF.name));
HF = double(HF); % convert to floating point
HF = HF ./ max(HF(:)); % normalize to one

% make output directory
outdir = 'D:\MS_SEG_2008_HF_like\';
mkdir(outdir);

% loop through each subject
for sub = 1:length(subs)
    
    % read in flair image
    path_flair = fullfile(subs(sub).folder,subs(sub).name);
    flair = niftiread(path_flair); 
    % read in segmentation
    path_seg = dir([subs(sub).folder,'\*_lesion.nii']);
    path_seg = fullfile(path_seg(sub).folder,path_seg(sub).name);
    seg = niftiread(path_seg); 
    
    % resize images and normalize intensity of image
    flair = flair(:,end:-1:1,:); % flip to match HF orientation
    flair = flair(70:450,50:475,100:400); % decrease boarder
    flair = double(flair); % convert to floating point
    flair = flair ./ max(flair(:)); % normalize to one
    flair = imresize3(flair,size(HF)); % resize to HF
    
    % generate mask of brain and skull
    mask = imgaussfilt(flair,3);
    mask = mask > 0.05;
    CC = bwconncomp(mask); % get clusters
    CC_length = [];
    for i = 1:length(CC.PixelIdxList)
        CC_length(i) = length(CC.PixelIdxList{i}); % get cluster sizes
    end
    [voxels,idx] = max(CC_length);
    mask = zeros(size(flair));
    mask(CC.PixelIdxList{idx}) = 1; % mask of only largest cluster
    mask = imfill(mask); % fill in holes in mask
    
    % match sizing for segmentation
    seg = seg(:,end:-1:1,:); % flip to match HF orientation
    seg = seg(70:450,50:475,100:400); % decrease boarder
    seg = imresize3(seg,size(HF)); % resize to HF
    
    ref = ones(size(flair)); % provide mask that includes all voxels
    [val,img_noise] = QM_function2(flair,ref,1,vals(1),vals(2),vals(3),vals(4));
    
    % add mask to reduce noise outside of iamge
    img_noise = img_noise .* mask;
    
    % save out slices into appropriate folders
    mkdir(fullfile(outdir,subs(sub).name));
    mkdir(fullfile(outdir,subs(sub).name,'1'));
    mkdir(fullfile(outdir,subs(sub).name,'0'));
    for i = 1:size(img_noise,3)
        cur_slice = squeeze(img_noise(:,:,i));
        cur_seg = squeeze(seg(:,:,i));
        if sum( cur_seg(:) ) >= 1
            filename = fullfile(outdir,subs(sub).name,'1',['slice',num2str(i),'_lesion.png']);
            imwrite(cur_slice,filename)
        else
            filename = fullfile(outdir,subs(sub).name,'0',['slice',num2str(i),'_nonlesion.png']);
            imwrite(cur_slice,filename)
        end 
    end
    
%     idx = find(img_noise .* HF);
%     subplot(1,4,1)
%     imagesc(squeeze(flair(:,:,19)))
%     subplot(1,4,2)
%     imagesc(squeeze(img_noise(:,:,19)))
%     N = length(idx);
%     [a1,b1] = sort(img_noise(idx));
%     [a2,b2] = sort(HF(idx));
%     max1 = a1(round(N*.9))
%     max2 = a2(round(N*.9))
%     subplot(1,4,3)
%     imagesc(squeeze(HF(:,:,19)))
%     colormap gray
%     subplot(1,4,4)
%     histogram(img_noise(find(img_noise)),100)
%     hold on
%     histogram(HF(find(HF)),100)
%     cd ..
%     pause
end

%% original MS data

addpath('C:\Users\tca11\Desktop\CNT\Projects\Hyperfine\scripts');
vals = [0.5000    2.5000    1.5000    0.5000]; % values used for image transformation

% get subject for processing
cd('D:\MS_lesion_data\train');
subs = dir('*FLAIR.nii');

% make output directory
outdir = 'D:\MS_SEG_2008\';
mkdir(outdir);

% loop through each subject
for sub = 1:length(subs)
    
    % read in flair image
    path_flair = fullfile(subs(sub).folder,subs(sub).name);
    flair = niftiread(path_flair); 
    % read in segmentation
    path_seg = dir([subs(sub).folder,'\*_lesion.nii']);
    path_seg = fullfile(path_seg(sub).folder,path_seg(sub).name);
    seg = niftiread(path_seg); 
    
    % resize images and normalize intensity of image
    flair = flair(:,end:-1:1,:); % flip to match HF orientation
    flair = flair(70:450,50:475,100:400); % decrease boarder
    flair = double(flair); % convert to floating point
    flair = flair ./ max(flair(:)); % normalize to one
    
    % generate mask of brain and skull
    mask = imgaussfilt(flair,3);
    mask = mask > 0.05;
    CC = bwconncomp(mask); % get clusters
    CC_length = [];
    for i = 1:length(CC.PixelIdxList)
        CC_length(i) = length(CC.PixelIdxList{i}); % get cluster sizes
    end
    [voxels,idx] = max(CC_length);
    mask = zeros(size(flair));
    mask(CC.PixelIdxList{idx}) = 1; % mask of only largest cluster
    mask = imfill(mask); % fill in holes in mask
    
    % match sizing for segmentation
    seg = seg(:,end:-1:1,:); % flip to match HF orientation
    seg = seg(70:450,50:475,100:400); % decrease boarder
    
    % add mask to reduce noise outside of iamge
    img_noise = flair .* mask;
    
    % save out slices into appropriate folders
    mkdir(fullfile(outdir,subs(sub).name));
    mkdir(fullfile(outdir,subs(sub).name,'1'));
    mkdir(fullfile(outdir,subs(sub).name,'0'));
    for i = 1:size(img_noise,3)
        cur_slice = squeeze(img_noise(:,:,i));
        cur_seg = squeeze(seg(:,:,i));
        if sum( cur_seg(:) ) >= 1
            filename = fullfile(outdir,subs(sub).name,'1',['slice',num2str(i),'_lesion.png']);
            imwrite(cur_slice,filename)
        else
            filename = fullfile(outdir,subs(sub).name,'0',['slice',num2str(i),'_nonlesion.png']);
            imwrite(cur_slice,filename)
        end 
    end
    
%     idx = find(img_noise .* HF);
%     subplot(1,4,1)
%     imagesc(squeeze(flair(:,:,19)))
%     subplot(1,4,2)
%     imagesc(squeeze(img_noise(:,:,19)))
%     N = length(idx);
%     [a1,b1] = sort(img_noise(idx));
%     [a2,b2] = sort(HF(idx));
%     max1 = a1(round(N*.9))
%     max2 = a2(round(N*.9))
%     subplot(1,4,3)
%     imagesc(squeeze(HF(:,:,19)))
%     colormap gray
%     subplot(1,4,4)
%     histogram(img_noise(find(img_noise)),100)
%     hold on
%     histogram(HF(find(HF)),100)
%     cd ..
%     pause
end