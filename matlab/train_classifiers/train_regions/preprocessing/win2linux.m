% Replace JPG with jpg
for i=1:length(filenames)
if (substr(filenames{i},-3,3) == 'JPG')
filenames{i} = regexprep(filenames{i},'JPG','jpg');
end;
end;

addpath('../../../common_utils');
load('../../../../datafiles/region_training/seg_set1.mat');
nfiles = {};
for i=1:length(filenames)
nfiles{i} = sprintf('../../../../datafiles/region_training/original_images/set1/%s',substr(filenames{i},13,length(filenames{i})));
end;
filenames = nfiles;
save('rmap_set1.mat','regionMaps','filenames');

clear;

load('../../../../datafiles/region_training/seg_set2.mat');
nfiles = {};
for i=1:length(filenames)
nfiles{i} = sprintf('../../../../datafiles/region_training/original_images/set2/%s',substr(filenames{i},13,length(filenames{i})));
end;
filenames = nfiles;
save('rmap_set2.mat','regionMaps','filenames');

clear;

load('../../../../datafiles/region_training/seg_set3.mat');
nfiles = {};
for i=1:length(filenames)
nfiles{i} = sprintf('../../../../datafiles/region_training/original_images/set3/%s',substr(filenames{i},13,length(filenames{i})));
end;
filenames = nfiles;
save('rmap_set3.mat','regionMaps','filenames');

clear;

load('../../../../datafiles/region_training/seg_set4.mat');
nfiles = {};
for i=1:length(filenames)
nfiles{i} = sprintf('../../../../datafiles/region_training/original_images/set4/%s',substr(filenames{i},13,length(filenames{i})));
end;
filenames = nfiles;
save('rmap_set4.mat','regionMaps','filenames');

clear;

load('../../../../datafiles/region_training/seg_set5.mat');
nfiles = {};
for i=1:length(filenames)
nfiles{i} = sprintf('../../../../datafiles/region_training/original_images/set5/%s',substr(filenames{i},13,length(filenames{i})));
end;
filenames = nfiles;
save('rmap_set5.mat','regionMaps','filenames');

clear;

load('../../../../datafiles/region_training/seg_set6.mat');
nfiles = {};
for i=1:length(filenames)
nfiles{i} = sprintf('../../../../datafiles/region_training/original_images/set6/%s',substr(filenames{i},13,length(filenames{i})));
end;
filenames = nfiles;
save('rmap_set6.mat','regionMaps','filenames');

clear;

load('../../../../datafiles/region_training/seg_set7.mat');
nfiles = {};
for i=1:length(filenames)
nfiles{i} = sprintf('../../../../datafiles/region_training/original_images/set7/%s',substr(filenames{i},13,length(filenames{i})));
end;
filenames = nfiles;
save('rmap_set7.mat','regionMaps','filenames');