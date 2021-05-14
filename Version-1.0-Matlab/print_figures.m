% t2 = 170; % last point in plot

close all

subplot(3,5,1)
plot(t1:t2,X_NOF.price(t1:t2),'color',rgb('cerise'),'linewidth',1.5)
hold on
plot(t1:t2,X_OF.price(t1:t2),'color',rgb('cerulean'),'linewidth',1.5)
plot(t1:t2,M.P_e_OF(t1:t2),'k','linewidth',1)
plot(t1:t2,M.P_e_NOF(t1:t2),'k','linewidth',1)
legend('NOF','OF','P_e OF','P_e NOF')
xlim([t1 t2]); xlabel('time')
ylabel('price')
% ylim([3e5 16e5])

subplot(3,5,2)
MMT.newplan(MMT.newplan==0)=NaN;
plot(t1:t2,MMT.bw(t1:t2),'color',rgb('black'),'linewidth',1)
hold on
plot(t1:t2,ACOM.Ebw(t1:t2),'color',rgb('dark periwinkle'),'linewidth',3)
plot(t1:t2,102*MMT.newplan(t1:t2),'rx')
ylabel('beach width')
legend('bw_t','E_t[bw]_{t+1}')
xlim([t1 t2]); xlabel('time')
ylim([0 105])

subplot(3,5,3)
plot(t1:t2,MMT.netben(t1:t2,1),'color',rgb('cerise'),'linewidth',1.5)
hold on
plot(t1:t2,MMT.netben(t1:t2,2),'color',rgb('cerulean'),'linewidth',1.5)
legend('NOF','OF')
ylabel('net benefits')
xlim([t1 t2]); xlabel('time')
ylim([-1e5 1e5])


subplot(3,5,4)
plot(t1:t2,SV_NOF.meanAWTP_base(t1:t2),'color',rgb('cerise'),'linewidth',1.5)
hold on
plot(t1:t2,SV_OF.meanAWTP_base(t1:t2),'color',rgb('cerulean'),'linewidth',1.5)
ylabel('avg WTP_{base}')
xlim([t1 t2]); xlabel('time')
% ylim([0 5e4])

subplot(3,5,5)
plot(t1:t2,SV_NOF.meanAWTP_alph(t1:t2),'color',rgb('cerise'),'linewidth',1.5)
hold on
plot(t1:t2,SV_OF.meanAWTP_alph(t1:t2),'color',rgb('cerulean'),'linewidth',1.5)
ylabel('avg WTP_\alpha')
xlim([t1 t2]); xlabel('time')
% ylim([0 5e4])


subplot(3,5,6)
for t=t1:t2
    wtp_all(t,1)=mean(X_NOF.WTP{t});
    wtp_all(t,2)=mean(X_OF.WTP{t});
end
plot(t1:t2,wtp_all(t1:t2,1),'color',rgb('cerise'),'linewidth',1.5)
hold on
plot(t1:t2,wtp_all(t1:t2,2),'color',rgb('cerulean'),'linewidth',1.5)
xlim([t1 t2]); xlabel('time')
legend('NOF','OF')
ylabel('avg WTP')
% ylim([1e4 2e5])

subplot(3,5,7)
plot(t1:t2,X_NOF.mkt(t1:t2),'color',rgb('cerise'),'linewidth',1.5)
hold on
plot(t1:t2,X_OF.mkt(t1:t2),'color',rgb('cerulean'),'linewidth',1.5)
total_market=(ACOM.n_NOF*X_NOF.mkt(t1:t2)+ACOM.n_OF*X_OF.mkt(t1:t2))/ACOM.n_agent_total;
plot(t1:t2,total_market,'k--','linewidth',2)
ylabel('inv. market share')
xlim([t1 t2]); xlabel('time')
ylim([0 1])

subplot(3,5,8)
plot(t1:t2,A_NOF.tau_prop(t1:t2),'color',rgb('cerise'),'linewidth',1.5)
hold on
plot(t1:t2,A_OF.tau_prop(t1:t2),'color',rgb('cerulean'),'linewidth',1.5)
ylabel('\tau^p')
xlabel('time')
xlim([t1 t2])
legend('NOF','OF')
ylim([0.005 0.07])


subplot(3,5,9)
plot(t1:t2,SV_NOF.meanAtauo(t1:t2),'color',rgb('cerise'),'linewidth',3)
hold on
plot(t1:t2,SV_OF.meanAtauo(t1:t2),'color',rgb('cerulean'),'linewidth',3)
ylabel('avg \tau^o')
xlim([t1 t2]); xlabel('time')
ylim([0.05 0.37])


subplot(3,5,10)
plot(t1:t2,MMT.h_dune(t1:t2),'color',rgb('black'),'linewidth',1)
hold on
plot(t1:t2,ACOM.Edh(t1:t2),'color',rgb('dark periwinkle'),'linewidth',3)
ylabel('dune height')
legend('hdune_t','E_t[hdune]_{t+1}')
xlim([t1 t2]); xlabel('time')
ylim([0 6])

subplot(3,5,11)

