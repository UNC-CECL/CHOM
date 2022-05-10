
fsize_title   = 7;
fontsize_axes = 7;
fsize_label   = 7;
fsize_legend  = 7;

t1=2;
t2=M.T-1;
%%%% CAP GAINS
for ii = t1:t2
    go_OF(ii)  = median(SV_OF.g_o(ii,:));
    go_NOF(ii) = median(SV_NOF.g_o(ii,:));
end
L           = 30;
go_OF(1:L)  = NaN;
go_NOF(1:L) = NaN;

for ti=t1:t2
    NOFrpO(ti)  = mean(SV_NOF.riskO{ti});
    NOFrpR(ti)  = mean(SV_NOF.riskR{ti});
    OFrpO(ti)   = mean(SV_OF.riskO{ti});
    OFrpR(ti)   = mean(SV_OF.riskR{ti});
    NOFtauO(ti) = mean(SV_NOF.tau_incO{ti});
    NOFtauR(ti) = mean(SV_NOF.tau_incR{ti});
    OFtauO(ti)  = mean(SV_OF.tau_incO{ti});
    OFtauR(ti)  = mean(SV_OF.tau_incR{ti});
end

pos1 = [0.13   0.77   0.775   0.2];
pos2 = [0.13   0.55   0.775   0.2];
pos3 = [0.13   0.3   0.375   0.2];
pos4 = [0.53   0.3   0.375   0.2];
pos5 = [0.13   0.07   0.375   0.2];
pos6 = [0.53   0.07   0.375   0.2];

figure1          = gcf;
figure1.Units    = 'Inches';
figure1.Position = [.5 4 7.4 5.5];

% [left bottom width height].

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% PRICES
%%%%%%%%%%%%%%%%%%%%%%%%
ax1=subplot('Position',pos1)
ax1.Units='Inches';
set(ax1.YAxis,{'Color'},{'k'})
line1 = line(t1:t2,X_OF.price(t1:t2)/1000,...
    'LineWidth',2,...
    'Color',[rgb('ocean blue')]);
line2 = line(t1:t2,X_NOF.price(t1:t2)/1000,...
    'LineWidth',2,...
    'Color',rgb('rust orange'));
set(ax1,'XMinorTick','on','YMinorTick','on')

y1val=[X_OF.price(t1:t2)/1000, X_NOF.price(t1:t2)/1000];
y1val=y1val(:);
y1max=max(y1val);
y1min=min(y1val);
y1range=y1max-y1min;
% ylim([y1min-0.2*y1range y1max+0.4*y1range])
ylim([0 y1max+0.4*y1range])

yyaxis right
set(ax1,'XMinorTick','off','YMinorTick','on')
ax1.YAxis(2).TickLabel=[];
set(ax1.YAxis,{'Color'},{'k'})
tobj1=title('(a) Property Value, $\times1000','FontName','Helvetica','FontSize',fsize_title);
tobj1.Units='Inches';
tobj1.HorizontalAlignment='left'
tobj1.VerticalAlignment='cap'
tobj1.Position(1)=0.15
tobj1.Position(2)=1.1
legend_1 = legend('Oceanfront',...
    'Non-Oceanfront','fontsize',fsize_legend);
legend_1.Box = 'off';
legend_1.Orientation='horizontal'
legend_1.Location='northeast'
legend_1.Position(2)=0.94
%     xticks([])
%     xticklabels({})
xticks([81])
xticklabels({''})
xlim([t1 t2])
set(ax1.YAxis,'fontsize',fontsize_axes,'FontName','Helvetica')
ax1.XGrid = 'on';

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Beach Width
%%%%%%%%%%%%%%%%%%%%%%%%
ax2=subplot('Position',pos2)
ax2.Units='Inches';
set(ax2,'YMinorTick','on')
set(ax2.YAxis,{'Color'},{'k'})
line1 = line(t1:t2,MMT.bw(t1:t2),'linestyle','-',...
    'LineWidth',1,...
    'Color',[0 0 0]);
line2 = line(t1:t2,ACOM.Ebw(t1:t2),...
    'LineWidth',2,'linestyle','-.',...
    'Color',[0 0 0]);

