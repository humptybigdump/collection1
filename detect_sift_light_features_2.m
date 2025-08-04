function [ features ] = detect_sift_light_features(I)
% DETECT_SIFT_LIGHT_FEATURES Detects SIFT (light) features in the image.
% function [ features ] = detect_sift_light_features(I)
%
%      with I: the input image (a graylevel image)
%    features: the interest points found in the image as N-by-5 matrix.
%              Each row represents one interest point as tuple with entries
%              [u v scale(as integer) L-value sigma(as double)]

Idouble = double(I);
[height, width] = size(Idouble);

% discretization of scale space (sigma in lecture slides)
num_scales = 15;
scales = power(2, (0:num_scales) ./ 3);  % create sequence of sigma values

% discretization of image and scale space L(sigma, v, u).
% Initialize L with 0
L = zeros(height, width, num_scales);

for i = 1:num_scales
    scale = scales(i);
    % convolution with LoG using the scale
    % store the result in the tensor
    LoG = fspecial('log', 2*round(scale*[5 5])+1, scale);
    L(:,:,i) = scale^2*imfilter(Idouble, LoG);
end

% compute the local maxima in a 3-by-3-by-3 environment
% it returns the indices of the maxima for each dimension
features_all = local_maxima (L);
features_all (:,5) = scales (features_all(:,3))';

% remove interest points located at the boundary of the image or on the smallest
% or largest scale
features_strip_boundaries = strip_boundaries ([1,1,1], [height,width,num_scales], features_all);

% remove interest points with small maxima close to zero
features_without_noise = threshold_features (10, features_strip_boundaries(:,4), features_strip_boundaries);

% remove interest points next to edges
features_without_edges = eliminate_edge_features (5, L, features_without_noise);

% return all remaining interest points
features = features_without_edges;
end


function [ features ] = local_maxima (L)
% function features = local_maximum (L)
%
% This function returns the indexes\subscripts of local maximum in the scale space function L.
% L is a tensor of dimension 3
% feature is a n-by-4 matrix that contains the coordinates of one feature
% per row and the L-value

se = ones ([3 3 3]);
L1 = imdilate (L,se);
f = find(L == L1);
n_maxima = length(f);
features = zeros (n_maxima, 4);
[features(:,1), features(:,2), features(:,3)] = ind2sub (size(L), f);
features(:,4) = L(f);
end


function [ features_clean ] = strip_boundaries (minimum, maximum, features)
% function [ features_clean ] = strip_boundaries (minimum, maximum, features)
%
% This function eliminates those interest points which are located next to
% the image boundaries or on the smallest or largest scale layer. minimum
% and maximum are 3-dimensional vector that contain the minimal (resp.
% maximal) values, e.g. minimum = [1 1 1], maximum = [height, width,
% max_scale]
idx_select = (features(:,1)>minimum(1))+(features(:,2)>minimum(2))+(features(:,3)>minimum(3))+(features(:,1)<maximum(1))+(features(:,2)<maximum(2))+(features(:,3)<maximum(3));
features_clean = features(idx_select==6,:);
end


function [ features_clean ] = threshold_features ( threshold, values, features)
% function [ features_clean ] = threshold_features ( threshold, values, features)
%
% This function removes those rows from features for which the respective
% entry in values is below threshold.
idx_select = (values>=threshold);
features_clean = features(idx_select,:);
end


function [ features_clean ] = eliminate_edge_features (r, L, features)
% function [ features_clean ] = eliminate_edge_features (r, L, features)
%
% This function applies the edge pixel check on all interest points in
% features. The edge check is based on the Hessian of the scale space
% function L. r is a threshold. The larger r, the more interest points are
% accepted.
threshold = (r+1)^2 /r;  % the threshold for later testing
n = size(features,1);
crit = zeros (n,1);
for i=1:n
    % Calculate the Hessian for each interest point.
    v = features(i,1);
    u = features(i,2);
    s = features(i,3);
    
    dvv = L(v+1, u, s) - 2*L(v,u,s) + L(v-1, u, s);
    duu = L(v, u+1, s) - 2*L(v,u,s) + L(v, u-1, s);
    dvu = 1/4*(L(v+1, u+1, s) + L(v-1, u-1, s) - L(v+1, u-1, s) - L(v-1, u+1, s));
    
    crit(i) = (dvv + duu)^2 / (dvv*duu - dvu^2);
    
end
idx_select = crit<threshold;
features_clean = features (idx_select, :);
end
