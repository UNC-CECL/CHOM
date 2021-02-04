function [tau_o,WTP,rp_base]=agent_distribution(mWTP,mtau_o,mrp,n,param)

% draw agent parameter distributions
% willingness to pay (WTP),income tax bracket (tau_o), base risk premium (rp_base)
% param 1 = WTP,tau_o,rp_base uncorrelated + random
% param 2 = WTP and tau_o correlated random, rp_base uncorrelated random
% param 3 = WTP, tau_o, rp_base correlated random

if param==1
    a   = mWTP(1);
    b   = mWTP(2);
    WTP = a+(b-a)*rand(n,1);
    
    a     = mtau_o(1);
    b     = mtau_o(2);
    tau_o = a+(b-a)*rand(n,1);
    
    a       = mrp(1);
    b       = mrp(2);
    rp_base = a+(b-a)*rand(n,1);
    
end

if param == 2
    Z(1,:) = 1-betarnd(6,3,n,1);
    Z(2,:) = 1-betarnd(6,3,n,1);
    
    Sigma = [1.0 0.8;
        0.8 1.0];
    C = chol(Sigma);
    M = C'*Z;
    
    bint = linspace(0,1,1000);                         % map the interval specified in tau_base
    bint = linspace(min(M(1,:))-0.001,max(M(1,:))+0.001,1000);      % map the interval specified by WTP_base
    cint = linspace(mtau_o(1),mtau_o(2),1000); % to [tau_o_base(1) tau_o_base(2)];
    for ii=1:n
        f       = find(M(1,ii)<bint);
        f       = f(1)-1;
        M(1,ii) = cint(f);
    end
    tau_o   = M(1,:)';

    bint = linspace(min(M(2,:))-0.001,max(M(2,:))+0.001,1000);      % map the interval specified by WTP_base
    cint = linspace(mWTP(1),mWTP(2),1000); % to [tau_o_base(1) tau_o_base(2)];
    for ii = 1:n
        f        = find(M(2,ii)<bint);
        f       = f(1)-1;
        M(2,ii) = cint(f);
    end
    WTP     = M(2,:)';
    
    a       = mrp(1);
    b       = mrp(2);
    rp_base = a+(b-a)*rand(n,1);
    
end


if param == 3 
    Z(1,:) = 1-betarnd(6,3,n,1);
    Z(2,:) = 1-betarnd(6,3,n,1);
    Z(3,:) = 1-betarnd(6,3,n,1);
        
    Sigma  = [1.0 0.8 -0.8 ;
              0.8 1.0 -0.8 ;
              0.8 0.8 1.0 ];
    C = chol(Sigma);
    M = C'*Z;
    
    bint = linspace(min(M(1,:))-0.001,max(M(1,:))+0.001,1000);      % map the interval specified by WTP_base
    cint = linspace(mtau_o(1),mtau_o(2),1000); % to [tau_o_base(1) tau_o_base(2)];
    for ii=1:n
        f       = find(M(1,ii)<bint);
        f       = f(1)-1;
        M(1,ii) = cint(f);
    end
    tau_o   = M(1,:)';
    
    bint = linspace(min(M(2,:))-0.001,max(M(2,:))+0.001,1000);      % map the interval specified by WTP_base
    cint = linspace(mWTP(1),mWTP(2),1000);
    for ii = 1:n
        f        = find(M(2,ii)<bint);
        f       = f(1)-1;
        M(2,ii) = cint(f);
    end
    WTP     = M(2,:)';
    
    bint = linspace(min(M(3,:))-0.001,max(M(3,:))+0.001,1000);
    cint = linspace(mrp(1),mrp(2),1000);
    for ii=1:n
        f       = find(M(3,ii)<bint);
        f       = f(1)-1;
        M(3,ii) = cint(f);
    end
    rp_base = M(3,:)';
    
%     close all; 
%     subplot(131); plot(tau_o,WTP,'k.'); xlabel('\tau_o'); ylabel('wtp')
%     subplot(132); plot(rp_base,tau_o,'k.'); ylabel('\tau_o');xlabel('rpbase')
%     subplot(133); plot(rp_base,WTP,'k.'); ylabel('WTP');xlabel('rpbase')

    
end


















