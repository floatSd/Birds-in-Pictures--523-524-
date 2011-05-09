% Load the training and testing data
load('../../../datafiles/region_training/trainingMatrices.mat');
iCategoryLabel = 7;
            
bestcv = 0;
for log2c = -1:5,
  for log2g = -4:1,
    cmd = ['-v 5 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
    cv = svmtrain(trainingLabels{iCategoryLabel}, trainingMatrices{iCategoryLabel}', cmd);
    if (cv >= bestcv),
      bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
    end
    fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
  end
end