function F=tintImage(I,mask,amt,channel)
% Function to apply a tint to a part of an image
% I = uint8 image
% amt = between 0-1
% channel = red/green/blue
% mask = mask to apply tint
% 
% Example:
% I =imread('cg1.jpg');
% [m,n,z] = size(I);
% mask=zeros(m,n,'uint8');
% mask(:,1:40) = 1;
% F = tintImage(I,mask,0.2,'red');
% imshow(F);
%
% Author: Nikhil Patwardhan
F = zeros(size(I),'uint8');
F = I;
% disp(sprintf('Color: %d',255*amt));
switch lower(channel)
    case 'red'
        F(:,:,1) = 255 * amt .* mask;
        F(:,:,2) = 0;
        F(:,:,3) = 0;
%         F(:,:,1) = I(:,:,1) .* mask * amt;
%         F(:,:,2) = I(:,:,2) .* mask;
%         F(:,:,3) = I(:,:,3) .* mask;
    case 'green'
%         F(:,:,2) = I(:,:,2) .* mask * amt;
%         F(:,:,1) = I(:,:,1) .* mask;
%         F(:,:,3) = I(:,:,3) .* mask;
        F(:,:,2) = 255 * amt .* mask;
        F(:,:,1) = 0;
        F(:,:,3) = 0;
    case 'blue'
%         F(:,:,3) = I(:,:,3) .* mask * amt;
%         F(:,:,1) = I(:,:,1) .* mask;
%         F(:,:,2) = I(:,:,2) .* mask;
        F(:,:,3) = 255 * amt .* mask;
        F(:,:,2) = 0;
        F(:,:,1) = 0;
end;
F;