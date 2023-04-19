% Before run MAIN.m, please run this script to generate some necessary
% function files.
function Derive_equations_biped_walk()

clear; close all; clc
disp('Creating variables and derivatives...')

%%%% position
x  = sym('x', 'real');
y  = sym('y', 'real');
q1 = sym('q1', 'real');
q2 = sym('q2','real');
q3 = sym('q3','real');
q4 = sym('q4','real');
q5 = sym('q5','real');

%%%% velocity
dx  = sym('dx', 'real');
dy  = sym('dy', 'real');
dq1 = sym('dq1', 'real');
dq2 = sym('dq2','real');
dq3 = sym('dq3','real');
dq4 = sym('dq4','real');
dq5 = sym('dq5','real');

%%%% acceleration
ddx  = sym('ddx', 'real');
ddy  = sym('ddy', 'real');
ddq1 = sym('ddq1','real');
ddq2 = sym('ddq2','real');
ddq3 = sym('ddq3','real');
ddq4 = sym('ddq4','real');
ddq5 = sym('ddq5','real');

%%%% Torques at each joint
u1 = sym('u1','real');   %Stance hip
u2 = sym('u2','real');   %Stance knee
u3 = sym('u3','real');   %Swing hip
u4 = sym('u4','real');   %Swing knee

%%%% stance force
fx = sym('fx','real');   %x direction
fy = sym('fy','real');   %y direction

%%%% Mass of each link
m1 = sym('m1','real');
m2 = sym('m2','real');
m3 = sym('m3','real');
m4 = sym('m4','real');
m5 = sym('m5','real');

%%%% Distance between parent joint and link center of mass (positive value)
c1 = sym('c1','real');
c2 = sym('c2','real');
c3 = sym('c3','real');
c4 = sym('c4','real');
c5 = sym('c5','real');

%%%% Length of each link
l1 = sym('l1','real');
l2 = sym('l2','real');
l3 = sym('l3','real');
l4 = sym('l4','real');
l5 = sym('l5','real');

%%%% Moment of inertia of each link about its own center of mass
I1 = sym('I1','real');
I2 = sym('I2','real');
I3 = sym('I3','real');
I4 = sym('I4','real');
I5 = sym('I5','real');

g = sym('g','real'); % Gravity

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                Set up coordinate system and unit vectors                %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

i = sym([1; 0]);   % Horizontal axis
j = sym([0; 1]);   % Vertical axis

% 2d rotation matrix
rotz_2d = @(q)( [cos(q), -sin(q); sin(q), cos(q)] );

% center of mass of each link relative to the parent joint
C1 =  c1 * j; % torso
C2 = -c2 * j; % stance thigh
C3 = -c3 * j; % stance shank
C4 = -c4 * j; % swing thigh
C5 = -c5 * j; % swing shank

% points relative to the parent joint
L1 =  l1 * j; % head
L2 = -l2 * j; % stance knee
L3 = -l3 * j; % stance foot
L4 = -l4 * j; % swing knee
L5 = -l5 * j; % swing knee

% ����Ҫ��λ�� -- kinematics
P0 = x * i + y * j;              % hip
P1 = P0 + rotz_2d(q1) * L1;      % head
P2 = P0 + rotz_2d(q2) * L2;      % stance knee
P3 = P2 + rotz_2d(q2 + q3) * L3; % stance foot
P4 = P0 + rotz_2d(q4) * L4;      % swing knee
P5 = P4 + rotz_2d(q4 + q5) * L5; % swing foot

% ����������λ�� -- dynamics
G1 = P0 + rotz_2d(q1) * C1;      % torso
G2 = P0 + rotz_2d(q2) * C2;      % stance thigh
G3 = P2 + rotz_2d(q2 + q3) * C3; % stance shank
G4 = P0 + rotz_2d(q4) * C4;      % swing thigh
G5 = P4 + rotz_2d(q4 + q5) * C5; % swing shank

