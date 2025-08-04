% function to calculate darcy fluxes
function q_l=darcy(phi,k,dim,dz)

for i=1:dim-1
      q_l(i)=-sqrt(k(i+1)*k(i))*(phi(i+1)-phi(i))/(-dz(i));
end
