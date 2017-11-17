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

NumGTImages = size(filearray,1); % get the number of images
if NumGTImages < 0
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

GTImSeq = ImSeq;

train_seq = ImSeq(:,:,1:470);
test_seq = ImSeq(:,:,471:end);
% Describe here your background subtraction method
Bg_image = double(zeros(VIDEO_HEIGHT, VIDEO_WIDTH));

nbr_train_imgs = 470;
nbr_test_imgs = 1700-470;

%% Gaussian model
VIDEO_WIDTH = 240;
VIDEO_HEIGHT = 320;

T = 2.5;
alpha = 0.01;
mean_matrix = ImSeq(:,:,1);
std_matrix = 10 * ones(size(ImSeq(:,:,1)));

mean_to_use = [];
std_to_use = [];

avg_gauss_seq_bin = zeros(size(ImSeq));

TP2=0; TN2=0; FP2=0; FN2=0;

for i=1:nbr_train_imgs
    frame = ImSeq(:,:,i);
    if(i==1)
       avg_gauss_seq_bin(:,:,i) = (double(frame) - mean_matrix) > T*std_matrix; 
       old_mean = mean_matrix;
       old_std = std_matrix;
    else
       [new_mean, new_std] = update_params(frame, alpha, old_mean, old_std);
       avg_gauss_seq_bin(:,:,i) = (double(frame) - new_mean) > T*new_std;
       
       old_mean = new_mean;
       old_std = new_std;
       mean_to_use = new_mean;
       std_to_use = new_std;
    end
    
end
%%
for i=nbr_train_imgs:NumImages
    frame = ImSeq(:,:,i);
    avg_gauss_seq_bin(:,:,i) = (double(frame) - mean_to_use) > T*std_to_use;
    
    [TP, TN, FP, FN] = find_quantities(255*avg_gauss_seq_bin(:,:,i), GTImSeq(:,:,i));
    TP2 = TP2 + TP;
    TN2 = TN2 + TN;
    FP2 = FP2 + FP;
    FN2 = FN2 + FN;
    
end   
disp('Done binarizing images using the gaussian model');
   
%% 

for i=1:NumImages
    imshowpair(avg_gauss_seq_bin(:,:,i), uint8(color_seq(:,:,:,i)), 'montage');
end

%% Precision and recall
precision2 = TP2/(TP2+FP2);
recall2 = TP2/(TP2+FN2);
F2 = 2 * (precision2 * recall2)/(precision2 + recall2);

