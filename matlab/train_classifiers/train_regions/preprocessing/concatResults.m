%{
To concatenate the results obtained by training various sets
%}

sets = {'set1','set2','set4','set6','set7'};

load(strcat('../../../../datafiles/region_training/tl_',sets{1}));
load(strcat('../../../../datafiles/region_training/rmap_',sets{1}));
    
fn = filenames;
tl = trainingMaps;
rm = regionMaps;

for i=2:length(sets)
    load(strcat('../../../../datafiles/region_training/tl_',sets{i}));
    load(strcat('../../../../datafiles/region_training/rmap_',sets{i}));
    fn = [fn filenames];
    tl = [tl;trainingMaps];
    rm = [rm regionMaps];
end;

filenames = fn;
trainingMaps = tl;
regionMaps = rm;

save('../../../../datafiles/region_training/concat_tl.mat','trainingMaps');
save('../../../../datafiles/region_training/concat_rmap.mat','regionMaps','filenames');