function [vw] = ...
    computeVisualWordFromSIFT(siftDescriptors, centroids, nSiftClusters)
% Compute visual words from a set of SIFT descriptors for a single region

nDescriptors = length(siftDescriptors);
visualWords = double(zeros(nSiftClusters,nDescriptors));

% Compute visual words for all descriptors
for i=1:nDescriptors
    oneDescriptor = siftDescriptors{i};
    [r3,c3] = size(oneDescriptor);

    for k=1:c3
        % Find closest cluster
        minC = inf;
        minT = inf;
        for t=1:nSiftClusters
            if (minC > norm(double(oneDescriptor(:,k)) - double(centroids(:,t))))
                minC = norm(double(oneDescriptor(:,k)) - double(centroids(:,t)));
                minT = t;
            end;
        end;
        visualWords(minT,i) = visualWords(minT,i) + 1;
    end;
end;

% Find the mean of the descriptors
vw = mean(visualWords,2);

% Normalize the SIFT histogram
vw = vw/norm(vw,1);