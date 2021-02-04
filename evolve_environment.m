% 1) Evolve environmental variables (X.h_dune, X.bw)
% 2) tracking beach width with both bw, and bw_halftime.
%    bw_halftime makes sense when trying to plot bw through time
% 3) Update agents perceived erosion rate

function [X]=evolve_environment(F,X,A,E,M)

t = X.time;

% beach - nourish, evolve,record position at beginning and end of step
if X.nourishtime(t) == 1                  % if nourish is scheduled
    X.bw(t)            = E.x0;            % then reset the beach and
    X.bw_halftime(t,1) = X.bw(t);         % grab the height at the beginning of the time step and store it
    X.t_halftime(t,1)  = t;               % the time is t
    X.bw(t)            = X.bw(t)-F.ER(t); % so take nourishment that just happened, and erode it
    X.bw_halftime(t,2) = X.bw(t);         % and store the beach width after the erosion
    X.t_halftime(t,2)  = t+1;             % and store the time passed t + dt
else                                      % else just erode beach
    X.bw_halftime(t,1) = X.bw(t-1);       % grab the height at the beginning of the time step (i.e. height at the previous time step)
    X.t_halftime(t,1)  = t;               % don't allow beach width to be less than or equal to zero
    X.bw(t)            = X.bw(t-1)-F.ER(t); % erode the beach
    if X.bw(t)<=0
        X.bw(t) = 1;
    end
    X.bw_halftime(t,2) = X.bw(t);         % and grab the height at the beginning of the time step and store it
    X.t_halftime(t,2)  = t+1;
end

X.er(t) = (A.theta_er)*F.ER(t)+(1-A.theta_er)*X.er(t-1); % update the 'perceived' erosion. rate if weighting param A.theta_er = 0,
                                                         % then percieved erosion rate is equal to the real erosion rate.

% dunes - build, keep the same, wipeout due to storm
if X.builddunetime(t) == 1                % if dune build is scheduled
    X.h_dune(t) = M.duneheight_max;       % then build it back up
end

if X.builddunetime(t)==0
    if F.storms(t) > 7                    % for demonstration purposes only, if storm value greater than 5, then destoy dunes
        X.h_dune(t) = 1;
    else
        X.h_dune(t) = X.h_dune(t-1);      % or else keep them the same
    end
    if X.h_dune(t)<1                      % don't allow dunes to be less than 1
        X.h_dune(t) = 1;
    end
end