% ״̬���� -- state vector
q   = [x y q1 q2 q3 q4 q5]';
dq  = [dx dy dq1 dq2 dq3 dq4 dq5]';
ddq = [ddx ddy ddq1 ddq2 ddq3 ddq4 ddq5]';

% �������������ٶ�
dG1 = jacobian(G1, q) * dq;
dG2 = jacobian(G2, q) * dq;
dG3 = jacobian(G3, q) * dq;
dG4 = jacobian(G4, q) * dq;
dG5 = jacobian(G5, q) * dq;

% ���˽��ٶ� -- ƽ������ܺü��㣡��ά���������Ҫ������ת����
w1 = dq1;
w2 = dq2;
w3 = dq2 + dq3;
w4 = dq4;
w5 = dq4 + dq5;

% 1.����֧�Ŷ���ѧ�����Ƶ���
singleStanceDynamics();

% 2.Ŀ�꺯��
objFunc();

% 3.�ڶ����������ײǰ��Ķ���ѧ�仯
heelStrikeDynamics();

% 4.�˶�ѧ���� -- Ϊ�˿��ӻ������˵��˶�
kinematics();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Sub-Functions %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function singleStanceDynamics()
        disp('-->1.Deriving single stance dynamics...')
        
        % ����PE�붯��KE
        PE = m1 * g * dot(G1, j) + ...
            m2 * g * dot(G2, j) + m3 * g * dot(G3, j) + m4 * g * dot(G4, j) + m5 * g * dot(G5, j);
        KE = 0.5*m1*dot(dG1,dG1) + 0.5*m2*dot(dG2,dG2) + 0.5*m3*dot(dG3,dG3) + 0.5*m4*dot(dG4,dG4) + 0.5*m5*dot(dG5,dG5) + ...
            0.5*w1*I1*w1 + 0.5*w2*I2*w2 + 0.5*w3*I3*w3 + 0.5*w4*I4*w4 + 0.5*w5*I5*w5;

        % Lagrangian Dynamics Derivation -- �������ն���ѧ�Ƶ�
        DK_Ddq = jacobian(KE, dq);
        dDK_Ddq_dt = jacobian(DK_Ddq, q) * dq + jacobian(DK_Ddq, dq) * ddq;

        DK_Dq = jacobian(KE, q);
        DP_Dq = jacobian(PE, q);

        % ������������
        eqns = dDK_Ddq_dt - DK_Dq' + DP_Dq';

        % dynamics function: eqns = MM * ddq - FF        
        [MM, FF] = equationsToMatrix(eqns, ddq); % % MM * ddq = FF
        MM = simplify(MM);
        FF = simplify(FF);

        % P3: stance foot -- jacobian of contact point
        Jac_c = jacobian(P3, q);
        
        u = [u1 u2 u3 u4]';

        % MM * ddq - FF = [0; 0; 0; u] + Jac_c' * [fx; fy]
        % ==> rhs = FF + [0; 0; 0; u] + Jac_c' * [fx; fy]
        rhs = FF + [sym([0; 0; 0]); u] + Jac_c' * [fx; fy];
        
        % ���ɵ���֧�ŵĶ���ѧ����(single stance dynamics)
        matlabFunction(MM, rhs, ...
            'file', 'autoGen_dynamics.m', ...
            'vars', {...
            'x', 'y', 'q1', 'q2', 'q3', 'q4', 'q5', ...
            'dx', 'dy','dq1','dq2','dq3','dq4','dq5',...
            'u1','u2','u3','u4', 'fx', 'fy', ...
            'm1','m2','m3','m4','m5',...
            'I1','I2','I3','I4','I5',...
            'l1','l2','l3','l4', 'l5',...
            'c1','c2','c3','c4','c5',...
            'g'});
        
    end

    function objFunc()
        disp('-->2.Deriving objective function...')
        
        % Ŀ�꺯�����������ص�ƽ�����Ӵ�������(regularization)
        obj = u1*u1 + u2*u2 + u3*u3 + u4*u4 + 1e-4*fx*fx + 1e-4*fy*fy;
        
        matlabFunction(obj,...
            'file','autoGen_objFunc.m',...
            'vars',{'u1','u2','u3','u4', 'fx', 'fy'});
        
    end

    function heelStrikeDynamics()
        disp('-->3.Deriving heel-strike dynamics...')
        
        % �ο�ETH�Ķ���ѧ�鼮��
        % ��ײ����ѧ��λ��״̬���䣬�ٶ����� --> dz(+) = Nc * dz(-)
        % �����붯��
