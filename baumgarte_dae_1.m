function dy = baumgarte_dae(t,y,simobj,modelobj)
global transfer

clc
disp("Solving... "+round(t/simobj.tspan(end)*100)+"%")
f = zeros(7*length(modelobj.bodyobj)+6*length(modelobj.bodyobj),1);
dy = zeros(size(y));

% Normalize q
for i1=1:length(modelobj.bodyobj)
 y(((i1-1)*7+4):((i1-1)*7+7)) = y(((i1-1)*7+4):((i1-1)*7+7))/norm(y(((i1-1)*7+4):((i1-1)*7+7)));
end

nKINEM = 7*length(modelobj.bodyobj);
nKINET = 6*length(modelobj.bodyobj);

for i1=1:length(modelobj.bodyobj)
    % Kinematics
    v       = y((nKINEM+(i1-1)*6+1):(nKINEM+(i1-1)*6+3));
    omega_k = y((nKINEM+(i1-1)*6+4):(nKINEM+(i1-1)*6+6));
    Omega_k   = [ 0        -omega_k(3)  omega_k(2);
        omega_k(3)  0        -omega_k(1);
        -omega_k(2)  omega_k(1)  0      ];
    f((i1-1)*7+1:i1*7)  = [v;
        0.5*[0         -omega_k.';
        omega_k   -Omega_k]*y(((i1-1)*7+4):((i1-1)*7+7))];
    % Kinematic Constraint
    % f(i1*7) = y((i1-1)*7+4)^2+y((i1-1)*7+5)^2+y((i1-1)*7+6)^2+y((i1-1)*7+7)^2-1;

    % Kinetics
    f((nKINEM+6*(i1-1)+1):(nKINEM+6*(i1-1)+6)) = [zeros(3,1);
        -Omega_k*modelobj.bodyobj(i1).J*omega_k];
end
FA = f((nKINEM+1):(nKINEM+nKINET)) + modelobj.calculateForceAndTorque(t,y);

% Calculate Constraints
if modelobj.jointobj(1).type == "none"
    FZ = zeros(size(FA));
else
    g = simulation.calculateg(modelobj,t,y);
    G = simulation.calculategGradient(g,y(1:7*length(modelobj.bodyobj)),modelobj,t,y);
    H     = simulation.calculateH(modelobj,t,y);
    FZ = (G*H).'*y((nKINEM+nKINET+1):(nKINEM+nKINET+length(g)));
end

f((nKINEM+1):(nKINEM+nKINET)) = FA + FZ;
dy(1:(nKINEM+nKINET)) = modelobj.MMatrix\f;

if modelobj.jointobj(1).type ~= "none"
    % Calculate Constraint Derivatives
    gDot  = simulation.calculategDot(modelobj,t,y);
    gDdot = simulation.calculategDdot(modelobj,t,y,dy);

    % Baumgarte Equation
    BG = gDdot + simobj.beta*gDot + simobj.beta^2*g;
    dy((nKINEM+nKINET+1):(nKINEM+nKINET+length(g))) = BG;
end

% transfer.t     = t;
% transfer.dy    = dy;
% transfer.FA    = FA;
% if modelobj.jointobj(1).type ~= "none"
%     transfer.g     = g;
%     transfer.G     = G(:);
%     transfer.gDot  = gDot;
%     transfer.gDdot = gDdot;
%     transfer.FZ    = FZ;
%     transfer.BG    = BG;
% end
end