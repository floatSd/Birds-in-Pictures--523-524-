function [outerBorderPixels] = getOuterBorder(window, regid)

boolWindow = window == regid;                           % Get the matrix of all pixels of the region
newWindow = boolean(zeros(size(boolWindow)));                                 % Initialize
exactBorder = TRACE_MooreNeighbourhood(boolWindow);     % Get the list of all border pixels of the region

[r1,c1] = size(exactBorder);
[r2,c2] = size(boolWindow);
% Add a pixel all around the region of the same value
for i=1:r1
    if (exactBorder(i,1)-1) >= 1                                % Add above
        newWindow(exactBorder(i,1)-1, exactBorder(i,2)) = 1;
    end;
    
    if (exactBorder(i,1)+1) <= r2                               % Add below
        newWindow(exactBorder(i,1)+1, exactBorder(i,2)) = 1;
    end;
    
    if (exactBorder(i,2)-1) >= 1                                % Add left
        newWindow(exactBorder(i,1), exactBorder(i,2)-1) = 1;
    end;
    
    if (exactBorder(i,2)+1) <= c2                                % Add right
        newWindow(exactBorder(i,1), exactBorder(i,2)+1) = 1;
    end;
end;
% if size(newWindow) == size(boolWindow)
    outerBorderWindow = newWindow - boolWindow;
    outerBorderPixels = window(find(outerBorderWindow==1));         % Actual values from 'window'
% else
%     outerBorderPixels = [1 2];                                      % Return different values
% end;