%         PE = m1 * g * dot(G1, j) + ...
%             m2 * g * dot(G2, j) + m3 * g * dot(G3, j) + m4 * g * dot(G4, j) + m5 * g * dot(G5, j);
        KE = 0.5*m1*dot(dG1,dG1) + 0.5*m2*dot(dG2,dG2) + 0.5*m3*dot(dG3,dG3) + 0.5*m4*dot(dG4,dG4) + 0.5*m5*dot(dG5,dG5) + ...
            0.5*w1*I1*w1 + 0.5*w2*I2*w2 + 0.5*w3*I3*w3 + 0.5*w4*I4*w4 + 0.5*w5*I5*w5;

        DK_Ddq = jacobian(KE, dq);
        MM = jacobian(DK_Ddq, dq); % ��ҪһЩ�����˶���ѧ������֪ʶ
        % ������Ҫ��Ϊ�������Ծ��� MM
                
        MM = simplify(MM);
        
        % �ڶ�������淢����ײ����������ڶ��ŵ�Jacobian
        Jac_c = jacobian(P5, q);
        
        % MM �� Jac_c Ϊ���Nc�ı�Ҫ����
        % Nc = eye(7) - MM^(-1)*Jac_c'*(Jac_c*MM^(-1)*Jac_c')^(-1)*Jac_c
        
        matlabFunction(MM, Jac_c, ...
            'file', 'autoGen_heelStrike.m', ...
            'vars', {...
            'x', 'y', 'q1', 'q2', 'q3', 'q4', 'q5', ...
            'm1','m2','m3','m4','m5',...
            'I1','I2','I3','I4','I5',...
            'l1','l2','l3','l4', 'l5',...
            'c1','c2','c3','c4','c5'});
        
        % ������ֻ��(P3--֧�Ž�; P5--�ڶ���)��λ����⺯��
        matlabFunction(P3, P5, ...
            'file', 'autoGen_feetPos.m', ...
            'vars', {...
            'x', 'y', 'q1', 'q2', 'q3', 'q4', 'q5', ...
            'l1','l2','l3','l4', 'l5'});
        
        % ������ֻ��(P3--֧�Ž�; P5--�ڶ���)���ٶ���⺯��
        dP3 = jacobian(P3, q) * dq;
        dP5 = jacobian(P5, q) * dq;
        matlabFunction(dP3, dP5, ...
            'file', 'autoGen_feetVel.m', ...
            'vars', {...
            'x', 'y', 'q1', 'q2', 'q3', 'q4', 'q5', ...
            'dx', 'dy', 'dq1', 'dq2', 'dq3', 'dq4', 'dq5', ...
            'l1','l2','l3','l4', 'l5'});
        
    end

    function kinematics()
        disp('-->4.Writing kinematics files...')
                
        P = [P0; P1; P2; P3; P4; P5]; % main points
        Gvec = [G1; G2; G3; G4; G5];  % CoM position
        
        % Used for plotting and animation
        matlabFunction(P,Gvec,'file','autoGen_kinematicsPoints.m',...
            'vars',{...
            'x','y','q1','q2','q3','q4','q5',...
            'l1','l2','l3','l4','l5',...
            'c1','c2','c3','c4','c5'},...
            'outputs',{'P','Gvec'});
        
    end


end