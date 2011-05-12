categoryNames = {'grass','buildings','mud','roads','snow','water',...
                 'sky','leaves','bark','sand','other','bird'};

chosenCategories=[1 2 4 5 6 7 12];             % You may not be interested in computing for all the categories
nCategories = length(chosenCategories);     % Number of Categories

baseDir = '../../datafiles/tests/try1/';

gridUnit = 40;
nColorBins = 32;
nSiftClusters = 50;

matDirectory = strcat(baseDir,'mat/');

load (strcat(baseDir,'models.mat'));
load (strcat(baseDir,'centroids.mat'));

filesList = dir(matDirectory);
[mRows, mCols] = size(filesList);

jpgList = dir(strcat(baseDir,'*.jpg'));

% Process all images in a certain directory
for k=1:mRows-2
    filename = strcat(imageDirectory,filesList(k+2).name);
    fprintf('Reading file: %s\n',filename);
    
    load(filename);
    
    jpgname = jpgList(k).name;
    
    fprintf('Corresponding jpg file: %s\n',jpgname);
    
    I = imread(strcat(baseDir,jpgname));
    if (size(I,2) > 400)
        % Resize width to maxImgWidth
        I = imresize(I, double(400/size(I,2)));
    end;

    % Attempt recognizing segments
    [labels maxProb] = tryPrediction(I, regionMap, unique(regionMap), nColorBins, nSiftClusters, nCategories, models, gridUnit, centroids);

    % Map the returned labels to the chosen labels
    for i=1:length(labels)
        if (labels(i) ~= -1)
            labels(i) = chosenCategories(labels(i));
        end;
    end;

    % Color the image
    I = colorPrediction(I, regionMap, unique(regionMap), labels, gridUnit, maxProb, 0.15);
    
    [pathstr name ext] = fileparts(filename);
    imwrite(I,sprintf('%s%s.png',baseDir,name));
    
    clearvars 'regionMap';
end;