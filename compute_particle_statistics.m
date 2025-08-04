function [mu, sigma] = compute_particle_statistics(particles)
    num_particles = size(particles, 1);
    mu = sum([particles(:,1) particles(:,1)] .* particles(:,2:3), 1);
    deviations = particles(:,2:3) - repmat(mu, num_particles, 1);
    sigma = zeros(2,2);
    for i = 1:num_particles
        sigma = sigma + particles(i,1) * deviations(i,:)' * deviations(i,:);
    end
end

