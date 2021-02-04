function [bw,nourish_xshore,nourish_yr,mbw]=evaluate_nourishment_future_beach_width(n_interval,E,X,M)

t                  = X.time;
t_horiz            = E.expectation_horizon+1;
bw                 = zeros(t_horiz,1);
nourishplan_last   = X.nourishtime(t+1:t+t_horiz);
nourishplan_new    = zeros(t_horiz,1);
n                  = 1:n_interval:t_horiz; 
nourishplan_new(n) = 1 ;
nourish_count      = nourishplan_last+nourishplan_new;
nourish_xshore     = zeros(1,t_horiz);
bw(1)              = E.x0;

for time = 2:t_horiz
    if nourish_count(time) == 1 & time < t_horiz
        bw(time)             = E.x0;
        nourish_xshore(time) = E.x0-(bw(time-1)-X.er(t));
    else if nourish_count(time) == 2
            bw(time) = E.x0;
        else
            bw(time) = bw(time-1)-X.er(t);
        end
    end
end

nourish_xshore(1) = E.x0-X.bw(t);  % amount during first nourishment
bw(bw<0)          = 0;
nourish_yr        = find(bw==E.x0)';
nourish_xshore    = nourish_xshore(nourish_yr);
mbw               = mean(bw);