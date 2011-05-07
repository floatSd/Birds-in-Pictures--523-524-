
%% Available images
% Grass     : 172 images
% Buildings : 132 images
% Mud       : 70 images
% Roads     : 90 images
% Snow      : 98 images
% Water     : 111 images

% Train on 50%, Test on 50%

clear;
clc;
nCategories = 6;
models = cell(nCategories,1);
probMatrix = cell(nCategories,1);
testingSize = cell(nCategories,1);

addpath('../common_training_code');

%% PART 1: Compute visual features
% computeImageFeatures;           % Need to run only once

%% PART 2: Prepare sets of positive and negative examples
% prepareTrainingMatrices;        % Need to run only once

%% PART 3: Train the models
%  The below values give higher individual accuracies, but lower overall
%  accuracies in the confusion matrix.
[models{1} probMatrix{1} testingSize{1}] = buildAndTestModel(1, 400, 1/365);
[models{2} probMatrix{2} testingSize{2}] = buildAndTestModel(2, 400, 1/365);
[models{3} probMatrix{3} testingSize{3}] = buildAndTestModel(3, 10, 1/16);
[models{4} probMatrix{4} testingSize{4}] = buildAndTestModel(4, 100, 1/8);
[models{5} probMatrix{5} testingSize{5}] = buildAndTestModel(5, 300, 1/170);
[models{6} probMatrix{6} testingSize{6}] = buildAndTestModel(6, 100, 9.9/128);

%  The below values give lower individual accuracies, but higher overall
%  accuracies in the confusion matrix.
% [models{1} probMatrix{1} testingSize{1}] = buildAndTestModel(1, 800, 0.1);
% [models{2} probMatrix{2} testingSize{2}] = buildAndTestModel(2, 800, 0.1);
% [models{3} probMatrix{3} testingSize{3}] = buildAndTestModel(3, 800, 0.1);
% [models{4} probMatrix{4} testingSize{4}] = buildAndTestModel(4, 800, 0.1);
% [models{5} probMatrix{5} testingSize{5}] = buildAndTestModel(5, 800, 0.1);
% [models{6} probMatrix{6} testingSize{6}] = buildAndTestModel(6, 800, 0.1);

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
    disp(sprintf('Accuracy for label %d is %.2f %',i,100*confusionMatrix(i,i)/sum(confusionMatrix(i,:))));
    accuracies(i) = 100*double(confusionMatrix(i,i))/double(sum(confusionMatrix(i,:)));
end;
save('confusion.mat','confusionMatrix');