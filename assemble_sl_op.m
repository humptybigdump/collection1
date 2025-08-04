function A = assemble_sl_op(mesh, space_type)
%
% Function to assemble the Galerkin discretization of the the single layer
% operator.
%
% This function uses the conventions and formulae from Handouts 5 & 6.

% Define quadrature rules to be used
N_quad_log = 5;
N_quad_cont = 5;

[s_log, t_log, w_log] = galerkin_quad_log(N_quad_log);
[s_cont, t_cont, w_cont] = galerkin_quad_cont(N_quad_cont);

% extract dimensions and allocate matrix
M = mesh.num_elements;
N_space = space_dim(space_type, mesh);
A = zeros(N_space, N_space);

% Do a double loop over all elements. All shape functions are treated at
% the same time!
for j = 1:M
    % local-to-global-dof map and parametrization of first element
    [loc_to_glob_j, eta_j] = element_data(mesh, space_type, j);

    for m = 1:M
        % local-to-global-dof map and parametrization of second element
        [loc_to_glob_m, eta_m] = element_data(mesh, space_type, m);

        if (j == m)
            % 1st case: the elements are identical

            % assemble contributions from integrals with smooth integrands
            % Here, H = J_m^2 / (2*pi) * sigma_{m,l}(t) * sigma_{m,l'}(tau)

            % as a shorthand, we define a = t*s and b = t - t*s
            a = t_cont .* s_cont;
            b = t_cont - a;

            % evaluate the parametrizations
            p1 = eta_j(t_cont);
            p2 = eta_j(b);
            p3 = eta_j(1 - t_cont);
            p4 = eta_j(1 - b);
      
            % compute all the terms in the integrands that are independent
            % of the shape functions
            K_lead = 1/(2*pi) * mesh.J(j)^2;
            K1 = K_lead * log(sqrt((p1(:, 1) - p2(:, 1)).^2 + (p1(:, 2) - p2(:, 2)).^2) ./ a) .* t_cont .* w_cont;
            K2 = K_lead * log(sqrt((p3(:, 1) - p4(:, 1)).^2 + (p3(:, 2) - p4(:, 2)).^2) ./ a) .* t_cont .* w_cont;
                
            % evaluate shape functions
            sigma1 = eval_shape_functions(space_type, t_cont);
            sigma2 = eval_shape_functions(space_type, b);
            sigma3 = eval_shape_functions(space_type, 1 - t_cont);
            sigma4 = eval_shape_functions(space_type, 1 - b);
                
            % finally, compute the contribution to the matrix
            A_contrib1 = -sigma1.' * ((K1 * ones(1, size(sigma2, 2))) .* sigma2) ...
                - sigma3.' * ((K2 * ones(1, size(sigma4, 2))) .* sigma4);

            % compute contribution from weakly singular kernel component
            % here we use the shorthand a = t - s*t, b = s - s*t
            a = t_log - s_log .* t_log;
            b = s_log - s_log .* t_log;

            % ---------------------------------------------------------------------
            % IMPLEMENT THE REST OF CASE 1 YOURSELF, PERFORMING THE INDICATES STEPS

            % again: first compute all the terms in the integrands that are
            % independent of the shape functions
                
            % evaluate shape functions (a total of 8 evaluations is necessary)

            % finally, compute the contribution for the integrals with
            % weakly singular integrand
            A_contrib2 =

            % ---------------------------------------------------------------------

            % add contribution to A
            A(loc_to_glob_j, loc_to_glob_j) = A(loc_to_glob_j, loc_to_glob_j) + A_contrib1 + A_contrib2;

        else
            [param_j, param_m] = elements_connected(mesh, j, m);
            if (param_j > -1)
                % 2nd case: the elements are adjacent. The returned values
                % param_j, param_m tell us which end point of which element
                % is the connecting point
                % Here, H = J_j * J_m / (2*pi) * sigma_{j,l}(t) * sigma_{m,l'}(tau)
                
                % step 1: compute contributions for smooth kernel components
                a = s_cont .* t_cont;
                b = s_cont - s_cont .* t_cont;

                K = 1/(2*pi) * mesh.J(j) * mesh.J(m) * s_cont .* w_cont;

                % Depending on which is the connecting point, the
                % we do additional substitutions in the integrals from
                % Handout 6, to have the singularity at (t, tau) = (0, 0).
                if param_j == 0.0
                    p1 = eta_j(1 - b);
                    sigma1 = eval_shape_functions(space_type, 1 - b);
                    p3 = eta_j(a);
                    sigma3 = eval_shape_functions(space_type, a);
                else
                    p1 = eta_j(b);
                    sigma1 = eval_shape_functions(space_type, b);
                    p3 = eta_j(1 - a);
                    sigma3 = eval_shape_functions(space_type, 1 - a);
                end

                if param_m == 0.0
                    p2 = eta_m(1 - a);
                    sigma2 = eval_shape_functions(space_type, 1 - a);
                    p4 = eta_m(b);
                    sigma4 = eval_shape_functions(space_type, b);
                else
                    p2 = eta_m(a);
                    sigma2 = eval_shape_functions(space_type, a);
                    p4 = eta_m(1 - b);
                    sigma4 = eval_shape_functions(space_type, 1 - b);
                end

                % Now we can evaluate the integrand
                K1 = log(1 ./ sqrt((p1(:, 1) - p2(:, 1)).^2 + (p1(:, 2) - p2(:, 2)).^2)) .* K;
                K2 = log(sqrt((p3(:, 1) - p4(:, 1)).^2 + (p3(:, 2) - p4(:, 2)).^2) ./ s_cont) .* K;
                A_contrib1 = sigma1.' * ((K1 * ones(1, size(sigma2, 2))) .* sigma2) ...
                    - sigma3.' * ((K2 * ones(1, size(sigma4, 2))) .* sigma4);
                             
                % Step 2: compute contribution from weakly singular
                % integrands
                a = s_log .* t_log;
                b = s_log - s_log .* t_log;

                % contributions independent of the shape functions
                K = 1/(2*pi) * mesh.J(j) * mesh.J(m) * s_log .* w_log;

                % shape functions, again using the correct common point
                if param_j == 0.0
                    sigma1 = eval_shape_functions(space_type, a);
                else
                    sigma1 = eval_shape_functions(space_type, 1-a);
                end

                if param_m == 0.0
                    sigma2 = eval_shape_functions(space_type, b);
                else
                    sigma2 = eval_shape_functions(space_type, 1-b);
                end
                
                % assemble all the contributions for the weakly singular
                % integrands
                A_contrib2 = sigma1.' * ((K * ones(1, size(sigma2, 2))) .* sigma2);

                % step 3: add the contribution to the matrix.
                A(loc_to_glob_j, loc_to_glob_m) = A(loc_to_glob_j, loc_to_glob_m) + A_contrib1 + A_contrib2;

            else
                % 3rd case: the elements have a positive distance from each other

                % ---------------------------------------------------------------------
                % IMPLEMENT THIS CASE YOURSELF, PERFORMING THE INDICATED STEPS
                
                % evaluate terms in integrand independent of the shape functions

                
                % evaluate shape functions

                
                % compute the contribution to the matrix


                % add contribution to A
                % ---------------------------------------------------------------------

            end
        end
    end
end

end
