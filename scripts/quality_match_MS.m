function [HF_img,tform] = quality_match_MS(img,ref)

% flip Hyperfine coronal axis to match BraTS
ref = ref(:,:,36:-1:1); 

% % register images
% [optimizer, metric] = imregconfig('monomodal');
% optimizer.MaximumStepLength = 0.01;
% %img_reg = imregister(img, ref, 'affine', optimizer, metric);
% tform = imregtform(img, ref, 'affine', optimizer, metric);
% img_reg = imwarp(img,tform);
tform = NaN;
img_reg = img;
%

% reslice to same size as hyperfine
img_reg = imresize3(img_reg,size(ref));

% get index for each image
idx_img = find(img_reg);
idx_ref = find(ref);

for i = 1:length(idx_img)
    if img_reg(idx_img(i)) < 50
        n = rand;
        img_reg(idx_img(i)) = img_reg(idx_img(i)) + 30 + (25 * n);
    end
end

% apply gaussian filter to smooth image
img_smooth = imgaussfilt3(img_reg,0.6); % smooth noise 
img_sm = zeros(size(img_smooth));
img_sm(idx_img) = img_smooth(idx_img);

% add in noise & reslice
noise_range = 3 * std(double(img_sm(find(img_sm))));
noise = noise_range * (rand(size(img_sm))-0.5);
noise = imgaussfilt3(noise,1); % smooth noise 
img_noise = img_sm + single(noise);
%B_noise(B_noise < max(noise(:))) = 0;

% add in noise & reslice
noise_range = 2 * std(double(img_sm(find(img_sm))));
noise = noise_range * (rand(size(img_sm))-0.5);
noise = imgaussfilt3(noise,0.5); % smooth noise 
img_noise = img_noise + single(noise);
%B_noise(B_noise < max(noise(:))) = 0;
A = zeros(size(img_noise));
A(idx_img) = img_noise(idx_img);
img_noise = A;

% figure
% colormap gray
% subplot(2,2,1)
% imagesc(squeeze(img(:,:,16)))
% subplot(2,2,2)
% imagesc(squeeze(ref(:,:,18)))
% subplot(2,2,3)
% imagesc(squeeze(img_noise(:,:,18)))

% mean-center intensity
ref = double(ref);
HF_img = double(img_noise);

HF_img = HF_img - min(HF_img(idx_img)); % set minimun to zero for scaling
max_intensity_ratio = max(ref(:)) / max(HF_img(:));
HF_img = HF_img .* 8;%max_intensity_ratio;
HF_img = HF_img + min(ref(idx_ref));

% subplot(2,2,4)
% histogram(ref(idx_ref))
% hold on
% idx = find(img_noise);
% hold on; histogram(HF_img(idx))

end