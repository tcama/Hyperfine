%Hfile='C:\Users\tca11\Desktop\CNT\Projects\Hyperfine\data\P001_Hyperfine_07.29.19\nii\outputBrainExtractionBrain.nii.gz';
%Bfile='D:\MICCAI_BraTS_2019_Data_Training\HGG\BraTS19_2013_2_1\BraTS19_2013_2_1_flair.nii.gz';

Hfile='C:\Users\tca11\Desktop\CNT\Projects\Hyperfine\data\832913_Stein_Hyperfine\tmp\sub1_FLAIR_HF2.nii.gz';
H_info = niftiinfo(Hfile); % NOTE: Hyperfine image has undergone brain extraction
H = niftiread(H_info);

Bfile='C:\Users\tca11\Desktop\CNT\Projects\Hyperfine\data\832913_Stein_Hyperfine\tmp\resliced_sub1_FLAIR.nii.gz';
B_info = niftiinfo(Bfile); % NOTE: Hyperfine image has undergone brain extraction
B = niftiread(B_info);

% mask images
maskfile = 'C:\Users\tca11\Desktop\CNT\Projects\Hyperfine\data\P001_Hyperfine_07.29.19\nii\outputBrainExtractionMask.nii.gz';
mask = niftiread(maskfile);

% make iamges same type
B = double(B);
H = double(H);

% normalize to same max value
B=B./max(B(:));
H=H./max(H(:));

% apply mask
Bm = B .* double(mask);
Hm = H .* double(mask);

% normalize to same max value
Bm=Bm./max(Bm(:));
Hm=Hm./max(Hm(:));



figure
subplot(1,2,1)
imagesc(squeeze(B(:,:,18)))
subplot(1,2,2)
imagesc(squeeze(H(:,:,18)))

%H = H(:,end:-1:1,:);
%subplot(1,3,3)
%imagesc(squeeze(H(:,:,15)))


% [optimizer, metric] = imregconfig('multimodal');
% optimizer.MaximumStepLength =0.01
% optimizer.InitialRadius =0.001
% B_reg = imregister(B, H, 'rigid', optimizer, metric);

% fig1 = figure;
% subplot(1,2,1)
% imagesc(squeeze(B_reg(:,:,15)))
% subplot(1,2,2)
% imagesc(squeeze(H(:,:,15)))
% title('check registration');

%fun = @(p) QM_gaussian_filt(B,H,p); % Gaussian smoothing filter
x=[1,1,1];
fun = @(x) QM_function(B,H,x(1),x(2),x(3));
options = optimoptions('fminunc');
options.OptimalityTolerance = 1e-14;
options.StepTolerance = 1e-14;
[x2,val]=fminunc(fun,x,options);
