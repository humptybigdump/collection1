%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         NM Uebung2          %
%  Xingyu Wu,    2338934      %
%  Xiang Chen,   1985804      %
%  Wentao Lu     2272180      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
[H,a,URL] = load_data('math_kitdat.sec');
H = H';
v0=zeros(9843,1);
v0(1,1)=1;
[p] = power_method(H,a,0.8,v0,10e-6);
[Importence,Position] = sort(p,'descend');
Importence = num2cell(Importence(1:10));
Position = Position(1:10);
descend_URL = URL(Position(),:);
most_relvant_URL = [descend_URL Importence];
most_relvant_URL