t2 = t-1;; % last point in plot

close all
% willingness to pay
subplot(4,4,1)
yyaxis left
plot(t1:t2,X.WTP(t1:t2))
ylabel('WTP(bw)')
yyaxis right
plot(mean(M.WTP_base+M.HV).*ones(length(X.WTP),1));
ylabel('Base WTP')
legend('total WTP','WTP_{base}+HV')
xlim([t1 t2])
xlabel('time')

% price
subplot(4,4,2)
plot([t1:t2]',X.price(t1:t2))
ylabel('price');
hold on
plot([t1:t2],M.P_e(t1:t2))
xlabel('time');
htitle=title('');
xlim([t1 t2])
legend('price','P_e')

% user costs
subplot(443)
plot(t1:t2,X.oUC(t1:t2))
hold on
plot(t1:t2,X.iUC(t1:t2))
ylabel('user cost')
legend('owner','investor')
xlim([t1 t2])
xlabel('time')

% number agents
subplot(4,4,4)
plot(X.n(t1:t2))
xlabel('time')
ylabel('number agents')

% beach width and stuff
subplot(4,4,5)
X.bw_halftime=X.bw_halftime(t1:t2,:)'; 
X.t_halftime=X.t_halftime(t1:t2,:)'; 
X.bw_halftime=X.bw_halftime(:);
X.t_halftime=X.t_halftime(:);
plot(X.t_halftime,X.bw_halftime,'k')
hold on
plot(t1:t2,X.Ebw(t1:t2),'k','linewidth',2)
newplan(X.newplan==0)=NaN;
plot(t1:t2,circshift(newplan(t1:t2)*E.x0+1,[1 0]),'bo','markersize',1,'linewidth',2,'markerfacecolor','b')
X.builddunetime(X.builddunetime==0)=NaN;
plot(t1:t2,E.x0*X.builddunetime(t1:t2)+2,'ro','markersize',4,'linewidth',1,'markerfacecolor','r')
xlim([t1 t2])
ylabel('BW')
legend('BW','E(BW)','new plan','Dune')
xlabel('time')

% nourishment and dune cost ben
subplot(4,4,6)
plot(t1:t2,X.planbenefit_beach(t1:t2),'b','linewidth',2)
hold on
% plot(t1:t2,dunebens(t1:t2),'r','linewidth',2)
% legend('beach','dune')
plot(t1:t2,zeros(length(t1:t2),1),'k')
ylabel('benefit - tax burden')
xlim([t1 t2])
xlabel('time')

% property tax
subplot(4,4,7)
plot(t1:t2,X.tau_prop(t1:t2))
ylabel('\tau_{property}')
xlabel('time')
xlim([t1 t2])

%
subplot(4,4,8)

% dune height
subplot(4,4,9)
plot(t1:t2,X.h_dune(t1:t2))
hold on
plot(t1:t2,X.mdh(t1:t2),'k','linewidth',2)
ylabel('dune height')
legend('DH','E(DH)')
xlabel('time')
xlim([t1 t2])

%
subplot(4,4,10)

% beach plan
subplot(4,4,13)
X.beach_plan(X.beach_plan==11) = 0;
plot(t1:t2,X.beach_plan(t1:t2))
hold on
ylabel('beach_plan')
xlim([t1 t2])
xlabel('time')

% perceived erosion rate
subplot(4,4,14)
plot(t1:t2,X.er(t1:t2))
hold on 
plot(t1:t2,F.ER(t1:t2))
legend('perceived erosion','real erosion')
ylabel('erosion rate')
xlabel('time')

% investor market share
subplot(4,4,15)
plot(t1:t2,X.mkt(t1:t2))
ylabel('mkt share')
xlabel('time')
xlim([t1 t2])

%
subplot(4,4,16)

% autoArrangeFigures
set(gcf, 'Position', get(0, 'Screensize'));
set(gcf,'color','w');