y2val=[MMT.bw(t1:t2) ACOM.Ebw(t1:t2)];
y2val=y2val(:);
y2max=max(y2val);
y2min=min(y2val);
y2range=y2max-y2min;
ylim([y2min-0.2*y2range y2max+0.6*y2range])
yyaxis right
set(ax2,'YMinorTick','on')
ax2.YAxis(2).TickLabel=[];
set(ax2.YAxis,{'Color'},{'k'})
tobj2=title('(b) Beach Width, m','FontName','Helvetica','FontSize',fsize_title);
tobj2.Units='Inches';
tobj2.HorizontalAlignment='left'
tobj2.VerticalAlignment='cap'
tobj2.Position(1)=0.15
tobj2.Position(2)=1.1
legend_2 = legend('Beach Width',...
    'Expected Beach Width','fontsize',fsize_legend);
legend_2.Box = 'off';
legend_2.Orientation='horizontal';
legend_2.Location='northeast';
legend_2.Position(2)=0.72
xticks([t1 81 t2])
xticklabels({'1','','200'})
xlabel2 = xlabel(...
    'Time (years)',...
    'FontName','Helvetica',...
    'FontSize',fsize_label);
xlabel2.Units='Inches';
xlabel2.Position(2)=-0.025
xlim([t1 t2])
set(ax2.YAxis,'fontsize',fontsize_axes,'FontName','Helvetica')
set(ax2.XAxis,'fontsize',fontsize_axes,'FontName','Helvetica')
ax2.XGrid = 'on';

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Market Share
%%%%%%%%%%%%%%%%%%%%%%%%
ax3=subplot('Position',pos3)
set(ax3,'YMinorTick','on')
set(ax3.YAxis,{'Color'},{'k'})    % use sedate color...
grid on
line1 = line(t1:t2,100*X_OF.mkt(t1:t2),...
    'LineWidth',2,...
    'Color',rgb('ocean blue'));
line2 = line(t1:t2,100*X_NOF.mkt(t1:t2),...
    'LineWidth',2,...
    'Color',rgb('rust orange'));
total_market=(ACOM.n_NOF*X_NOF.mkt+ACOM.n_OF*X_OF.mkt)/ACOM.n_agent_total;
line3=line(t1:t2,total_market(t1:t2)*100,'linewidth',.5,'Color',[0 0 0])
ylim([0 125])
yyaxis right
set(ax3,'YMinorTick','on')
ax3.YAxis(2).TickLabel=[];        % don't show labels on LH axis
set(ax3.YAxis,{'Color'},{'k'})
tobj3=title('(c) Investor Share Housing, pct.','FontName','Helvetica','FontSize',fsize_title);
tobj3.Units='Inches';
tobj3.HorizontalAlignment='left'
tobj3.VerticalAlignment='cap'
tobj3.Position(1)=0.15
tobj3.Position(2)=1.05
xticks([81])
xticklabels({''})
xlim([t1 t2])
set(ax3.YAxis,'fontsize',fontsize_axes,'FontName','Helvetica')
ax3.XGrid = 'on';
ax3.YGrid = 'off';

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Income
%%%%%%%%%%%%%%%%%%%%%%%%
ax4=subplot('Position',pos4)
set(ax4,'YMinorTick','on')
yyaxis right
set(ax4,'YMinorTick','on')
ax4.YAxis(1).TickLabel=[];        % don't show labels on LH axis
set(ax4.YAxis,{'Color'},{'k'})    % use sedate color...
line1 = line(t1:t2,100*OFtauO(t1:t2),...
    'LineWidth',2,...
    'Color',[rgb('ocean blue')]);
line2 = line(t1:t2,100*NOFtauO(t1:t2),...
    'LineWidth',2,...
    'Color',rgb('rust orange'));
line3 = line(t1:t2,100*OFtauR(t1:t2),'linestyle',':',...
    'LineWidth',1,...
    'Color',[rgb('ocean blue')]);
line4 = line(t1:t2,100*NOFtauR(t1:t2),'linestyle',':',...
    'LineWidth',1,...
    'Color',rgb('rust orange'));
y4val=100*[NOFtauR(t1:t2) OFtauR(t1:t2) NOFtauO(t1:t2) OFtauO(t1:t2)];
y4max=max(y4val);
y4min=min(y4val);
y4range=y4max-y4min;
ylim([y4min-0.1*y4range y4max+0.4*y4range])
tobj4=title('(e) Income Tax Rate, pct.','FontName','Helvetica','FontSize',fsize_title);
tobj4.Units='Inches';
tobj4.HorizontalAlignment='left'
tobj4.VerticalAlignment='cap'
tobj4.Position(2)=1.05
xticks([81])
xticklabels({''})
xlim([t1 t2])
set(ax4.YAxis,'fontsize',fontsize_axes,'FontName','Helvetica')
ax4.XGrid = 'on';
ax4.YGrid = 'off';
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Cap Gains
%%%%%%%%%%%%%%%%%%%%%%%%
ax5=subplot('Position',pos5)
set(ax5,'YMinorTick','on')
set(ax5.YAxis,{'Color'},{'k'})    % use sedate color...

