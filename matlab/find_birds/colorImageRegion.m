function I=colorImageRegion(I,regionMap,regid,color)
temp = I(:,:,1); temp(find(regionMap == regid)) = color(1); I(:,:,1) = temp;
temp = I(:,:,2); temp(find(regionMap == regid)) = color(2); I(:,:,2) = temp;
temp = I(:,:,3); temp(find(regionMap == regid)) = color(3); I(:,:,3) = temp;