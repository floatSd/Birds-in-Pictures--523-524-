function colorImageSet(setName)
%% TASK : Coloring regions in images with associated region IDs

baseImageDirectory = '../../../../datafiles/region_training/';

% Add the necessary paths
addpath('../../../common_utils/');
addpath('../../../common_utils/classifier/');
addpath('../../../common_utils/region/');
addpath('../../../common_utils/segmentation/');

loadFile = sprintf('%srmap_%s.mat',baseImageDirectory,setName);
load(loadFile);             % get filenames{} and regionMaps{}
maxImgWidth = 400;

nFiles = length(filenames);
segfilenames = cell(nFiles,1);
for i=1:nFiles
    kRegionMap = regionMaps{i};
    I = imread(filenames{i});
    if (size(I,2) > maxImgWidth)
        % Resize width to maxImgWidth
        I = imresize(I, double(maxImgWidth/size(I,2)));
    end;

    [height,width,z] = size(I);
    nRegions = numel(unique(kRegionMap));
    [coloredSegments] = colorSegmentedImage(kRegionMap, nRegions, height, width);
    
    newfilename = sprintf('%scolored_segments/%s/training_%d_regions_%d.png',baseImageDirectory,setName,i,nRegions);
    segfilenames{i} = newfilename;
    % Save segmentation result
    imwrite(coloredSegments,newfilename);
end;

savefile = sprintf('%ssfn_%s.mat',baseImageDirectory,setName);
save(savefile,'segfilenames');