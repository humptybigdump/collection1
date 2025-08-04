classdef body
    properties
        name  = "void_body";
        m     = 1;
        rs0   = [0;0;0];
        J     = eye(3,3);
        rho   = 0;
        mesh  = struct();
        color = [0.6 0.6 0.6]; 
        patch 
    end
    methods
        function bodyobj = loadMesh(bodyobj,path)
            bodyobj.mesh = stlread(path);
        end
        function bodyobj=plotBody(bodyobj)
            bodyobj.patch = trimesh(bodyobj.mesh,'Facecolor',bodyobj.color,'Edgecolor','none','FaceLighting',  'gouraud');
        end
%         function bodyobj = updatePlotBody(bodyobj,resultobj,frame)
%             bodyobj.patch.Vertices = bodyobj.mesh.Points + resultobj.y(frame,1:3);
%         end
        function bodyobj = updatePlotBody(bodyobj,resultobj,frame)
            bodyobj.patch.Vertices = bodyobj.rs0.'.*ones(size(bodyobj.mesh.Points)) + resultobj.y(frame,1:3) + ...
                QuadRotation(bodyobj.mesh.Points-bodyobj.rs0.'.*ones(size(bodyobj.mesh.Points)),resultobj.y(frame,4:7));
        end
        function bodyobj = body_init(bodyobj)
            [bodyobj.m,bodyobj.rs0,bodyobj.J] = CalculateInertia(bodyobj.rho,bodyobj.mesh); 
        end
    end
end