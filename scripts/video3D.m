function [x,y,z] = video3D(vol,cmap,filename,time)
    
    % set data type and scale image
    vol=double(vol);
    vol = vol ./ max(vol(:));
    sizeVol = size(vol);
    
    %% X dimension
    % setup video paramters
    x = VideoWriter([filename,'_x.avi'],'Uncompressed AVI');
    x.FrameRate = sizeVol(1)/time;
    colormap(cmap);
    open(x)
    
    % write frames
    for i = 1:sizeVol(1)
        writeVideo(x,squeeze(vol(i,:,:)));
    end
    close(x)
    
    %% y dimension
    % setup video paramters
    y = VideoWriter([filename,'_y.avi'],'Uncompressed AVI');
    y.FrameRate = sizeVol(2)/time;
    colormap(cmap);
    open(y)
    
    % write frames
    sizeVol = size(vol);
    for i = 1:sizeVol(2)
        writeVideo(y,squeeze(vol(:,i,:)));
    end
    close(y)
    
   %% X dimension
    % setup video paramters
    z = VideoWriter([filename,'_z.avi'],'Uncompressed AVI');
    z.FrameRate = sizeVol(3)/time;
    colormap(cmap);
    open(z)
    
    % write frames
    sizeVol = size(vol);
    for i = 1:sizeVol(3)
        writeVideo(z,squeeze(vol(:,:,i)));
    end
    close(z)
    
end