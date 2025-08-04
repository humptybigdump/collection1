function squared_mean_error = analyze_residual_error(est_poses, true_poses)
numPoses = size(true_poses, 1);

pose_diff = est_poses - true_poses(:,1);

figure('Name', 'Position Error Visualization');
plot(1:numPoses, zeros(numPoses), 'r-'); hold on;
plot(1:numPoses, pose_diff, 'bx');
xlabel('time step')
ylabel('error')

squared_mean_error = sum(pose_diff.^2) ./ numPoses;
end
