function SOL=chemreac
% calculation of chemical equilibrium for an 
% adiabatic, isobaric system

% species  
sp=create_specieslist('H2 O2 H2O OH H','H O');
r(1,:)=[-2,-1,2, 0,0];   % reaction vector: 2 H2 + O2 -> 2 H2O
r(2,:)=[-1,-1,0, 2,0];   % reaction vector:   H2 + O2 -> 2 OH 
r(3,:)=[ 0, 0,-1,1,1];   % reaction vector:   H2O -> OH + H
%r(4,:)=[ -1, 0,0,0,0,2];   % reaction vector:  H2 -> H + H
%r=r';
% Alternative: 
% "automatic" reaction vector(s): The column(s) of the null space of
% the element composition vector.
r=null(sp.elenum');

n0=[5,2.5,0,0,0]';  % initial composition (mol)
T0=298;         % K
p0=1e5;         % Pa 
ne0=sp.elenum'*n0;  % number of atoms for each element in mixture
h=calc_h_cp(T0,sp.thcf); % molar enthalpy of species J/mol
H0=n0'*h;       % enthalpy (J) of mixture
p_ref=1.013e5;  % Pa
R_gas=8.3145;   % universal gas constant J/(mol*K)
psi0=[T0;n0];   % initial state vector 
npsi=size(psi0,1);
psi0=psichi(.5*ones(size(r,2),1));

if 0 % block for plotting (no solution)
% one reaction only 
cchi=linspace(0,2.5,51);

% two or three reactions
[c1,c2,c3]=ndgrid(linspace(5.33,5.36,61),linspace(1.94,1.96,61),linspace(1.22,1.25,61));
SS=zeros(size(c1));ppsi=zeros(length(c1(:)),1+sp.nspe);
for i=1:length(c1(:))
	chi=[c1(i);c2(i);c3(i)];
	ppsi(i,:)=psichi(chi)';
	SS(i)=Spsi(ppsi(i,:)');	
end
%mesh(c1,c2,SS);
SOL={c1,c2,ppsi,SS};
fd=fopen('S_chi1chi2chi3.dat','wt');
fprintf(fd,'VARIABLES=c1,c2,c3,S/(J/K),T/K');
fprintf(fd,',%s',sp.names{:});fprintf(fd,'\n');
fprintf(fd,'ZONE I=%d,J=%d,K=%d\n',size(c1));
fprintf(fd,'%f %f %f %f %f %f %f\n',[c1(:) c2(:) c3(:) SS(:) ppsi]');
fclose(fd);
return
% end two reactions

% this is for plotting.  
make_plot=0;
if make_plot
	SS=cchi;ppsi=zeros(1+sp.nspe,length(cchi)); % sp.nspe: number of species
	for i=1:length(cchi)
		ppsi(:,i)=psichi(cchi(i));
		SS(i)=Spsi(ppsi(:,i))/300;
		ppsi(1,i)=ppsi(1,i)/1000;
	end
	plot(cchi,ppsi,cchi,SS);
	xlabel('\chi');ylabel('T,S,n');
	drawnow
end

end  % if 0


dSdpsi=@(psi) jacobianest(@Spsi,psi)
dGdpsi=@(psi) jacobianest(@Gpsi,psi)
l0=[0,0,0]; % vector of Lagrangian multipliers (arbitrary initial value) 
chi0=[0.2;0.2;0.2];   % initial reaction progress vector  
psi0=psichi(chi0)
psil0=[psi0;l0'];

% solution by solving equations from method of Lagrangian multipliers
% (conservation of energy and element masses appear as explicit constraint equations)
 SOL=newton(@lagr_res,[],psil0)

% solution by directly optimizing entropy as a function of the progress variables 
% (conservation of energy and element masses are fulfilled automatically and do not
% appear as explicit equations).
%opts=optimset('Display','iter','tolfun',1e-6,'tolx',1e-4);
%q=@(x) -Schi(x); % minimize negative entropy -S 
%[SOL,S]=fminunc(q,chi0,opts);
%[S,psi]=Schi(SOL);
%x=psi(2:end);x=x/sum(x);
%T=psi(1);
%[T,x(:)']

% solution by solving ode: dchi/dt = dS/d(chi)
dSdchi=@(t,chi) jacobianest(@Schi,chi)';
dSdchi(0,[0,0,0]');
[t,y]=ode15s(dSdchi,[0,1e0],[5,1,1]');

% if desired, indicate equilibrium state in plot
%make_plot=1;
%if make_plot 
%	chisol = SOL(end,4)/r(3)
%	yl=get(gca,'ylim');
%	hold on
%	plot([chisol,chisol],yl,'k:');
%	plot(chisol,SOL(end,1:4)./[1e3,1,1,1],'o');
%end


	function out=lagr_res(psil)
		% evaluate equations resulting from method of Lagrangian multipliers
		% Output OUT =  
		% dSdpsi + lambda*dGdpsi = 0      (npsi equations)
		% G(psi)                 = 0      (nl equations)
		psi=psil(1:npsi);psil=psil(:);psi=psi(:);
		l               = psil(npsi+1:end);
		out             = zeros(size(psil));
		G_psi           = dGdpsi(psi);
    hlp             = dSdpsi(psi);
		out(1:npsi)     = [hlp(:)'+(l'*G_psi)]';
		out(npsi+1:end) = Gpsi(psi);
	end

	function S = Spsi(psi)
		% psi = [T;P,n]. psi is assumed to be a column vector.
		T=psi(1);n=psi(2:end);n=n(:);
		ntot=sum(n);
		[h,cp,s]=calc_h_cp(T,sp.thcf);
		idx=find(n~=0);
		s(idx)=s(idx) - R_gas*log(n(idx)*p0/(sum(n)*p_ref));
		S = real(n'*s);
	end

	function out=Gpsi(psi)
		% psi = [T;n]. psi is assumed to be a column vector.
		T=psi(1);n=psi(2:end);
		h=calc_h_cp(T,sp.thcf);
		H=n(:)'*h; 
		ne=sp.elenum'*n(:);
		out = [H-H0;ne-ne0]; 
	end

	function Tn=psichi(chi)
		n=n0 + r*chi; 
		T=calcT(sp,H0,n,'n');
		Tn=[T;n(:)];
	end

	function [S,psi]=Schi(chi)
		% Entropy as a function of the progress variables chi
		psi=psichi(chi);
		S=Spsi(psi);
		ix=find(psi<0);
		% Trick: we do not want to find states where temperature or species are
		% negative. Therefore, in case we meet megative states, subtract a 
		% large amount from entropy to hinder algorithm from converging towards
		% these states. To be applied with care. 
		S=S-1e3*sum(psi(ix).^2); 
	end

end