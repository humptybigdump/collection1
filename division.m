function [a,i,j,k] = division(a1, i1, j1, k1, a2, i2, j2, k2)
betrag2= a2^2+ i2^2+  j2^2+ k2^2;
a_inv=a2/betrag2;
i_inv=-i2/betrag2;
j_inv=-j2/betrag2;
k_inv=-k2/betrag2;

[a,i,j,k]=multiplikation(a1, i1, j1, k1,a_inv, i_inv, j_inv,k_inv);
 
end