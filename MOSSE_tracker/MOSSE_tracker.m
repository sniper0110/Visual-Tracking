%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                            %
%   This script is an implementation of the MOSSE tracker    %
%                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear all
close all

%% read images
imPath = 'car'; imExt = 'jpg';

% LOAD IMAGES
%=======================
% check if directory and files exist
if isdir(imPath) == 0
    error('USER ERROR : The image directory does not exist');
end

filearray = dir([imPath filesep '*.' imExt]); % get all files in the directory
NumImages = size(filearray,1); % get the number of images
if NumImages < 0
    error('No image in the directory');
end

disp('Loading image files ...');

% Get image parameters
imgname = [imPath filesep filearray(1).name]; % get image name
I = imread(imgname);
VIDEO_WIDTH = size(I,2);
VIDEO_HEIGHT = size(I,1);
ImSeq = zeros(VIDEO_HEIGHT, VIDEO_WIDTH, NumImages);

% Reading all images 
for i=1:NumImages
    imgname = [imPath filesep filearray(i).name]; % get image name
    my_im = imread(imgname);
    ImSeq(:,:,i) = my_im;   
end

disp('Done loading images!');

%% Getting patches from learning frames

train_size = round(NumImages/5); % one fifth of the sequence for training
W = 100; % patch width
H = 50; % patch height

trainPatchSeq = zeros(H, W, train_size);

sprintf('We will crop %d frames! \n', train_size);

for i=1:train_size
    clc; i
    
    imgname = [imPath filesep filearray(i).name]; % get image name
    frame = imread(imgname);
    
    % Cropping patches
    figure(1)
    imshow(imgname);
    [cdX, cdY] = ginput(1);
    rectangle('Position', [cdX-W/2, cdY-H/2, W-1, H-1], 'EdgeColor', 'g');
    patch_cropped = double(imcrop(frame, [cdX-W/2, cdY-H/2, W-1, H-1]));
    trainPatchSeq(:,:,i) = patch_cropped; % load patch
end
disp(' ... OK!');

%% Preprocessing
load('car_data/trainSeq.mat'); % sequence without pre-processing

% 1/ Apply log(u + 1)
% 2/ Normalize so that : mean=0 and norm=1
% 3/ Apply cosine window (vertically and horizontally)

W = 100; % patch width
H = 50; % patch height
ver_cos = repmat(hann(H), 1, W); % {{{
hor_cos = repmat(hann(W)', H, 1); % ~

for i=1:size(trainPatchSeq, 3)
    m_patch = trainPatchSeq(:,:,i);
    m_patch = log(m_patch + 1);
    m_patch = m_patch - mean2(m_patch); % mean=0
    m_patch = m_patch / sum(m_patch(:)); % norm=1
    m_patch = m_patch .* ver_cos; % vertical cosine window
    m_patch = m_patch .* hor_cos; % horizontal cosine window
    trainPatchSeq(:,:,i) = m_patch; % updating train patches sequence
end

% Saving patches after being pre-processed
save('car_data/trainSeqPreProc.mat', 'trainPatchSeq');

%% Saving data to file

%save('car_data/cdXY.mat', 'cdX', 'cdY');
%save('car_data/trainSeq.mat', 'trainPatchSeq');

%% Finding MOSSE filter
train_size = round(NumImages/5); % 10
% Computing FFTs of patches
FFT_patches = zeros(H, W, train_size);
for i=1:train_size
    FFT_patches(:,:,i) = fft2(trainPatchSeq(:,:,i));    
end

% Initialization (t = 1)
filter = FFT_patches(:,:,1); % our filter 
Y = zeros(size(FFT_patches));
Y(:,:,1) = FFT_patches(:,:,1) .* filter;
Hn = filter;
Hd = filter;
gamma = 0.125; % learning rate
lambda = 1; % regularization parameter

% learning (t >= 2)
for t=2:train_size
    Y(:,:,t) = FFT_patches(:,:,t) .* filter;
    Hn = (1-gamma) * Hn + gamma * (conj(Y(:,:,t)) .*  FFT_patches(:,:,t));
    Hd = (1-gamma) * Hd + gamma * (conj(FFT_patches(:,:,t)) .* FFT_patches(:,:,t));
    filter = Hn ./ (Hd+lambda);
end

filter = ifft2(filter); % Our final filter 
imshow(uint8(filter));
%save('car_data/filter.mat', 'filter');

%% Applying MOSSE filter for tracking
% Loading data
load('car_data/trainSeq.mat');
load('car_data/filter.mat');
load('car_data/cdXY.mat');

% Tracking
Window_W = 150;
Window_H = 70;
cX = cdX;
cY = cdY;
[p_H, p_W] = size(filter);
v = zeros(1, 2);
v_w = zeros(1, 2);


for i=11:NumImages
    % vector from top left of frame to top left of window
    v(2) = cX-Window_W/2; % columns
    v(1) = cY-Window_H/2; % rows
    
    window = double(imcrop(ImSeq(:,:,i), [v(2), v(1), Window_W-1, Window_H-1]));
    my_conv = conv2(window, filter, 'same');
    
    % Getting vector inside the window
    [v_w(1), v_w(2)] = find(my_conv == max(my_conv(:))); % [row, col]

    %my_patch = double(imcrop(window, [indJ-p_W/2, indI-p_H/2, p_W-1, p_H-1]));
    
    % Tracking Display
    myFigure = figure(1);
    imshow(ImSeq(:,:,i), [])
    rectangle('Position',[cX-p_W/2, cY-p_H/2, p_W-1, p_H-1], 'EdgeColor','r','LineWidth',1 )
    drawnow
    
    % Updating vectors
    cX = v(2) + v_w(2); % columns
    cY = v(1) + v_w(1); % rows
    
end    





