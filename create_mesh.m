function mesh = create_mesh(the_geometry, h)
% 
% Create a mesh on "the_geometry" where each element has at most diameter h.
%
% The geometry is a domain such that the boundary is the union of a finite number of straight lines.
% Hence the parametrization of each element is an affine map and the normal is constant along each
% element. A detailed description of the "the_geometry" argument is given in the function
% create_geometry().
%
% The mesh is a structure with the following fields:
%
%    mesh.num_nodes   number of nodes in the mesh
%
%        mesh.nodes   array of dimension num_nodes x 2 with the X and Y coordinates of the nodes
%
% mesh.num_elements   number of elements in the mesh
%
%     mesh.elements   array of dimension num_elements x 2. The first column contains the indeces of 
%                     the nodes corresponding to 0 in the reference element, the second column
%                     contains the indeces of the nodes corresponding to 1 in the reference element.
%
%      mesh.normals   array of dimension num_elements x 2. The columns are the first and second
%                     coordinates of the outward drawn unit normal for that element.
%
%            mesh.J   vector of length num_elements. Each entry is the length of the derivative of
%                     the parametrization of the corresponding element.
%

% compute the number of elements per line segment
elements_per_segment = cell(1, the_geometry.num_chains);
total_elements = 0;
for j = 1:the_geometry.num_chains
    the_chain = the_geometry.chains{j};
    elements_per_segment{j} = zeros(1, length(the_chain));
    for k = 1:length(the_chain)-1
        length_segment = norm(the_geometry.corner_points(the_chain(k+1), :) - the_geometry.corner_points(the_chain(k), :));
        elements_per_segment{j}(k) = ceil(length_segment / h);
        total_elements = total_elements + elements_per_segment{j}(k);
    end
    length_segment = norm(the_geometry.corner_points(the_chain(end), :) - the_geometry.corner_points(the_chain(1), :));
    elements_per_segment{j}(end) = ceil(length_segment / h);
    total_elements = total_elements + elements_per_segment{j}(end);
end
mesh = struct('num_elements', total_elements);

% we are only dealing with closed polygonal chains, so number of nodes is equal to number of
% elements
mesh.num_nodes = mesh.num_elements;

% initialize other fields
mesh.nodes = zeros(mesh.num_nodes, 2);
mesh.elements = zeros(mesh.num_elements, 2);
mesh.normals = zeros(mesh.num_elements, 2);
mesh.J = zeros(mesh.num_elements, 1);

% create nodes and elements on each segment
offset = 0;
for j = 1:the_geometry.num_chains
    the_chain = the_geometry.chains{j};
    start_index = offset + 1;
    for k = 1:length(the_chain)
        node_indeces = offset+(1:elements_per_segment{j}(k)+1);
        
        start_node = the_geometry.corner_points(the_chain(k), :);
        if (k < length(the_chain))
            end_node = the_geometry.corner_points(the_chain(k+1), :);
        else
            end_node = the_geometry.corner_points(the_chain(1), :);
        end
        
        t = linspace(0, 1, elements_per_segment{j}(k)+1).';
        dir_vector = end_node - start_node;
        nodes_vector = start_node + t * dir_vector;

        normal = [dir_vector(2), -dir_vector(1)] ./ norm(dir_vector);
        J = (t(2) - t(1)) * norm(dir_vector);

        if (k < length(the_chain))
            mesh.nodes(node_indeces, :) = nodes_vector;
            mesh.elements(node_indeces, :) = [node_indeces.', node_indeces.' + 1];
            mesh.normals(node_indeces, :) = ones(elements_per_segment{j}(k)+1, 1) * normal;
            mesh.J(node_indeces) = J;
        else
            shortend_indeces = node_indeces(1:end-1);
            mesh.nodes(shortend_indeces, :) = nodes_vector(1:end-1, :);
            mesh.elements(shortend_indeces, :) = [shortend_indeces.', shortend_indeces.' + 1];
            mesh.elements(shortend_indeces(end), 2) = start_index;
            mesh.normals(shortend_indeces, :) = ones(elements_per_segment{j}(k), 1) * normal;
            mesh.J(shortend_indeces) = J;
        end

        offset = offset + elements_per_segment{j}(k);
    end

end

end