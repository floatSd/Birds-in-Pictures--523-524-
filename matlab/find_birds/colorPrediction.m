% Looks at the predicted label and assigns an appropriate color

% Grass (1) = Green
% Buildings (2) = Red
% Mud (3) = Brown
% Roads (4) = Grey
% Snow (5) = White
% Water (6) = Blue
function colorPrediction(I, regionMap, topRegions, topLabels, filename)

numTopRegions = size(topRegions,1);

for i=1:numTopRegions
    switch topLabels(i)
        case 1
            temp = I(:,:,1); temp(find(regionMap == topRegions(i))) = 0; I(:,:,1) = temp;    % Red Channel 0
            temp = I(:,:,2); temp(find(regionMap == topRegions(i))) = 255; I(:,:,2) = temp;    % Green Channel 255
            temp = I(:,:,3); temp(find(regionMap == topRegions(i))) = 0; I(:,:,3) = temp;    % Blue Channel 0
        case 2
            temp = I(:,:,1); temp(find(regionMap == topRegions(i))) = 255; I(:,:,1) = temp;    % Red Channel 255
            temp = I(:,:,2); temp(find(regionMap == topRegions(i))) = 0; I(:,:,2) = temp;    % Green Channel 0
            temp = I(:,:,3); temp(find(regionMap == topRegions(i))) = 0; I(:,:,3) = temp;    % Blue Channel 0
        case 3
            temp = I(:,:,1); temp(find(regionMap == topRegions(i))) = 147; I(:,:,1) = temp;
            temp = I(:,:,2); temp(find(regionMap == topRegions(i))) = 99; I(:,:,2) = temp;
            temp = I(:,:,3); temp(find(regionMap == topRegions(i))) = 43; I(:,:,3) = temp;
        case 4
            temp = I(:,:,1); temp(find(regionMap == topRegions(i))) = 193; I(:,:,1) = temp;
            temp = I(:,:,2); temp(find(regionMap == topRegions(i))) = 193; I(:,:,2) = temp;
            temp = I(:,:,3); temp(find(regionMap == topRegions(i))) = 193; I(:,:,3) = temp;
        case 5
            temp = I(:,:,1); temp(find(regionMap == topRegions(i))) = 255; I(:,:,1) = temp;
            temp = I(:,:,2); temp(find(regionMap == topRegions(i))) = 255; I(:,:,2) = temp;
            temp = I(:,:,3); temp(find(regionMap == topRegions(i))) = 255; I(:,:,3) = temp;
        case 6
            temp = I(:,:,1); temp(find(regionMap == topRegions(i))) = 0; I(:,:,1) = temp;
            temp = I(:,:,2); temp(find(regionMap == topRegions(i))) = 0; I(:,:,2) = temp;
            temp = I(:,:,3); temp(find(regionMap == topRegions(i))) = 255; I(:,:,3) = temp;
    end;
end;

newfilename = sprintf('%s_R_%d_L_%d_R_%d_L_%d_R_%d_L_%d.png',filename,topRegions(1),topLabels(1),topRegions(2),topLabels(2),topRegions(3),topLabels(3));
imwrite(I,newfilename);