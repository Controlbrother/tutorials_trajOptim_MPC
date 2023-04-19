function [c, ceq] = pathConstraint(q,p)
% ʩ�ӹ���Լ��������֧�Ž�λ�ù̶����ڶ��Ÿ߶ȵ�

x = q(1, :);
y = q(2, :);
q1 = q(3,:);
q2 = q(4,:);
q3 = q(5,:);
q4 = q(6,:);
q5 = q(7,:);

% position of stance and swing foot
[P3,P5] = autoGen_feetPos(...
    x,y,q1,q2,q3,q4,q5,...
    p.l1, p.l2, p.l3, p.l4, p.l5);

% ֧�Ž�λ�ù̶� == [0; 0] -- ��ʽԼ��
ceq = reshape(P3 - zeros(size(P3)), [], 1);

% �ڶ��Ÿ߶� >= 0 -- ����ʽԼ��
c = -P5(2, :)';

end