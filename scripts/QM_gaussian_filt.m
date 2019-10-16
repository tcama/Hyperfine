function [val,p] = QM_gaussian_filt(img,ref,p)

    img_gauss = imgaussfilt3(img,p);
    my_corr = corrcoef(img_gauss,ref);
    if  my_corr(2) < 0
        val = 1;
    else
        val = 1 - my_corr(2);
    end
    
    
end