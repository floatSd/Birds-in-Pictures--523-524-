function [counts] = computeVW(siftDescriptors, areas, nSiftDimensions, nSiftClusters, centroids)
%  Works on a set of categories as a whole.
% Author:   Nikhil Patwardhan
% Program:  To find visual word histograms for all images

multiplier = 10000;         % To prevent underflow in visual word kCounts
counts = {};

for k=1:length(siftDescriptors)
    nFiles = length(siftDescriptors{k});
    % Initialize a histogram of kCounts for all images
    % Each row is an image
    kCounts = double(zeros(nFiles,nSiftClusters));
    
    disp(nFiles);
    % Loop through all files' descriptors
    for i=1:nFiles
        % Get one descriptor
        s = siftDescriptors{k}{i};
        [r3,c3] = size(s);
        
        % For all features in that descriptor, find corresponding cluster
        for j=1:c3
            % Find closest cluster
            minC = inf;
            minT = inf;
            for t=1:nSiftClusters
                if (minC > norm(double(s(:,j)) - double(centroids(:,t))))
                    minC = norm(double(s(:,j)) - double(centroids(:,t)));
                    minT = t;
                end;
            end;
            kCounts(i,minT) = kCounts(i,minT) + 1;
        end;
        % Compute a normalized count
        kCounts(i,:) = double(kCounts(i,:))/norm(kCounts(i,:),1);
    end;
    counts{k} = kCounts';
end;