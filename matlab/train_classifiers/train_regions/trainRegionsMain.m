gridUnit = 40;
nColorBins = 32;
nSiftClusters = 50;
nSiftDimensions = 128;
trainingPercentage = 0.5;

categoryNames = {'grass','buildings','mud','roads','snow','water',...
                 'sky','leaves','bark','sand','other','bird'};

chosenCategories=[1 2 4 5 6 7 12];          % You may not be interested in computing for all the categories

nCategories = length(chosenCategories);

models = cell(nCategories,1);
probMatrix = cell(nCategories,1);
testingSize = cell(nCategories,1);

addpath('./preprocessing/');
addpath('../common_training_code');
addpath('../../common_utils/');
addpath('../../common_utils/classifier/');
addpath('../../common_utils/region/');
addpath('../../common_utils/vlfeat-0.9.9/toolbox/mex/mexa64/');
addpath('../../common_utils/libsvm-mat-3.0-1/');

%% PART 1: Compute visual features
cd './preprocessing';
computeRegionFeatures(gridUnit, nColorBins, nSiftClusters, nSiftDimensions, '../../../../datafiles/region_training/', categoryNames, chosenCategories);           % TO DO Fix path problem Need to run only once
cd ..;
%% PART 2: Prepare sets of positive and negative examples
prepareTrainingMatrices('../../../datafiles/region_training/', nColorBins, nSiftClusters, nCategories, trainingPercentage);        % Need to run only once

%% PART 3: Train the models
% [models{1} probMatrix{1} testingSize{1}] = buildAndTestModel(1, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{2} probMatrix{2} testingSize{2}] = buildAndTestModel(2, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{3} probMatrix{3} testingSize{3}] = buildAndTestModel(3, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{4} probMatrix{4} testingSize{4}] = buildAndTestModel(4, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{5} probMatrix{5} testingSize{5}] = buildAndTestModel(5, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{6} probMatrix{6} testingSize{6}] = buildAndTestModel(6, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{7} probMatrix{7} testingSize{7}] = buildAndTestModel(7, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{8} probMatrix{8} testingSize{8}] = buildAndTestModel(8, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{9} probMatrix{9} testingSize{9}] = buildAndTestModel(9, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{10} probMatrix{10} testingSize{10}] = buildAndTestModel(10, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{11} probMatrix{11} testingSize{11}] = buildAndTestModel(11, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{12} probMatrix{12} testingSize{12}] = buildAndTestModel(12, 8, 2, '../../../datafiles/region_training/', nCategories);

for i=1:nCategories
    disp(sprintf('Category: %s',categoryNames{i}));
    [models{i} probMatrix{i} testingSize{i}] = buildAndTestModel(i, 128, 2, '../../../datafiles/region_training/', nCategories);
end;

save('../../../datafiles/region_training/models.mat','models');
%% PART 4: Process the results in a human understandable manner
reorderedProbMatrix = cell(nCategories,1);
for i=1:nCategories
    reorderedProbMatrix{i} = zeros(nCategories,testingSize{i});
    for j=1:nCategories
        reorderedProbMatrix{i}(j,:) = probMatrix{j}{i};
    end;
end;

% Compute confusion matrix
confusionMatrix = zeros(nCategories,nCategories);
for i=1:nCategories
    % Count how many times each label was maximum
    counts = zeros(nCategories,1);
    for k=1:testingSize{i}
        [value location] = max(reorderedProbMatrix{i}(:,k));
        counts(location) = counts(location) + 1;
    end;
    for j=1:nCategories
        confusionMatrix(i,j) = counts(j);
    end;
end;

accuracies = double(zeros(nCategories,1));
for i=1:nCategories
    disp(sprintf('Accuracy for label %s is %.2f %',categoryNames{chosenCategories(i)},100*confusionMatrix(i,i)/sum(confusionMatrix(i,:))));
    accuracies(i) = 100*double(confusionMatrix(i,i))/double(sum(confusionMatrix(i,:)));
end;

confusionMatrix(:,end+1)=accuracies';       % Append accuracies to the confusion matrix
confusionMatrix(:,end+1)=cell2mat(testingSize);     % Append testing sizes
confusionMatrix(:,end+1)=floor(cell2mat(testingSize) * trainingPercentage / (1 - trainingPercentage));   % Append training sizes
confusionMatrix(:,end+1)=confusionMatrix(:,end) + confusionMatrix(:,end-1);   % Append total sizes
save('../../../datafiles/region_training/confusion.mat','confusionMatrix');