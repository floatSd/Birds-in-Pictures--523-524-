function [centroids] = ...
    computeSIFTClusters(siftmatfile, nSiftDimensions, nSiftClusters, nRandomSelect)
%% Clusters the SIFT descriptors by selecting some of them at random.
%  matfile = cell array with all categories' sift descriptors.
%  Works on a set of categories as a whole.

if (nargin < 4)
    nRandomSelect = 0.25;       % Percentage of features to be selected
end;

all = [];

load(siftmatfile);          % siftDescriptors
for k=1:length(siftDescriptors)
    % Find how many descriptors
    q = size(siftDescriptors{k},1);

    % Loop through all descriptors
    for i=1:q
        % Get one descriptor
        s = siftDescriptors{k}{i};
        [r,c] = size(s);

        if (r ~= nSiftDimensions)
            continue;
        end;

        % Get random 15% of its features
        n = ceil(nRandomSelect*c);
        nos = rand(n,1);
        % Map 0.0 - 1.0 to 1.0 - n
        nos = floor(1 + (n-1)*nos);

        % Concatenate all 'n' columns of s into one matrix
        concat = zeros(nSiftDimensions,n);
        for j=1:n
            concat(:,j) = s(:,nos(j));
        end;

        clearvars s;
        clearvars n;
        clearvars nos;

        % Concatenate s to all
        all = [all concat];
    end;
end;

% Apply kmeans on the randomly selected SIFT descriptors
[IDX,centroids] = kmeans(all',nSiftClusters);
centroids = centroids';