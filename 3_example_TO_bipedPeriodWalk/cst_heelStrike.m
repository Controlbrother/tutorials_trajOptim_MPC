function ceq = cst_heelStrike(x0,xF,p)
% ʩ�ӿ���Ӳ�Ӵ������ײ�ٶ�ͻ������ڲ�̬Լ��

qF  = xF(1:7);
q0  = x0(1:7);
dqF = xF(8:14);
dq0 = x0(8:14);

% �����ײʱ��MM����Ͱڶ��ż�������潨���Ӵ��ĽӴ����Jacobian(����qF�й�)
[MM, Jc] = autoGen_heelStrike(...
    qF(1),qF(2),qF(3),qF(4),qF(5),qF(6),qF(7),...
    p.m1, p.m2, p.m3, p.m4, p.m5, p.I1, p.I2, p.I3, p.I4, p.I5, ...
    p.l1, p.l2, p.l3, p.l4, p.l5, p.c1, p.c2, p.c3, p.c4, p.c5);

% Nc����������ο�../reference/ETH_dynamics_lecture.pdf
Nc = eye(7) - MM^(-1) * Jc' * (Jc * MM^(-1) * Jc')^(-1) * Jc;

%%%%%%   ���ڲ�̬Լ��--��̬���ٶȣ� %%%%%%
% 1.��̬Լ����ע�Ⲣû�аѿ�ʼ�ͽ�����̬��x�Ž�Լ����
ceqPos = q0(2:7) - qF([2,3,6,7,4,5]);

% 2.�ٶ�Լ���� ��Ҳ������Ҫ��һ��Լ����Ӳ�Ӵ�(Hard Contact)�ļ����ǣ�
% ��ײ����ǰ������˵�״̬q������ͻ�䣬��״̬�ĵ�����Ҳ�����ٶ�dq����ͻ��
% �ù�ʽ��ʾ���ǣ�dq(+) = Nc * dq(-) +:������ײ��, -:������ײǰ
% ������dq(+)��Ӧ���Ż��е�dq0(��һ���ڵ���ײ��)
%       dq(-)��Ӧ���Ż��е�dqF(��һ���ڵ���ײǰ)
% �ʶ�Լ����ʾΪ��dq0 = Nc * dqF
ceqVel = dq0 - Nc * dqF;

% pack up equality constraints
ceq = [ceqPos;ceqVel];  

end