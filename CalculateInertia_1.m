function [m,rs0,Js] = CalculateInertia(rho,mesh)

% Calculate vectors between triangle points 1 and 2 and 1 and 3
d12 = [mesh.Points(mesh.ConnectivityList(:,1),1)-mesh.Points(mesh.ConnectivityList(:,2),1) ...
       mesh.Points(mesh.ConnectivityList(:,1),2)-mesh.Points(mesh.ConnectivityList(:,2),2) ...
       mesh.Points(mesh.ConnectivityList(:,1),3)-mesh.Points(mesh.ConnectivityList(:,2),3)];
d13 = [mesh.Points(mesh.ConnectivityList(:,1),1)-mesh.Points(mesh.ConnectivityList(:,3),1) ...
       mesh.Points(mesh.ConnectivityList(:,1),2)-mesh.Points(mesh.ConnectivityList(:,3),2) ...
       mesh.Points(mesh.ConnectivityList(:,1),3)-mesh.Points(mesh.ConnectivityList(:,3),3)];

% Get the triangle normal vector from the cross product
n = cross(d12,d13,2);

% Calculate the object surface area
triangleArea        = 0.5*sqrt(n(:,1).^2+n(:,2).^2+n(:,3).^2);
inertia.SurfaceArea = sum(triangleArea);

% Calculate the center coordinates of all triangles
xM    = 1/3*(mesh.Points(mesh.ConnectivityList(:,1),1)+ ...
             mesh.Points(mesh.ConnectivityList(:,2),1)+ ...
             mesh.Points(mesh.ConnectivityList(:,3),1));
yM    = 1/3*(mesh.Points(mesh.ConnectivityList(:,1),2)+ ...
             mesh.Points(mesh.ConnectivityList(:,2),2)+ ...
             mesh.Points(mesh.ConnectivityList(:,3),2));
zM    = 1/3*(mesh.Points(mesh.ConnectivityList(:,1),3)+ ...
             mesh.Points(mesh.ConnectivityList(:,2),3)+ ...
             mesh.Points(mesh.ConnectivityList(:,3),3));

% Normalize the normal vector for all triangles
abs_n = sqrt(n(:,1).^2+n(:,2).^2+n(:,3).^2);
nx = n(:,1)./abs_n;
ny = n(:,2)./abs_n;
nz = n(:,3)./abs_n;

% Calculate the volume and mass according to the divergence theorem 
Volume = abs(sum(1/3*triangleArea.*(xM.*nx+yM.*ny+zM.*nz)));
m      = rho*Volume;

% Calculate the center of mass according to the divergence theorem
rs0        = zeros(3,1);
rs0(1)     = 1/Volume*sum(0.5*triangleArea.*xM.^2.*nx);
rs0(2)     = 1/Volume*sum(0.5*triangleArea.*yM.^2.*ny);
rs0(3)     = 1/Volume*sum(0.5*triangleArea.*zM.^2.*nz);

% Calculate inertia matrix components
Js = zeros(3,3);
ix2 = rho*sum(1/3*triangleArea.*(xM-rs0(1)).^3.*nx);
iy2 = rho*sum(1/3*triangleArea.*(yM-rs0(2)).^3.*ny);
iz2 = rho*sum(1/3*triangleArea.*(zM-rs0(3)).^3.*nz);
ixy = rho*sum(1/2*triangleArea.*(xM-rs0(1)).*(yM-rs0(2)).^2 .*ny);
ixz = rho*sum(1/2*triangleArea.*(xM-rs0(1)).*(zM-rs0(3)).^2 .*nz);
iyz = rho*sum(1/2*triangleArea.*(yM-rs0(2)).*(zM-rs0(3)).^2 .*nz);
Js(1,1) = iy2+iz2;
Js(2,2) = ix2+iz2;
Js(3,3) = ix2+iy2;
Js(1,2) = ixy;
Js(2,1) = ixy;
Js(1,3) = ixz;
Js(3,1) = ixz;
Js(2,3) = iyz;
Js(3,2) = iyz;
end