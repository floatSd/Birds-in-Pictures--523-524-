function I=colorPrediction(I, regionMap, regions, labels, gridUnit, maxProb, probThreshold)

nRegions = size(regions,1);

% Define colors for each class
colors = [  163 195 0;      % Grass = green
            222 113 16;     % Buildings = orange
            108 61 20;      % Mud = brown
            114 49 135;     % Roads = purple
            20 234 206;     % Snow = aqua
            81 86 183;      % Water = navy blue
            148 207 246;    % Sky = light blue
            0 124 60;       % Leaves = dark green
            255 155 155;    % Bark = pink
            255 238 155;    % Sand = pale yellow
            255 255 51;     % Other = yellow
            236 2 2;    ];  % Bird = Red
            

% Convert to grayscale
gI = rgb2gray(I);
I(:,:,1) = gI;
I(:,:,2) = gI;
I(:,:,3) = gI;

% Paint over gray image
for i=1:nRegions
    if (labels(i) ~= -1 && maxProb(i) > probThreshold)%numel(find(regionMap == regions(i))) > gridUnit*gridUnit/2)
        I=colorImageRegion(I,regionMap,regions(i),colors(labels(i),:));
    end;
end;