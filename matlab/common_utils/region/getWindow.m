function [window] = getWindow(regionMap, regid, border, height, width)

[xx yy] = find(regionMap == regid);   % Get the region's pixels

% Compute region (boundaries)
top_left_row = min(xx);
top_left_col = min(yy);
bottom_right_row = max(xx);
bottom_right_col = max(yy);

% Window encapsulating the region with a border
start_left_row = max(top_left_row - border,1);               % Avoids illegal indices
start_left_col = max(top_left_col - border,1);               % Avoids illegal indices
end_right_row = min(bottom_right_row + border,height);       % Avoids illegal indices
end_right_col = min(bottom_right_col + border,width);        % Avoids illegal indices

% Get all region masks in the window
window = uint16(regionMap(start_left_row:end_right_row,start_left_col:end_right_col));
