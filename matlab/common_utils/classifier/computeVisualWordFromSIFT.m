function [visualWord] = ...
    computeVisualWordFromSIFT(siftDescriptor, centroids, nSiftClusters, ...
                            multiplier, sourceArea)
% Compute visual words from that SIFT descriptor
visualWord = double(zeros(nSiftClusters,1));
[r3,c3] = size(siftDescriptor);

for k=1:c3
    % Find closest cluster
    minC = inf;
    minT = inf;
    for t=1:nSiftClusters
        if (minC > norm(double(siftDescriptor(:,k)) - double(centroids(:,t))))
            minC = norm(double(siftDescriptor(:,k)) - double(centroids(:,t)));
            minT = t;
        end;
    end;
    visualWord(minT) = visualWord(minT) + 1;
end;

visualWord = double(visualWord * multiplier) / double(sourceArea);