%% Tracking for highway sequence
clc
clear all
close all

%%%%% LOAD THE IMAGES
%=======================

% Give image directory and extension
imPath = 'highway/input'; imExt = 'jpg';

% check if directory and files exist
if isdir(imPath) == 0
    error('USER ERROR : The image directory does not exist');
end
%%
filearray = dir([imPath filesep '*.' imExt]); % get all files in the directory
NumImages = size(filearray,1); % get the number of images
if NumImages < 0
    error('No image in the directory');
end
%%
disp('Loading image files from the video sequence, please be patient...');
% Get image parameters
imgname = [imPath filesep filearray(1).name]; % get image name
I = imread(imgname); % read the 1st image and pick its size
VIDEO_WIDTH = size(I,2);
VIDEO_HEIGHT = size(I,1);

color_seq = zeros(VIDEO_HEIGHT, VIDEO_WIDTH, 3, NumImages);
ImSeq = zeros(VIDEO_HEIGHT, VIDEO_WIDTH, NumImages);
for i=1:NumImages
    imgname = strcat(imPath, '/', filearray(i).name); % get image name
    I_color = imread(imgname);
    color_seq(:,:,:,i) = I_color;
    I_gray = rgb2gray(I_color);
    ImSeq(:,:,i) = I_gray; % load image
end
disp(' ... OK!');

%% Loading ground truth

%%%%% LOAD THE IMAGES
%=======================
clc;
% Give image directory and extension
imPath = 'highway/groundtruth'; imExt = 'png';

% check if directory and files exist
if isdir(imPath) == 0
    error('USER ERROR : The image directory does not exist');
end
%
filearray = dir([imPath filesep '*.' imExt]); % get all files in the directory
NumGTImages = size(filearray,1); % get the number of images
if NumGTImages < 0
    error('No image in the directory');
end
%
disp('Loading ground truth files from the video sequence, please be patient...');
% Get image parameters
imgname = strcat(imPath, '/', filearray(i).name); % get image name
I = imread(imgname); % read the 1st image and pick its size
VIDEO_WIDTH = size(I,2);
VIDEO_HEIGHT = size(I,1);

GTImSeq = zeros(VIDEO_HEIGHT, VIDEO_WIDTH, NumGTImages);
for i=1:NumGTImages
    imgname = strcat(imPath, '/', filearray(i).name); % get image name
    I_gray = imread(imgname);
    %I_gray = rgb2gray(I_color);
    GTImSeq(:,:,i) = I_gray; % load image
end
disp(' ... OK!');


%% Background subtraction
% Finding background
%=======================
train_seq = ImSeq(:,:,1:470);
test_seq = ImSeq(:,:,471:end);
% Describe here your background subtraction method
Bg_image = double(zeros(VIDEO_HEIGHT, VIDEO_WIDTH));

nbr_train_imgs = 470;
nbr_test_imgs = 1700-470;

for i=1:VIDEO_WIDTH
    for j=1:VIDEO_HEIGHT
        vect = [];
        for k=1:nbr_train_imgs
           vect = [vect, test_seq(j,i,k)];
        end
        
        Bg_image(j,i) = median(vect);
    end
end
%% BACKGROUND SUBTRACTION  
path = '/Users/mac/Documents/MSCV2/Visual Tracking/Labs/Lab1/background_subtraction/track_car/';
TP1=0; TN1=0; FP1=0; FN1=0;
se = strel('disk',5); 
for i=nbr_train_imgs:NumImages
    sub1 = ImSeq(:,:,i) - Bg_image;
    thr = sub1 > 30;
    
    thr = imclose(thr, se);
    thr = imopen(thr, se);
    
    %st = regionprops(thr, 'BoundingBox', 'Area' );
    %[maxArea, indexOfMax] = max([st.Area]);
    %col_im = uint8(color_seq(:,:,:,nbr_train_imgs+i));
    %imshowpair(thr, col_im, 'montage')
    
    [TP, TN, FP, FN] = find_quantities(255*thr, GTImSeq(:,:,i));
    TP1 = TP1 + TP;
    TN1 = TN1 + TN;
    FP1 = FP1 + FP;
    FN1 = FN1 + FN;

%     hold on
%     rectangle('Position',[st(indexOfMax).BoundingBox(1),st(indexOfMax).BoundingBox(2),st(indexOfMax).BoundingBox(3),st(indexOfMax).BoundingBox(4)], 'EdgeColor','r','LineWidth',1 )
%     hold off
    %saveas(myFigure, strcat(path, 'track_car', num2str(i), '.jpg'));
end

%% DEFINE A BOUNDING BOX AROUND THE OBTAINED REGION
% you can draw the bounding box and show it on the image
path = '/Users/mac/Documents/MSCV2/Visual Tracking/Labs/Lab1/background_subtraction/track_car/';
for i=1:NumImages
     str = strcat(path, 'track_car', num2str(i), '.jpg');
     imshow(str);
end

%% Precision and recall
precision1 = TP1/(TP1+FP1);
recall1 = TP1/(TP1+FN1);
F1 = 2 * (precision1 * recall1)/(precision1 + recall1);


