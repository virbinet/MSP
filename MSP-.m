% -------------------------------------------------------------------------
% "MicroScan Particle " (MSP)
% Created by Virginia Binet
% -------------------------------------------------------------------------

% Load image
% A = imread('m44i-4.bmp');

B = imread('particle_image.png');

% Binarization
threshold = graythresh(B);
it2 = im2bw(B, threshold);

figure(2), imshow(it2), title('Binary Image')

% Define structuring elements (pixel neighborhood)
square = strel('square',1);        
disk = strel('disk',1);

% Apply morphological operations
image_erode_square = imerode(it2, square);
image_erode_disk = imerode(it2, disk);

figure(3), imshow(image_erode_square), title('Eroded Image - Square')
figure(4), imshow(image_erode_disk), title('Eroded Image - Disk')

disk2 = strel('disk',3);
C = imclose(image_erode_disk, disk2);
figure(5), imshow(C), title('Disk erosion + closing')

% Morphological reconstruction
Ir = imreconstruct(C, it2);

figure(6)
subplot(121), imshow(it2), title('Binary'), axis on
subplot(122), imshow(image_erode_disk), title('Eroded'), axis on

figure(7), imshow(Ir), title('Reconstructed Image'), axis on

% Fill holes
F = imfill(Ir, 'holes');
figure(8), imshow(F), title('Hole-filled Image')

% Remove border-touching particles
J = imclearborder(F);
figure(9), imshow(J), title('Border-cleaned Image')

% Compare final vs original image
figure(10), imshowpair(J, B), ...
    title('Final (Green) vs Original (Magenta)')

% Label connected components
E = bwlabel(J);
figure(11), vislabels(E), title('Labeled Particles')

% Compute properties
stats = regionprops(E, 'Area', 'Perimeter', 'Centroid', 'BoundingBox');

% Draw particle boundaries
BW2 = bwperim(E);
hold on

for k = 1:length(stats)
    bbox = stats(k).BoundingBox;  
    
    % Color by size
    if stats(k).Area > 476
        rectangle('Position', bbox, 'EdgeColor','r','LineWidth',2);
    else
        rectangle('Position', bbox, 'EdgeColor','b','LineWidth',2);
    end

    % Shape classification using circularity
    circularity = stats(k).Perimeter^2 / stats(k).Area;

    if circularity > 18
        text(stats(k).Centroid(1), stats(k).Centroid(2), ...
            'Triangle', 'Color','r');
    elseif circularity < 18
        text(stats(k).Centroid(1), stats(k).Centroid(2), ...
            'Circle', 'Color','g');
    else
        text(stats(k).Centroid(1), stats(k).Centroid(2), ...
            'Square', 'Color','b');
    end 
end

% --- Conversion to micrometers ---

% Microns per pixel (X and Y directions)
MPX = 0.290;
MPY = 0.297;

% Pixel area in microns²
AP = MPX * MPY;

% Particle area
Area = [stats.Area].';
ACP = Area * AP;

% Perimeter
Perimeter = [stats.Perimeter].';
mean_pixel = (MPX + MPY) / 2;
PCP = Perimeter * mean_pixel;

% Mean particle diameter (in pixels)
dia_mean = zeros(size(stats,1),1);
fprintf('Part#    Diameter [px]\n')

for n = 1:size(stats,1)
    dia_mean(n) = mean(stats(n).BoundingBox([3 4]));
    fprintf('%3d:     %.2f\n', n, dia_mean(n))
end

% Convert diameter to micrometers
DCP = dia_mean * mean_pixel;

% Final table
Table = table(ACP, PCP, DCP);