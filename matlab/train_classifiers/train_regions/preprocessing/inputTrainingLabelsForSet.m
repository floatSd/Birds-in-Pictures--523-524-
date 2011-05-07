function inputTrainingLabelsForSet(setName)
%% TASK : Manually labelling regions in images
upperSetName = upper(setName);
loadFile1 = sprintf('.\\regionResults\\segmentation%s.mat',upperSetName);
loadFile2 = sprintf('.\\coloredSegments\\%s\\segFileNames%s.mat',setName,upperSetName);

load(loadFile1);        % Get filenames{} and regionMaps{}
load(loadFile2);        % Get segfilenames{}

nFiles = length(filenames);
nCategories = 12;

% Initialize
trainingMaps = cell(nFiles,1);
for i=1:nFiles
    trainingMaps{i} = cell(nCategories,1);
end;

prompt = {'Region IDs for Grass','Region IDs for Buildings','Region IDs for Mud',...
            'Region IDs for Roads','Region IDs for Snow','Region IDs for Water',...
            'Region IDs for Sky','Region IDs for Leaves','Region IDs for Bark',...
            'Region IDs for Sand','Region IDs for Other','Region IDs for Bird'};

numlines = 1;

% For all files (images)
for i=1:nFiles
    % Get original and segmented files
    origFilename = filenames{i};
    segFilename = segfilenames{i};
    
    [origImage, map1] = imread(origFilename);
    [segImage, map2] = imread(segFilename);
    
    [width, height, z] = size(origFilename);
    
    subplot(1,2,1), imshow(origImage), set(gcf, 'Position', get(0, 'ScreenSize'))
    subplot(1,2,2), imshow(segImage), set(gcf, 'Position', get(0, 'ScreenSize'))
    
    name = sprintf('Training for file: %s',origFilename);
    answer = inputdlg(prompt, name, numlines);
    
    if ~isempty(answer)
        for j=1:nCategories
            if (~isempty(answer{j}))
                trainingMaps{i}{j} = str2num(answer{j});
            else
                trainingMaps{i}{j} = [];
            end;
        end;
    else
        for j=1:nCategories
            trainingMaps{i}{j} = [];
        end;
    end;
end;

savefilename = sprintf('trainingLabels%s.mat',setName);
save(savefilename,'trainingMaps');