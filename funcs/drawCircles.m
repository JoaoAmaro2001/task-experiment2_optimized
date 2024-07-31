function [start_x,y_position,space_between_circles,circle_radius] = drawCircles(centerX, centerY, img, window, varargin)

p = inputParser;
addOptional(p, 'surround', 0, @(x) isnumeric(x) && isscalar(x) && (x == 0 || (x >= 1 && x <= 9)));
parse(p, varargin{:});
surround = p.Results.surround;

% Calculate positions for the circles
circle_radius = 45;
circle_radius_c = circle_radius + 10;
contour_thickness = 3;
space_between_circles = 175;
total_length = 8 * space_between_circles + 2 * (circle_radius + contour_thickness);
start_x = centerX - total_length / 2 + circle_radius + contour_thickness;
y_position = centerY + size(img, 1) / 2 + 100;

if surround == 0

% Draw and number circles with contours
for i = 1:9
current_x = start_x + (i-1) * space_between_circles;
% Draw contour and circle
Screen('FillOval', window, [0 0 0], ...
    [current_x - (circle_radius + contour_thickness), y_position - (circle_radius + contour_thickness), ...
    current_x + (circle_radius + contour_thickness), y_position + (circle_radius + contour_thickness)]);
Screen('FillOval', window, [255 255 255], ...
    [current_x - circle_radius, y_position - circle_radius, ...
    current_x + circle_radius, y_position + circle_radius]);
% Draw the number centered in the circle
number_str = num2str(i);
text_bounds = Screen('TextBounds', window, number_str);
text_width = text_bounds(3) - text_bounds(1);
text_height = text_bounds(4) - text_bounds(2);
text_x = current_x - text_width / 2;
text_y = y_position - text_height / 2000;
DrawFormattedText(window, number_str, text_x, text_y, [0 0 0]);


end

else
    % Draw and number circles with contours
    for i = 1:9
    current_x = start_x + (i-1) * space_between_circles;
    % Draw contour and circle
    Screen('FillOval', window, [0 0 0], ...
        [current_x - (circle_radius + contour_thickness), y_position - (circle_radius + contour_thickness), ...
        current_x + (circle_radius + contour_thickness), y_position + (circle_radius + contour_thickness)]);
    % Draw the circle
    Screen('FillOval', window, [255 255 255], ...
        [current_x - circle_radius, y_position - circle_radius, ...
        current_x + circle_radius, y_position + circle_radius]);
    % Draw the number centered in the circle
    number_str = num2str(i);
    text_bounds = Screen('TextBounds', window, number_str);
    text_width = text_bounds(3) - text_bounds(1);
    text_height = text_bounds(4) - text_bounds(2);
    text_x = current_x - text_width / 2;
    text_y = y_position - text_height / 2000;
    DrawFormattedText(window, number_str, text_x, text_y, [0 0 0]);

    % Draw the green circle around the specified number
    if i == surround
        Screen('FrameOval', window, [0 255 0], ...
            [current_x - (circle_radius_c + contour_thickness), y_position - (circle_radius_c + contour_thickness), ...
            current_x + (circle_radius_c + contour_thickness), y_position + (circle_radius_c + contour_thickness)], 5);
    end
    end
end