m1=mean(SV_NOF.rp_o(t1:t2,:),2)';
s1=std(SV_NOF.rp_o(t1:t2,:)');
m2=mean(SV_OF.rp_o(t1:t2,:),2)';
s2=std(SV_OF.rp_o(t1:t2,:)');
for i=1:3
boundedline([t1:t2], [m1], s1, 'alpha','cmap', rgb('cerise'));
boundedline([t1:t2], [m2], s2, 'alpha','cmap', rgb('cerulean'));
end
hold on
plot(t1:t2,SV_NOF.rp_I(t1:t2),'color',rgb('cerise'),'linewidth',2)
plot(t1:t2,SV_OF.rp_I(t1:t2),'color',rgb('cerulean'),'linewidth',2)
xlim([t1 t2]); xlabel('time')
ylabel('r^p')
xlim([t1 t2]); xlabel('time')
% ylim([0.01 0.1])


subplot(3,5,12)
m1=mean(SV_NOF.g_o(t1:t2,:),2)';
s1=std(SV_NOF.g_o(t1:t2,:)');
m2=mean(SV_OF.g_o(t1:t2,:),2)';
s2=std(SV_OF.g_o(t1:t2,:)');
for i=1:3
boundedline([t1:t2], [m1], s1, 'alpha','cmap', rgb('cerise'));
boundedline([t1:t2], [m2], s2, 'alpha','cmap', rgb('cerulean'));
end
hold on
plot(t1:t2,SV_NOF.g_I(t1:t2),'color',rgb('cerise'),'linewidth',2)
plot(t1:t2,SV_OF.g_I(t1:t2),'color',rgb('cerulean'),'linewidth',2)
ylabel('exp. cap gains')
xlim([t1 t2]); xlabel('time')
% ylim([-0.07 0.07])

subplot(3,5,13)
plot(t1:t2,SV_NOF.W(t1:t2),'color',rgb('cerise'),'linewidth',1.5)
hold on
plot(t1:t2,SV_OF.W(t1:t2),'color',rgb('cerulean'),'linewidth',1.5)
xlim([t1 t2]); xlabel('time')
ylabel('W')

subplot(3,5,14)
plot(t1:t2,SV_NOF.beta_x(t1:t2),'color',rgb('cerise'),'linewidth',1.5)
hold on
plot(t1:t2,SV_OF.beta_x(t1:t2),'color',rgb('cerulean'),'linewidth',1.5)
xlim([t1 t2]); xlabel('time')
ylabel('x_{\beta}')

subplot(3,5,15)
m1=mean(X_NOF.Ouc(:,t1:t2),1)';
s1=std(X_NOF.Ouc(:,t1:t2));
m2=mean(X_OF.Ouc(:,t1:t2),1)';
s2=std(X_OF.Ouc(:,t1:t2));
boundedline([t1:t2], [m1], s1, 'alpha','cmap', rgb('cerise'));
hold on
boundedline([t1:t2], [m2], s2, 'alpha','cmap', rgb('cerulean'));
hold on
% plot(t1:t2,X_NOF.rent(t1:t2)./X_NOF.price(t1:t2),'color',rgb('cerise'),'linewidth',2)
% plot(t1:t2,X_OF.rent(t1:t2)./X_OF.price(t1:t2),'color',rgb('cerulean'),'linewidth',2)
ylabel('user cost')
figure(2)


subplot(5,4,1:2)
X=X_OF;
ind=1;
for ti=t1:t2
    maxti(ind)=max(X.P_o(:,ti));
    minti(ind)=min(X.P_o(:,ti));
ind=ind+1;
end
minti(minti==0)=NaN;
EDGES=linspace(0,2e6,50);
clear po_total
for ti=2:t2
    [N,EDGES] = histcounts(X.P_o(:,ti),EDGES);
    po_total(:,ti)=N(:);
end
EDGES=EDGES(2:end); EDGES=EDGES(:);
time=[t1:t2]; time=time(:);
imagesc(time,EDGES,po_total(:,t1:t2))
hold on
plot(t1:t2,X_OF.price(t1:t2),'color',[1 1 1],'linewidth',1)
colormap(magma(512))
set(gca,'YDir','normal')
ylabel('Histogram Bid Price')
xlabel('time')
colorbar
xlim([t1 t2])

subplot(5,4,3:4)
X=X_NOF;
ind=1;
for ti=t1:t2
    maxti(ind)=max(X.P_o(:,ti));
    minti(ind)=min(X.P_o(:,ti));
ind=ind+1;
end
minti(minti==0)=NaN;
EDGES=linspace(0,2e6,50);
clear po_total
for ti=2:t2
    [N,EDGES] = histcounts(X.P_o(:,ti),EDGES);
    po_total(:,ti)=N(:);
end
EDGES=EDGES(2:end); EDGES=EDGES(:);
time=[t1:t2]; time=time(:);
imagesc(time,EDGES,po_total(:,t1:t2))
hold on
plot(t1:t2,X_OF.price(t1:t2),'color',[1 1 1],'linewidth',1)
colormap(magma(512))
set(gca,'YDir','normal')
ylabel('Histogram Bid Price')
xlabel('time')
colorbar
xlim([t1 t2])




subplot(5,4,5:6)
X=X_OF;
for ti=t1:t2
    maxti(ti)=max(SV_OF.g_o(ti,:));
    minti(ti)=min(SV_OF.g_o(ti,:));
end
minti(minti==0)=NaN;
EDGES=linspace(min(minti(12:t2)),max(maxti(12:t2)),50);
clear po_total
for ti=2:t2
    [N,EDGES] = histcounts(SV_OF.g_o(ti,:),EDGES);
    po_total(:,ti)=N(:);
end
EDGES=EDGES(2:end); EDGES=EDGES(:);
time=[12:t2]; time=time(:);
imagesc(time,EDGES,po_total(:,time))
hold on
plot(t1:t2,SV_OF.g_I(t1:t2),'color',[1 1 1],'linewidth',1)
colormap(magma(512))
set(gca,'YDir','normal')
ylabel('Histogram cap gain')
xlabel('time')
colorbar
xlim([t1 t2])

subplot(5,4,7:8)
X=X_NOF;
ind=1;
for ti=t1:t2
    maxti(ind)=max(SV_NOF.g_o(ti,:));
    minti(ind)=min(SV_NOF.g_o(ti,:));
ind=ind+1;
end
minti(minti==0)=NaN;
EDGES=linspace(min(minti(12:t2)),max(maxti(12:t2)),50);
clear po_total
for ti=2:t2
    [N,EDGES] = histcounts(SV_NOF.g_o(ti,:),EDGES);
    po_total(:,ti)=N(:);
end
EDGES=EDGES(2:end); EDGES=EDGES(:);
time=[12:t2]; time=time(:);
imagesc(time,EDGES,po_total(:,time))
hold on
plot(t1:t2,SV_NOF.g_I(t1:t2),'color',[1 1 1],'linewidth',1)
colormap(magma(512))
set(gca,'YDir','normal')
ylabel('Histogram cap gain')
xlabel('time')
colorbar
xlim([t1 t2])



subplot(5,4,9:10)
X=X_OF;
for ti=t1:t2
    maxti(ti)=max(SV_OF.rp_o(ti,:));
    minti(ti)=min(SV_OF.rp_o(ti,:));
end
minti(minti==0)=NaN;
EDGES=linspace(min(minti(t1:t2)),max(maxti(t1:t2)),50);
clear po_total
for ti=2:t2
    [N,EDGES] = histcounts(SV_OF.rp_o(ti,:),EDGES);
    po_total(:,ti)=N(:);
end
EDGES=EDGES(2:end); EDGES=EDGES(:);
time=[t1:t2]; time=time(:);
imagesc(time,EDGES,po_total(:,t1:t2))
hold on
plot(t1:t2,SV_OF.rp_I(t1:t2),'color',[1 1 1],'linewidth',1)
colormap(magma(512))
set(gca,'YDir','normal')
ylabel('Histogram risk prem')
xlabel('time')
colorbar
xlim([t1 t2])

subplot(5,4,11:12)
X=X_NOF;
ind=1;
for ti=t1:t2
    maxti(ind)=max(SV_NOF.rp_o(ti,:));
    minti(ind)=min(SV_NOF.rp_o(ti,:));
ind=ind+1;
end
minti(minti==0)=NaN;
EDGES=linspace(min(minti(t1:t2)),max(maxti(t1:t2)),20);
clear po_total
for ti=2:t2
    [N,EDGES] = histcounts(SV_NOF.rp_o(ti,:),EDGES);
    po_total(:,ti)=N(:);
end
EDGES=EDGES(2:end); EDGES=EDGES(:);
time=[t1:t2]; time=time(:);
imagesc(time,EDGES,po_total(:,t1:t2))
hold on
plot(t1:t2,SV_NOF.rp_I(t1:t2),'color',[1 1 1],'linewidth',1)
colormap(magma(512))
set(gca,'YDir','normal')
ylabel('Histogram risk prem')
xlabel('time')
colorbar
xlim([t1 t2])

% subplot(5,4,5:6)
% X=X_OF;
% for ti=1:t2
%     maxti(ti)=max(X.Ouc2(:,ti));
%     minti(ti)=min(X.Ouc2(:,ti));
% end
% minti(minti==0)=NaN;
% EDGES=linspace(min(minti(2:end)),max(maxti(2:end)),50);
% clear po_total
% for ti=2:t2
%     [N,EDGES] = histcounts(X.Ouc2(:,ti),EDGES);
%     po_total(:,ti)=N(:);
% end
% EDGES=EDGES(2:end); EDGES=EDGES(:);
% time=[t1:t2]; time=time(:);
% imagesc(time,EDGES,po_total(:,t1:t2))
% hold on
% plot(t1:t2,X_OF.rent(t1:t2)./X_OF.price(t1:t2),'color',[1 1 1],'linewidth',1.5)
% colormap(magma(512))
% set(gca,'YDir','normal')
% ylabel('Histogram Bid Price')
% xlabel('time')
% colorbar
% xlim([t1 t2])
% 
% 
% 
% subplot(5,4,7:8)
% X=X_NOF;
% ind=1;
% for ti=t1:t2
%     maxti(ind)=max(X.Ouc2(:,ti));
%     minti(ind)=min(X.Ouc2(:,ti));
% ind=ind+1;
% end
% minti(minti==0)=NaN;
% EDGES=linspace(min(minti),max(maxti),50);
% % EDGES=linspace(0,2e6,50);
% clear po_total
% for ti=2:t2
%     [N,EDGES] = histcounts(X.Ouc2(:,ti),EDGES);
%     po_total(:,ti)=N(:);
% end
% EDGES=EDGES(2:end); EDGES=EDGES(:);
% time=[t1:t2]; time=time(:);
% imagesc(time,EDGES,po_total(:,t1:t2))
% hold on
% plot(t1:t2,X_NOF.rent(t1:t2)./X_NOF.price(t1:t2),'color',[1 1 1],'linewidth',1.5)
% colormap(magma(512))
% set(gca,'YDir','normal')
% ylabel('Histogram Bid Price')
% xlabel('time')
% colorbar
% xlim([t1 t2])



% close all
% filename1='C:\Users\Zack\Desktop\econmeeting\price_2'
% plot(t1:t2,X_NOF.price(t1:t2),'color',rgb('cerise'),'linewidth',1.5)
% hold on
% plot(t1:t2,X_OF.price(t1:t2),'color',rgb('cerulean'),'linewidth',1.5)
% plot(t1:t2,M.P_e_OF(t1:t2),'k','linewidth',1)
% plot(t1:t2,M.P_e_NOF(t1:t2),'k','linewidth',1)
% xlim([t1 t2]); 
% hTitle=title('')
% hLegend = legend('NOF','OF','P_e OF','P_e NOF');
% hXLabel = xlabel('time (yr)');
% hYLabel = ylabel('price');
% set( gca                       , ...
%     'FontName'   , 'Helvetica' );
% set([hTitle, hXLabel, hYLabel], ...
%     'FontName'   , 'Helvetica');
% set([hLegend, gca]             , ...
%     'FontSize'   , 12           );
% set([hXLabel, hYLabel]  , ...
%     'FontSize'   , 14          );
% set( hTitle                    , ...
%     'FontSize'   , 14          , ...
%     'FontWeight' , 'bold'      );
% set(gca, ...
%     'Box'         , 'off'     , ...
%     'TickDir'     , 'out'     , ...
%     'TickLength'  , [.015 .015] , ...
%     'XMinorTick'  , 'on'      , ...
%     'YMinorTick'  , 'on');
% set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
% set(gcf, 'PaperSize', [5 5]); 
% print('-dpdf','-painters',filename1)
% 
% close all
% filename2='C:\Users\Zack\Desktop\econmeeting\bw_2'
% MMT.newplan(MMT.newplan==0)=NaN;
% plot(t1:t2,MMT.bw(t1:t2),'color',rgb('black'),'linewidth',1)
% hold on
% plot(t1:t2,ACOM.Ebw(t1:t2),'color',rgb('dark periwinkle'),'linewidth',3)
% plot(t1:t2,102*MMT.newplan(t1:t2),'rx')
% ylabel('beach width')
% xlim([t1 t2]); xlabel('time')
% ylim([0 105])
% hTitle=title('')
% hLegend = legend('bw_t','E_t[bw]_{t+1}')
% hXLabel = xlabel('time (yr)');
% hYLabel = ylabel('beach width');
% set( gca                       , ...
%     'FontName'   , 'Helvetica' );
% set([hTitle, hXLabel, hYLabel], ...
%     'FontName'   , 'Helvetica');
% set([hLegend, gca]             , ...
%     'FontSize'   , 12           );
% set([hXLabel, hYLabel]  , ...
%     'FontSize'   , 14          );
% set( hTitle                    , ...
%     'FontSize'   , 14          , ...
%     'FontWeight' , 'bold'      );
% set(gca, ...
%     'Box'         , 'off'     , ...
%     'TickDir'     , 'out'     , ...
%     'TickLength'  , [.015 .015] , ...
%     'XMinorTick'  , 'on'      , ...
%     'YMinorTick'  , 'on');
% set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
% set(gcf, 'PaperSize', [5 5]); 
% print('-dpdf','-painters',filename2)
% 
% 
% close all
% filename3='C:\Users\Zack\Desktop\econmeeting\wtp_2'
% for t=t1:t2
%     wtp_all(t,1)=mean(X_NOF.WTP{t});
%     wtp_all(t,2)=mean(X_OF.WTP{t});
% end
% plot(t1:t2,wtp_all(t1:t2,1),'color',rgb('cerise'),'linewidth',1.5)
% hold on
% plot(t1:t2,wtp_all(t1:t2,2),'color',rgb('cerulean'),'linewidth',1.5)
% xlim([t1 t2]); 
% hTitle=title('')
% hLegend = legend('NOF','OF');
% hXLabel = xlabel('time (yr)');
% hYLabel = ylabel('avg. WTP');
% set( gca                       , ...
%     'FontName'   , 'Helvetica' );
% set([hTitle, hXLabel, hYLabel], ...
%     'FontName'   , 'Helvetica');
% set([hLegend, gca]             , ...
%     'FontSize'   , 12           );
% set([hXLabel, hYLabel]  , ...
%     'FontSize'   , 14          );
% set( hTitle                    , ...
%     'FontSize'   , 14          , ...
%     'FontWeight' , 'bold'      );
% set(gca, ...
%     'Box'         , 'off'     , ...
%     'TickDir'     , 'out'     , ...
%     'TickLength'  , [.015 .015] , ...
%     'XMinorTick'  , 'on'      , ...
%     'YMinorTick'  , 'on');
% set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
% set(gcf, 'PaperSize', [5 5]); 
% print('-dpdf','-painters',filename3)
% 
% close all
% filename4='C:\Users\Zack\Desktop\econmeeting\mkt_2'
% plot(t1:t2,X_NOF.mkt(t1:t2),'color',rgb('cerise'),'linewidth',1.5)
% hold on
% plot(t1:t2,X_OF.mkt(t1:t2),'color',rgb('cerulean'),'linewidth',1.5)
% total_market=(ACOM.n_NOF*X_NOF.mkt(t1:t2)+ACOM.n_OF*X_OF.mkt(t1:t2))/ACOM.n_agent_total;
% plot(t1:t2,total_market,'k--','linewidth',2)
% xlim([t1 t2]); 
% ylim([0 1])
% hTitle=title('')
% hLegend = legend('NOF','OF','all');
% hXLabel = xlabel('time (yr)');
% hYLabel = ylabel('inv. market share')
% set( gca                       , ...
%     'FontName'   , 'Helvetica' );
% set([hTitle, hXLabel, hYLabel], ...
%     'FontName'   , 'Helvetica');
% set([hLegend, gca]             , ...
%     'FontSize'   , 12           );
% set([hXLabel, hYLabel]  , ...
%     'FontSize'   , 14          );
% set( hTitle                    , ...
%     'FontSize'   , 14          , ...
%     'FontWeight' , 'bold'      );
% set(gca, ...
%     'Box'         , 'off'     , ...
%     'TickDir'     , 'out'     , ...
%     'TickLength'  , [.015 .015] , ...
%     'XMinorTick'  , 'on'      , ...
%     'YMinorTick'  , 'on');
% set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
% set(gcf, 'PaperSize', [5 5]); 
% print('-dpdf','-painters',filename4)
% 
% close all
% filename5='C:\Users\Zack\Desktop\econmeeting\tau_2'
% plot(t1:t2,SV_NOF.meanAtauo(t1:t2),'color',rgb('cerise'),'linewidth',3)
% hold on
% plot(t1:t2,SV_OF.meanAtauo(t1:t2),'color',rgb('cerulean'),'linewidth',3)
% xlim([t1 t2]); xlabel('time')
% ylim([0.05 0.37])
% hTitle=title('')
% hLegend = legend('NOF','OF','all');
% hXLabel = xlabel('time (yr)');
% hYLabel = ylabel('avg \tau^o');
% set( gca                       , ...
%     'FontName'   , 'Helvetica' );
% set([hTitle, hXLabel, hYLabel], ...
%     'FontName'   , 'Helvetica');
% set([hLegend, gca]             , ...
%     'FontSize'   , 12           );
% set([hXLabel, hYLabel]  , ...
%     'FontSize'   , 14          );
% set( hTitle                    , ...
%     'FontSize'   , 14          , ...
%     'FontWeight' , 'bold'      );
% set(gca, ...
%     'Box'         , 'off'     , ...
%     'TickDir'     , 'out'     , ...
%     'TickLength'  , [.015 .015] , ...
%     'XMinorTick'  , 'on'      , ...
%     'YMinorTick'  , 'on');
% set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
% set(gcf, 'PaperSize', [5 5]); 
% print('-dpdf','-painters',filename5)
% 
% close all
% filename6='C:\Users\Zack\Desktop\econmeeting\dune_2'
% plot(t1:t2,MMT.h_dune(t1:t2),'color',rgb('black'),'linewidth',1)
% hold on
% plot(t1:t2,ACOM.Edh(t1:t2),'color',rgb('dark periwinkle'),'linewidth',3)
% hTitle=title('')
% hLegend = legend('hdune_t','E_t[hdune]_{t+1}')
% hXLabel = xlabel('time (yr)');
% hYLabel = ylabel('dune height')
% xlim([t1 t2]);
% set( gca                       , ...
%     'FontName'   , 'Helvetica' );
% set([hTitle, hXLabel, hYLabel], ...
%     'FontName'   , 'Helvetica');
% set([hLegend, gca]             , ...
%     'FontSize'   , 12           );
% set([hXLabel, hYLabel]  , ...
%     'FontSize'   , 14          );
% set( hTitle                    , ...
%     'FontSize'   , 14          , ...
%     'FontWeight' , 'bold'      );
% set(gca, ...
%     'Box'         , 'off'     , ...
%     'TickDir'     , 'out'     , ...
%     'TickLength'  , [.015 .015] , ...
%     'XMinorTick'  , 'on'      , ...
%     'YMinorTick'  , 'on');
% set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
% set(gcf, 'PaperSize', [5 5]); 
% print('-dpdf','-painters',filename6)
% 
% 
% close all
% filename7='C:\Users\Zack\Desktop\econmeeting\rp_2'
% m1=mean(SV_NOF.rp_o(t1:t2,:),2)';
% s1=std(SV_NOF.rp_o(t1:t2,:)');
% m2=mean(SV_OF.rp_o(t1:t2,:),2)';
% s2=std(SV_OF.rp_o(t1:t2,:)');
% for i=1:3
%     boundedline([t1:t2], [m1], s1, 'alpha','cmap', rgb('cerise'));
%     boundedline([t1:t2], [m2], s2, 'alpha','cmap', rgb('cerulean'));
%     set(gca, ...
%     'Box'         , 'off'     , ...
%     'TickDir'     , 'out'     , ...
%     'TickLength'  , [.015 .015] , ...
%     'XMinorTick'  , 'on'      , ...
%     'YMinorTick'  , 'on');
% end
% hold on
% plot(t1:t2,SV_NOF.rp_I(t1:t2),'color',rgb('cerise'),'linewidth',2)
% plot(t1:t2,SV_OF.rp_I(t1:t2),'color',rgb('cerulean'),'linewidth',2)
% hXLabel = xlabel('time (yr)');
% hYLabel = ylabel('r^p')
% hTitle=title('');
% xlim([t1 t2]);
% set( gca                       , ...
%     'FontName'   , 'Helvetica' );
% set([hTitle, hXLabel, hYLabel], ...
%     'FontName'   , 'Helvetica');
% set([gca]             , ...
%     'FontSize'   , 12           );
% set([hXLabel, hYLabel]  , ...
%     'FontSize'   , 14          );
% set( hTitle                    , ...
%     'FontSize'   , 14          , ...
%     'FontWeight' , 'bold'      );
% set(gca, ...
%     'Box'         , 'off'     , ...
%     'TickDir'     , 'out'     , ...
%     'TickLength'  , [.015 .015] , ...
%     'XMinorTick'  , 'on'      , ...
%     'YMinorTick'  , 'on');
% set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
% set(gcf, 'PaperSize', [5 5]);
% print('-dpdf','-painters',filename7)
% 
% 
% close all
% filename8='C:\Users\Zack\Desktop\econmeeting\eg_2'
% m1=mean(SV_NOF.g_o(t1:t2,:),2)';
% s1=std(SV_NOF.g_o(t1:t2,:)');
% m2=mean(SV_OF.g_o(t1:t2,:),2)';
% s2=std(SV_OF.g_o(t1:t2,:)');
% for i=1:3
%     boundedline([t1:t2], [m1], s1, 'alpha','cmap', rgb('cerise'));
%     boundedline([t1:t2], [m2], s2, 'alpha','cmap', rgb('cerulean'));
% end
% hold on
% plot(t1:t2,SV_NOF.g_I(t1:t2),'color',rgb('cerise'),'linewidth',2)
% plot(t1:t2,SV_OF.g_I(t1:t2),'color',rgb('cerulean'),'linewidth',2)
% xlim([t1 t2]); xlabel('time')
% hTitle=title('')
% hLegend = legend('Own NOF','Inv. NOF','Own OF','Inv. OF');
% hXLabel = xlabel('time (yr)');
% hYLabel = ylabel('exp. cap gains')
% set( gca                       , ...
%     'FontName'   , 'Helvetica' );
% set([hTitle, hXLabel, hYLabel], ...
%     'FontName'   , 'Helvetica');
% set([hLegend, gca]             , ...
%     'FontSize'   , 12           );
% set([hXLabel, hYLabel]  , ...
%     'FontSize'   , 14          );
% set( hTitle                    , ...
%     'FontSize'   , 14          , ...
%     'FontWeight' , 'bold'      );
% set(gca, ...
%     'Box'         , 'off'     , ...
%     'TickDir'     , 'out'     , ...
%     'TickLength'  , [.015 .015] , ...
%     'XMinorTick'  , 'on'      , ...
%     'YMinorTick'  , 'on');
% set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
% set(gcf, 'PaperSize', [5 5]); 
% print('-dpdf','-painters',filename8)
% 
% 
% 
% 
% close all
% filename9='C:\Users\Zack\Desktop\econmeeting\uc_2'
% m1=mean(SV.oUC_NOF(t1:t2,:),2)';
% s1=std(SV.oUC_NOF(t1:t2,:)');
% m2=mean(SV.oUC_OF(t1:t2,:),2)';
% s2=std(SV.oUC_OF(t1:t2,:)');
% boundedline([t1:t2], [m1], s1, 'alpha','cmap', rgb('cerise'));
% boundedline([t1:t2], [m2], s2, 'alpha','cmap', rgb('cerulean'));
% hold on
% plot(t1:t2,SV.iUC_NOF(t1:t2),'color',rgb('cerise'),'linewidth',2)
% plot(t1:t2,SV.iUC_OF(t1:t2),'color',rgb('cerulean'),'linewidth',2)
% ylabel('user cost')
% xlim([t1 t2])
% hTitle=title('')
% hLegend = legend('Own NOF','Inv. NOF','Own OF','Inv. OF');
% hXLabel = xlabel('time (yr)');
% hYLabel = ylabel('user cost')
% set( gca                       , ...
%     'FontName'   , 'Helvetica' );
% set([hTitle, hXLabel, hYLabel], ...
%     'FontName'   , 'Helvetica');
% set([hLegend, gca]             , ...
%     'FontSize'   , 12           );
% set([hXLabel, hYLabel]  , ...
%     'FontSize'   , 14          );
% set( hTitle                    , ...
%     'FontSize'   , 14          , ...
%     'FontWeight' , 'bold'      );
% set(gca, ...
%     'Box'         , 'off'     , ...
%     'TickDir'     , 'out'     , ...
%     'TickLength'  , [.015 .015] , ...
%     'XMinorTick'  , 'on'      , ...
%     'YMinorTick'  , 'on');
% set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
% set(gcf, 'PaperSize', [5 5]); 
% print('-dpdf','-painters',filename9)




% 
% 
% 
% clear all; close all
% 
% cd C:\Users\Zack\Desktop\temp_figs
% load run1
% t1=2;
% var1=2;
% var2=12;
% var3=17;
% 
% x(:,1)=X_NOF.price(t1:t2);             % 1  NOF price
% x(:,2)=X_OF.price(t1:t2);              % 2  OF  price
% x(:,3)=MMT.netben(t1:t2,1);            % 3  NOF netben
% x(:,4)=MMT.netben(t1:t2,2);            % 4  OF  netben
% x(:,5)=wtp_all(t1:t2,1);               % 5  NOF wtp
% x(:,6)=wtp_all(t1:t2,2);               % 6  OF  wtp
% x(:,7)=X_NOF.mkt(t1:t2);               % 7  NOF mkt
% x(:,8)=X_OF.mkt(t1:t2);                % 8  OF  mkt
% x(:,9)=A_NOF.tau_prop(t1:t2);          % 9  NOF tauprop
% x(:,10)=A_OF.tau_prop(t1:t2);          % 10 OF  tauprop
% x(:,11)=mean(SV_NOF.rp_o(t1:t2,:),2)'; % 11 NOF risk
% x(:,12)=mean(SV_OF.rp_o(t1:t2,:),2)';  % 12 OF  risk
% x(:,13)=mean(SV_NOF.g_o(t1:t2,:),2)';  % 13 NOF cap gain
% x(:,14)=mean(SV_OF.g_o(t1:t2,:),2)';   % 14 OF  cap gain 
% x(:,15)=mean(SV.oUC_NOF(t1:t2,:),2)';  % 15 NOF Ouc
% x(:,16)=mean(SV.oUC_OF(t1:t2,:),2)';   % 16 OF  Ouc
% % x(:,17)=ACOM.Ebw(t1:t2);             % 17 beach width
% x(:,17)=MMT.bw(t1:t2);                 % 17 beach width
% x(:,18)=ACOM.Edh(t1:t2);               % 18 dune height
% 
% subplot(1,2,2)
% plot3(x(:,var1),x(:,var2),x(:,var3),'b')
% hold on
% plot3(x(1,var1),x(1,var2),x(1,var3),'go','markerfacecolor','g')
% 
% load run4
% t1 = 2;
% x(:,1)=X_NOF.price(t1:t2);             % 1  NOF price
% x(:,2)=X_OF.price(t1:t2);              % 2  OF  price
% x(:,3)=MMT.netben(t1:t2,1);            % 3  NOF netben
% x(:,4)=MMT.netben(t1:t2,2);            % 4  OF  netben
% x(:,5)=wtp_all(t1:t2,1);               % 5  NOF wtp
% x(:,6)=wtp_all(t1:t2,2);               % 6  OF  wtp
% x(:,7)=X_NOF.mkt(t1:t2);               % 7  NOF mkt
% x(:,8)=X_OF.mkt(t1:t2);                % 8  OF  mkt
% x(:,9)=A_NOF.tau_prop(t1:t2);          % 9  NOF tauprop
% x(:,10)=A_OF.tau_prop(t1:t2);          % 10 OF  tauprop
% x(:,11)=mean(SV_NOF.rp_o(t1:t2,:),2)'; % 11 NOF risk
% x(:,12)=mean(SV_OF.rp_o(t1:t2,:),2)';  % 12 OF  risk
% x(:,13)=mean(SV_NOF.g_o(t1:t2,:),2)';  % 13 NOF cap gain
% x(:,14)=mean(SV_OF.g_o(t1:t2,:),2)';   % 14 OF  cap gain 
% x(:,15)=mean(SV.oUC_NOF(t1:t2,:),2)';  % 15 NOF Ouc
% x(:,16)=mean(SV.oUC_OF(t1:t2,:),2)';   % 16 OF  Ouc
% % x(:,17)=ACOM.Ebw(t1:t2);               % 17 beach width
% x(:,17)=MMT.bw(t1:t2);               % 17 beach width
% x(:,18)=ACOM.Edh(t1:t2);               % 18 dune height
% plot3(x(:,var1),x(:,var2),x(:,var3),'r')
% plot3(x(1,var1),x(1,var2),x(1,var3),'go','markerfacecolor','g')
% 
% xlabel('price')
% ylabel('risk premium')
% zlabel('beach width')
% title('constant forcing vs SLR')
% 
% load run1
% t1=2;
% var1=2;
% var2=12;
% var3=17;
% 
% x(:,1)=X_NOF.price(t1:t2);             % 1  NOF price
% x(:,2)=X_OF.price(t1:t2);              % 2  OF  price
% x(:,3)=MMT.netben(t1:t2,1);            % 3  NOF netben
% x(:,4)=MMT.netben(t1:t2,2);            % 4  OF  netben
% x(:,5)=wtp_all(t1:t2,1);               % 5  NOF wtp
% x(:,6)=wtp_all(t1:t2,2);               % 6  OF  wtp
% x(:,7)=X_NOF.mkt(t1:t2);               % 7  NOF mkt
% x(:,8)=X_OF.mkt(t1:t2);                % 8  OF  mkt
% x(:,9)=A_NOF.tau_prop(t1:t2);          % 9  NOF tauprop
% x(:,10)=A_OF.tau_prop(t1:t2);          % 10 OF  tauprop
% x(:,11)=mean(SV_NOF.rp_o(t1:t2,:),2)'; % 11 NOF risk
% x(:,12)=mean(SV_OF.rp_o(t1:t2,:),2)';  % 12 OF  risk
% x(:,13)=mean(SV_NOF.g_o(t1:t2,:),2)';  % 13 NOF cap gain
% x(:,14)=mean(SV_OF.g_o(t1:t2,:),2)';   % 14 OF  cap gain 
% x(:,15)=mean(SV.oUC_NOF(t1:t2,:),2)';  % 15 NOF Ouc
% x(:,16)=mean(SV.oUC_OF(t1:t2,:),2)';   % 16 OF  Ouc
% % x(:,17)=ACOM.Ebw(t1:t2);             % 17 beach width
% x(:,17)=MMT.bw(t1:t2);                 % 17 beach width
% x(:,18)=ACOM.Edh(t1:t2);               % 18 dune height
% subplot(121)
% plot3(x(:,var1),x(:,var2),x(:,var3),'b')
% hold on
% plot3(x(1,var1),x(1,var2),x(1,var3),'go','markerfacecolor','g')
% 
% load run2
% t1 = 2;
% x(:,1)=X_NOF.price(t1:t2);             % 1  NOF price
% x(:,2)=X_OF.price(t1:t2);              % 2  OF  price
% x(:,3)=MMT.netben(t1:t2,1);            % 3  NOF netben
% x(:,4)=MMT.netben(t1:t2,2);            % 4  OF  netben
% x(:,5)=wtp_all(t1:t2,1);               % 5  NOF wtp
% x(:,6)=wtp_all(t1:t2,2);               % 6  OF  wtp
% x(:,7)=X_NOF.mkt(t1:t2);               % 7  NOF mkt
% x(:,8)=X_OF.mkt(t1:t2);                % 8  OF  mkt
% x(:,9)=A_NOF.tau_prop(t1:t2);          % 9  NOF tauprop
% x(:,10)=A_OF.tau_prop(t1:t2);          % 10 OF  tauprop
% x(:,11)=mean(SV_NOF.rp_o(t1:t2,:),2)'; % 11 NOF risk
% x(:,12)=mean(SV_OF.rp_o(t1:t2,:),2)';  % 12 OF  risk
% x(:,13)=mean(SV_NOF.g_o(t1:t2,:),2)';  % 13 NOF cap gain
% x(:,14)=mean(SV_OF.g_o(t1:t2,:),2)';   % 14 OF  cap gain 
% x(:,15)=mean(SV.oUC_NOF(t1:t2,:),2)';  % 15 NOF Ouc
% x(:,16)=mean(SV.oUC_OF(t1:t2,:),2)';   % 16 OF  Ouc
% % x(:,17)=ACOM.Ebw(t1:t2);               % 17 beach width
% x(:,17)=MMT.bw(t1:t2);               % 17 beach width
% x(:,18)=ACOM.Edh(t1:t2);               % 18 dune height
% plot3(x(:,var1),x(:,var2),x(:,var3),'r')
% plot3(x(1,var1),x(1,var2),x(1,var3),'go','markerfacecolor','g')
% 
% title('constant forcing')
% xlabel('price')
% ylabel('risk premium')
% zlabel('beach width')
% 
% 
% close all
% var1=8;
% var2=16;
% var3=17;
% 
% plot3(x(:,var1),x(:,var2),x(:,var3),'k')
% hold on
% plot3(x(1,var1),x(1,var2),x(1,var3),'go','markerfacecolor','g')
% plot3(x(end,var1),x(end,var2),x(end,var3),'ro','markerfacecolor','r')
% 
% close all
% plot(x(:,var1),x(:,var2),'k')
% hold on
% plot(x(1,var1),x(1,var2),'go','markerfacecolor','g')
% plot(x(end,var1),x(end,var2),'ro','markerfacecolor','r')
% 
% 
% var1=4;
% [v,lag]=ami(x(:,var1),x(:,var1),[1:20]);
% plot(lag,v)
% [X]=delay_embed(x(:,var1),3,4);
% 
% close all
% plot3(X(:,1),X(:,2),X(:,3),'k.')
% 
% close all
% plot(X(:,1),X(:,2))
% 