line1 = line(t1:t2,100*go_OF(t1:t2),...
    'LineWidth',2,...
    'Color',[rgb('ocean blue')]);
line2 = line(t1:t2,100*go_NOF(t1:t2),...
    'LineWidth',2,...
    'Color',rgb('rust orange'));
y5val=100*[go_OF(t1:t2) go_NOF(t1:t2)];
y5max=max(y5val);
y5min=min(y5val);
y5range=y5max-y5min;
ylim([y5min-0.1*y5range y5max+0.4*y5range])
xlabel1 = xlabel(...
    'Time (years)',...
    'FontName','Helvetica',...
    'FontSize',fsize_label);
yyaxis right
set(ax5,'YMinorTick','on')
ax5.YAxis(2).TickLabel=[];        % don't show labels on LH axis
set(ax5.YAxis,{'Color'},{'k'})
tobj5=title('(d) Expected Return Rate, pct.','FontName','Helvetica','FontSize',fsize_title);
tobj5.Units='Inches';
tobj5.HorizontalAlignment='left'
tobj5.VerticalAlignment='cap'
tobj5.Position(1)=0.15
tobj5.Position(2)=1.05
xticks([t1 81 t2])
xticklabels({'1','','200'})
xlabel5 = xlabel(...
    'Time, years',...
    'FontName','Helvetica',...
    'FontSize',fsize_label);
xlabel5.Units='Inches';
xlabel5.Position(2)=-0.025
xlim([t1 t2])
set(ax5.YAxis,'fontsize',fontsize_axes,'FontName','Helvetica')
set(ax5.XAxis,'fontsize',fontsize_axes,'FontName','Helvetica')
ax5.XGrid = 'on';
ax5.YGrid = 'off';
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Risk
%%%%%%%%%%%%%%%%%%%%%%%%
ax6=subplot('Position',pos6)
set(ax6,'YMinorTick','on')
yyaxis right
set(ax6,'YMinorTick','on')
ax6.YAxis(1).TickLabel=[];        % don't show labels on LH axis
set(ax6.YAxis,{'Color'},{'k'})    % use sedate color...
line1 = line(t1:t2,100*OFrpO(t1:t2),...
    'LineWidth',2,...
    'Color',[rgb('ocean blue')]);
line2 = line(t1:t2,100*NOFrpO(t1:t2),...
    'LineWidth',2,...
    'Color',rgb('rust orange'));
line3 = line(t1:t2,100*OFrpR(t1:t2),'linestyle',':',...
    'LineWidth',1,...
    'Color',[rgb('ocean blue')]);
line4 = line(t1:t2,100*NOFrpR(t1:t2),'linestyle',':',...
    'LineWidth',1,...
    'Color',rgb('rust orange'));

y6val=100*[OFrpO(t1:t2) NOFrpO(t1:t2) OFrpR(t1:t2) NOFrpR(t1:t2)];
y6max=max(y6val);
y6min=min(y6val);
y6range=y6max-y6min;
ylim([y6min-0.2*y6range y6max+0.4*y6range])

tobj6=title('(f) Risk Premium Rate, pct.','FontName','Helvetica','FontSize',fsize_title);
tobj6.Units='Inches';
tobj6.HorizontalAlignment='left'
tobj6.VerticalAlignment='cap'
tobj6.Position(1)=1.28
tobj6.Position(2)=1.05
xticks([t1 81 t2])
xticklabels({'1','','200'})
xlabel6 = xlabel(...
    'Time, years',...
    'FontName','Helvetica',...
    'FontSize',fsize_label);
xlabel6.Units='Inches';
xlabel6.Position(2)=-0.025
xlim([t1 t2])
set(ax6.YAxis,'fontsize',fontsize_axes,'FontName','Helvetica')
set(ax6.XAxis,'fontsize',fontsize_axes,'FontName','Helvetica')
ax6.XGrid = 'on';
ax6.YGrid = 'off';

figure1 = gcf;
set(figure1, 'PaperPosition', [0 0 7.4/1.1 5.5/1.1]); %Position plot at left hand corner with width 5 and height 5.
set(figure1, 'PaperSize', [7.4/1.1 5.5/1.1]);

savefigurename='C:\Users\Zack\Desktop\WB_sim'
%     print('-dpng','-r500','-painters',savefigurename)
%
%
%

