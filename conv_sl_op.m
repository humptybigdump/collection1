function conv_sl_op

n_vec = [20, 40, 80, 160, 320, 640];

all_discr = zeros(6, length(n_vec));
eoc = nan(6, length(n_vec)-1);

for j=1:length(n_vec)
    all_discr(:, j) = test_sl_op(n_vec(j));
    if j > 1
        eoc(:, j-1) = log(all_discr(:, j-1) ./ all_discr(:, j)) ./ log(2);
    end
end

fprintf('Table of EOC for S phi_m\n\n')
fprintf('  n     m=0     m=1     m=2     m=3     m=4     m=5\n');
for j=1:length(n_vec)-1
    fprintf(' %3d', n_vec(j));
    fprintf('  %6.4f', eoc(:, j));
    fprintf('\n');
end


end