function [ features ] = detect_sift_light_features(I)
% DETECT_SIFT_LIGHT_FEATURES Detects SIFT (light) features in the image.
% function [ features ] = detect_sift_light_features(I)
%
%      with I: the input image (a graylevel image)
%    features: the interest points found in the image as N-by-5 matrix.
%              Each row represents one interest point as tuple with entries
%              [u v c(as integer) L-value scale(as double)] where c serves
%               as an index

Idouble = double(I);
[height, width] = size(Idouble);

% discretization of scale space
num_scales = 16;
c = 1:num_scales;
scales = power(2, (c-1)./ 3);  % create sequence of sigma/scale values

% Initialize scale space L(u, v, sigma) with zeros. 
L = zeros(height, width, num_scales);

for i = 1:num_scales
    % ------ Your code here ------
    % ----------------------------
end

% compute the local maxima in a 3-by-3-by-3 environment
% the function return a n-by-4 matrix that contains one row per detected 
% potential feature point: [v, u, c, L(v,u,scale)]
features_all = local_maxima(L);
% add the scale: [v, u, c, L(v,u,scale), scale]
features_all(:,5) = scales(features_all(:,3))';

% remove interest points located at the boundary of the image or on the
% smallest or largest scale
features_strip_boundaries = strip_boundaries( ...
    [1,1,c(1)], [height,width,c(end)], features_all);

% remove interest points with a filter response smaller than a 
% specific threshold
thr = 10;
features_without_noise = threshold_features( ...
    thr, features_strip_boundaries(:,4), features_strip_boundaries);

% remove interest points next to edges
r = 5;
features_without_edges = eliminate_edge_features( ...
    r, L, features_without_noise);

% return all remaining interest points
features = features_without_edges;
end


function [ features ] = local_maxima(L)
% function features = local_maxima (L)
%
% Input:
%   L: 3-dimensional array representing the scale space
% Output:
%   features: n-by-4 matrix that contains one row per detected 
%             potential feature point: [v, u, c, L(v,u,scale)]
%               - v und u are the coordinates of the detected feature point
%               - c is the index of the scale level on which the maximum
%                 was detected
%               - L(v,u,scale) is the corresponding LoG filter response

se = ones([3 3 3]);
L1 = imdilate(L,se);
f = find(L == L1);
n_maxima = length(f);
features = zeros(n_maxima, 4);

% save values as [v, u, c, L(v,u,scale)]
[features(:,1), features(:,2), features(:,3)] = ind2sub(size(L), f);
features(:,4) = L(f);
end


function [ features_clean ] = strip_boundaries(minimum, maximum, features)
% function [ features_clean ] = strip_boundaries (minimum, maximum, features)
%
% This function eliminates those interest points which are located next to
% the image boundaries or on the smallest or largest scale layer. Minimum
% and maximum are 3-dimensional vectors that contain the minimal (resp.
% maximal) values, e.g. minimum = [1 1 1], maximum = [height, width,
% max_scale]
idx_select = (features(:,1)>minimum(1))+...
    (features(:,2)>minimum(2))+...
    (features(:,3)>minimum(3))+...
    (features(:,1)<maximum(1))+...
    (features(:,2)<maximum(2))+...
    (features(:,3)<maximum(3));
features_clean = features(idx_select==6,:);
end


function [ features_clean ] = threshold_features(threshold, values, features)
% function [ features_clean ] = threshold_features ( threshold, values, features)
%
% This function removes those rows from features for which the respective
% entry in values is below the specified threshold.
% ------ Your code here ------
% ----------------------------
end


function [ features_clean ] = eliminate_edge_features(r, L, features)
% function [ features_clean ] = eliminate_edge_features (r, L, features)
%
% This function applies the edge pixel check on all interest points in
% features. The edge check is based on the Hessian of the scale space
% function L. r is a threshold. The larger r, the more interest points are
% accepted.

% ------ Your code here ------
% ----------------------------

end
