  % Programm zur Lösung der Kriging-Gleichungen

%Laden der Messdaten:
rmax=100; %maximaler Suchradius für Kriginggleichungen
Ergebnis='Interpolation_ks_gauss_400.dat';
data=load('measurement_tb.dat');
n=length(data(:,1));  % Anzahl der Beobachtungen
x=data(:,1);
y=data(:,2);
z=data(:,3);

% Laden der von vario_2.m berechneten Variogramm-Daten:
vario=load('variogramm_data.dat');
nugg=vario(1,1);
sill=vario(1,2);
range=vario(1,3);
typ=vario(1,4);

% Raster für die Interpolation
feld=load('feld.dat');
%x0=feld(551:560,1);
%y0=feld(551:560,2);
x0=feld(:,1);
y0=feld(:,2);

m=length(x0);

for a=1:m
    
   % Berechnung der Abstände h(i) zwischen gemessenen Punkten und dem Schätzpunkt:
   nah=[];
   bla=zeros(n,1);
   h=zeros(n,1);
   for i=1:n
     h0(i)=sqrt((x(i)-x0(a))^2+(y(i)-y0(a))^2);
     b=h0(i);

     % Auswahl der ausreichend nahen Punkte:
     if b < rmax      % Suchradius
       nah=[nah,i];
     end
   end
   p=length(nah);
   ip=find(h0 <= rmax);
     
   % Berechnung der Abstände h(i,j) zwischen allen ausreichend nahen Punkten:
   h=zeros(p,p);
   % for =2:length(ip)
   for i=2:p
     for j=1:i-1
       h(i,j)=sqrt((x(nah(i))-x(nah(j)))^2+(y(nah(i))-y(nah(j)))^2);
       h(j,i)=h(i,j);
     end
   end
   
   
   % Berechnung der Koeffizientenmatrix A und des Vektors b der rechten Seite 
   
   A=zeros(p+1,p+1);  % (p+1 wegen Mü und Summe(coef) = 1)
   A(p+1,1)=1;
   A(1,p+1)=1;
   b=zeros(p+1,1);    % Vektor auf rechter Seite im Kriging-System
   b(p+1)=1;   
   
   for i=2:p
      A(p+1,i)=1;
      A(i,p+1)=1;
      
      if typ==1   
        for j=1:i-1
          A(i,j)=  -[nugg + sill*( 1 - exp(-h(i,j)/range))];
          A(j,i)=A(i,j);
        end
        for i=1:p
          b(i)= -[nugg + sill*( 1 - exp(-h0(i)/range))];% rechte seite
        end
      
      elseif typ==2
        for j=1:i-1
          A(i,j)= -[nugg + sill * ( 1 - exp(-h(i,j)^2 / range^2))];
          A(j,i)=A(i,j);
        end
        for i=1:p
          b(i)= -[nugg + sill * ( 1 - exp(-(h0(nah(i))^2 / range^2)))];  ;
        end
    
      elseif typ==3
        for j=1:i-1
          A(i,j)= -[nugg + sill * (3.5 * h(i,j)/range - 0.5* (h(i,j)/range)^3)];
          A(j,i)=A(i,j);
        end
        for i=1:p
          b(i)= -[nugg + sill * (3.5 * h0(i)/range - 0.5* (h0(i)/range)^3)]; 
        end
                   
      end     
      
   end
      
   % Lösung des Kriging-Systems:
   coef=A\b; 
   
   lam=zeros(1,n);
   for i=1:p        % darf nur bis p gehen, um coef(p+1) rauszuschmeißen
     lam(nah(i))=coef(i);
   end
    
   z0(a) = lam * z;  
   
   s(a)=sum(lam);   % nur zur Überprüfung
   
end


fido=fopen(Ergebnis,'w');
aim=[x0,y0,z0']';
fprintf(fido,'%6.0f %6.0f %8.2f\n',aim);
fclose(fido);

% visual comparison of interpolation and virtual realty 
evaluate_simul;
