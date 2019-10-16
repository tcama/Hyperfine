function [val,vals,img_noise] = quality_match_ex(HF_filename,T3_filename,out_dir)

H_info = niftiinfo(HF_filename); % NOTE: Hyperfine image has undergone brain extraction
H = niftiread(H_info);

B_info = niftiinfo(T3_filename); % NOTE: Hyperfine image has undergone brain extraction
B = niftiread(B_info);

% make iamges same type
B = double(B);
H = double(H);

% define mask
mask = (B .* H)>0;

% apply mask
Bm = B .* double(mask);
Hm = H .* double(mask);

% normalize to same max value
Bm=Bm./max(Bm(:));
Hm=Hm./max(Hm(:));

% intial search grid
sigma_vals = 0.5:1:2.5;
N = length(sigma_vals);
noise_vals = 0.5:1:2.5;
M = length(noise_vals);
my_vals = zeros(N,M,M,M);
for i = 1:length(sigma_vals)
for j = 1:length(noise_vals)
for k = 1:length(noise_vals)
for l = 1:length(noise_vals)
[my_vals(i,j,k,l),img_noise] = QM_function2(Bm,Hm,1,sigma_vals(i),noise_vals(j),noise_vals(k),noise_vals(l));
end
end
end
end
[x,y,z,a] = ind2sub(size(my_vals),find(my_vals==min(my_vals(:))));
sigma = sigma_vals(x); noise_coef=noise_vals(y); noise_coef2=noise_vals(z); noise_coef3=noise_vals(a);
[sigma, noise_coef noise_coef2 noise_coef3]

% second grid search
options = optimoptions('fminunc');
fun = @(x) QM_function2(Bm,Hm,1,x(1),x(2),x(3),x(4));
[x2,val,exitflag,output]=fminunc(fun,[sigma,noise_coef,noise_coef2,noise_coef3],options);
x2
[val,img_noise] = QM_function2(Bm, Hm, 1, x2(1), x2(2), x2(3), x2(4));
figure
subplot(1,4,1)
imagesc(squeeze(Bm(:,:,19)))
caxis([0 1])
subplot(1,4,2)
imagesc(squeeze(img_noise(:,:,19)))
N = length(idx);
[a1,b1] = sort(img_noise(idx));
[a2,b2] = sort(Hm(idx));
max1 = a1(round(N*.9))
max2 = a2(round(N*.9))
caxis([0 max1/max2])
subplot(1,4,3)
imagesc(squeeze(Hm(:,:,19)))
caxis([0 1])
colormap gray
subplot(1,4,4)
histogram(img_noise(find(img_noise)),100)
hold on
histogram(Hm(find(Hm)),100)

% load in function
cd(out_dir)
save QM_output val img_noise sigma noise_coef noise_coef2 noise_coef3
info = B_info;
info.Filename = fullfile(out_dir,'QM_image.nii');
info.Datatype = 'double';

niftiwrite(img_noise,'QM_image',info);

end