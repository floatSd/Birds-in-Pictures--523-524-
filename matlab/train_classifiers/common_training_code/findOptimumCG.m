% Load the training and testing data
load('../../../datafiles/region_training/trainingMatrices.mat');

addpath('../../common_utils/libsvm-mat-3.0-1/');

bc=[];
bestcv = 0;

categoryNames = {'grass','buildings','mud','roads','snow','water',...
                 'sky','leaves','bark','sand','other','bird'};

chosenCategories=[1 2 4 5 6 7 12];          % You may not be interested in computing for all the categories

for i=1:length(chosenCategories)
bestcv=0;
for log2c = -1:8,
  for log2g = -4:1,
    cmd = ['-v 5 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
    cv = svmtrain(trainingLabels{i}, trainingMatrices{i}', cmd);
    if (cv >= bestcv),
      bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
    end
    fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
  end
end

    bc(1,i) = bestc;
    bc(2,i) = bestg;
    bc(3,i) = bestcv;
end;

save('../../../datafiles/region_training/bestcg.mat','bc');
