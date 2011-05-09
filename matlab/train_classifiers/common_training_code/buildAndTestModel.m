function [model probMatrix testingSize] = buildAndTestModel(iCategoryLabel, c, g, baseDirectory, nCategories)

addpath('../../common_utils/');
addpath('../../common_utils/classifier/');
addpath('../../common_utils/region/');
addpath('../../common_utils/vlfeat-0.9.9/toolbox/mex/mexa64/');
addpath('../../common_utils/libsvm-mat-3.0-1/');

load(strcat(baseDirectory,'trainingMatrices.mat'));
disp('Building models...');

str = sprintf('-c %d -g %f -b 1',c,g);
model = svmtrain(trainingLabels{iCategoryLabel},...
                trainingMatrices{iCategoryLabel}', str);
            
disp('Predicting...');

testingSize = size(testingMatrices{iCategoryLabel},2);

probMatrix = {};
if (testingSize > 1)
    for j=1:nCategories               % For all models
        % Test all categories with all models
        [predictedLabel, accuracy, prob] = ...
                    svmpredict(testingLabels{j},...
                                testingMatrices{j}', model, '-b 1');
        probMatrix{j} = prob(:,1)';
    end;
else
    for j=1:nCategories               % For all models
        probMatrix{j} = zeros(1,1);
    end;
end;