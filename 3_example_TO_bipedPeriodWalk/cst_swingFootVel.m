function c = cst_swingFootVel(x0,xF,p)
% ʩ�Ӱڶ��ſ�ʼ�ͽ���״̬���ٶ�Լ��

q0  = x0(1:7);
qF  = xF(1:7);
dq0 = x0(8:14);
dqF = xF(8:14);

% initial
[~,dP5_0] = autoGen_feetVel(...
    q0(1),q0(2),q0(3),q0(4),q0(5),q0(6),q0(7),...
    dq0(1),dq0(2),dq0(3),dq0(4),dq0(5),dq0(6),dq0(7),...
    p.l1, p.l2, p.l3, p.l4, p.l5);

% final
[~,dP5_F] = autoGen_feetVel(...
    qF(1),qF(2),qF(3),qF(4),qF(5),qF(6),qF(7),...
    dqF(1),dqF(2),dqF(3),dqF(4),dqF(5),dqF(6),dqF(7),...
    p.l1, p.l2, p.l3, p.l4, p.l5);

% velocity constraints (vertical axis -- y)
% dP5_0(2) >= 0 -- ��ʼ�ڶ��ٶ� >= 0
% dP5_F(2) <= 0 -- �����ڶ��ٶ� <= 0
c = [-dP5_0(2); dP5_F(2)];

end