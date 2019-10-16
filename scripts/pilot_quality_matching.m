%function [] = pilot_quality_matching(img,ref)

% load in files
Hfile='C:\Users\tca11\Desktop\CNT\Projects\Hyperfine\data\P001_Hyperfine_07.29.19\nii\outputBrainExtractionBrain.nii.gz';
Bfile='D:\MICCAI_BraTS_2019_Data_Training\HGG\BraTS19_2013_2_1\BraTS19_2013_2_1_flair.nii.gz';
H = niftiread(Hfile); % NOTE: Hyperfine image has undergone brain extraction
B = niftiread(Bfile);

% mean-center intensity
H = double(H);
B = double(B);
max_intensity_ratio = max(H(:)) / max(B(:));
B = B .* max_intensity_ratio;
mean_intensity_diff = mean(H(find(H))) - mean(B(find(B)));
B = B + mean_intensity_diff;
B(B< mean_intensity_diff + 1) = 0;
H = int16(H);
B = int16(B);

% flip Hyperfine coronal axis to match BraTS
%H = H(:,146:-1:1,:); 
    
% register images
[optimizer, metric] = imregconfig('monomodal');
B_reg = imregister(B, H, 'affine', optimizer, metric);

% add in noise & reslice
noise_range = 4 * std(double(B_reg(find(B_reg))));
noise = noise_range * (rand(size(B_reg))-0.5);
noise = imgaussfilt3(noise,1); % smooth noise 
B_noise = B_reg + int16(noise);
%B_noise(B_noise < max(noise(:))) = 0;
B_reslice = imresize3(B_noise,size(H));

% save out
niftiwrite(B_reslice,'B_test');
niftiwrite(H,'H_test');


%end