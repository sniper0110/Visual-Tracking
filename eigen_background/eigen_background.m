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

se = strel('disk',5); 
%% Eigen background
X = [];

for i=1:NumImages
    temp = reshape(ImSeq(:,:,i), [VIDEO_WIDTH*VIDEO_HEIGHT, 1]);
    X = [X, temp];  
end

m = mean(X, 2);

X_norm = X - repmat(m, [1, NumImages]);
[U,~,~] = svd(X_norm, 0);

%%
k = 25;
Uk = U(:,1:k);
T_eig = 17;

for i=1:NumImages
    im = X(:,i);
    w = (im - m)' * Uk;
    y_hat = Uk * w' + m;
    thresh_im = ((im - y_hat) > T_eig);
    bin_ima = reshape(thresh_im, [VIDEO_HEIGHT, VIDEO_WIDTH]);
    imshow(bin_ima)
end

