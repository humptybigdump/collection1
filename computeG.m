function G = computeG(q)
    % Compute the matrix G = dg/dq.
    % Inside of the function, we compute GT = G^T and transpose in the end.

    q = reshape(q,2,[]);
    numballs = size(q,2);
    dq = q - [[0;0], q(:,1:numballs-1)];
    GT = zeros(2*numballs, numballs);
    for j = 1:numballs-1
        GT(2*(j-1)+(1:2),j) = dq(:,j);
        GT(2*(j-1)+(1:2),j+1) = -dq(:,j+1);
    end
    GT(2*numballs+(-1:0),numballs) = dq(:,numballs);
    G = GT';
    
end