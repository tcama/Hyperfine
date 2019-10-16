function [val,img_noise] = QM_function(img, ref, mask, sigma, noise_coef, noise_coef2, noise_coef3)
    
    load noise_var
%     noise1 = rand(size(img))-0.5;
%     noise2 = rand(size(img))-0.5;
%     noise3 = rand(size(img))-0.5;
    
    % fake mask
    if mask == 1
        mask = (img .* ref)>0;
    end
    
    % gaussian smoothing
    if sigma < 0.1
        sigma = 0.1;
    end
    img_gauss = imgaussfilt3(img,sigma);
    img_gauss = img_gauss .* double(mask);
    
    % add in noise
    noise_range = noise_coef * std(double(img_gauss(find(img_gauss))));
    noise_add = noise_range * noise1;
    noise_add = imgaussfilt3(noise_add,0.5); % smooth noise 
    img_noise = img_gauss + noise_add;
    
%    val = sum((ref(:)-img_gauss(:)).^2)/numel(ref);
    
    % reapply mask
    img_noise = img_noise .* double(mask);

    % add in noise
    noise_range = noise_coef2 * std(double(img_noise(find(img_noise))));
    noise_add = noise_range * noise2;
    noise_add = imgaussfilt3(noise_add,noise_coef3); % smooth noise 
    img_noise = img_noise + noise_add;
    
    % reapply mask
    img_noise = img_noise .* double(mask);
    
%     % add in noise
%     noise_range = noise_coef3 * std(double(img_noise(find(img_noise))));
%     noise_add = noise_range * noise3;
%     noise_add = imgaussfilt3(noise_add,2); % smooth noise 
%     img_noise = img_noise + noise_add;
%     
%     % reapply mask
%     img_noise = img_noise .* double(mask);
    
    % renormalize image
    idx = find(mask);
    img_clean = zeros(size(mask));
    img_clean = img_noise - min(img_noise(:));
    img_clean = img_clean .* mask;
    img_noise = img_clean;
    img_noise = img_noise./max(img_noise(:));
    
%     my_corr = corrcoef(img_noise(idx),ref(idx));
%     if  my_corr(2) < 0
%         val = 1;
%     else
%         val = 1 - my_corr(2);
%     end
    %val = abs(mean(img_noise(idx)) - mean(ref(idx))) + abs(std(img_noise(idx)) - std(ref(idx)));
    %val = abs((kurtosis(img_noise(idx))-3) - (kurtosis(ref(idx))-3)) + abs(skewness(img_noise(idx)) - skewness(ref(idx))) + abs(std(img_noise(idx)) - mean(std(ref(idx))));
    val = abs(skewness(img_noise(idx)) - skewness(ref(idx)))/10 + abs(std(img_noise(idx)) - mean(std(ref(idx))));
    %val = abs(std(img_noise(idx)) - std(ref(idx)));
    
    
end