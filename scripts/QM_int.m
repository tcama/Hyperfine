function [val] = QM_int(img,ref,thres,int_val)
    

    % decrease low intensity value contrast
    img_intensity = img;
    for i = 1:numel(img)
        if img(i) < thres
            img_intensity(i) = img(i) + rand(1) * int_val ;
        end
    end
    
    % SSD as similarity measure
    % val = sum((ref(:)-img_intensity(:)).^2)/numel(ref);
    
    % correlation as similarity measure
    my_corr = corrcoef(img_intensity,ref);
    if  my_corr(2) < 0
        val = 1;
    else
        val = 1 - my_corr(2);
    end
    
end