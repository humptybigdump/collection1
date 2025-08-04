function [mu, sigma] = compute_particle_statistics(particles)
    num_particles = size(particles, 1);

    % compute the mean of the estimated state distribution
    mu = sum([particles(:,1) particles(:,1)] .* particles(:,2:3), 1);
    % compute the covariance matrix of the estimated state distribution
    deviations = particles(:,2:3) - repmat(mu, num_particles, 1);
    sigma = zeros(2,2);
    for i = 1:num_particles
        sigma = sigma + particles(i,1) * deviations(i,:)' * deviations(i,:);
    end
end

