% script to calculate the locations of any zones of runaway feedback
% 
% These occur if the combination of processes leads to the planet getting
% even warmer when temperatures are in the vicinity of the upper limit to
% habitability (runaway greenhouse), or to overall cooling in the vicinity
% of the lower boundary (runaway icehouse)
%--------------------------------------------------------------------------


%% calculate the extent of the zone of runaway cooling, if there is one

% icehT = threshold temperature for initiation of runaway icehouse
icehT = Tmin;

% at the cold end of the habitable envelope, there can only be a runaway
% feedback to sterility if the first (left-most) node has negative dT/dt
% (tendency for the system to get even colder when already nearly too cold)
if (feedbacks(1) < 0.0)
    % find the first x-axis intercept (temperature at which the tendency is
    % no longer to get cooler over time)
    intercept_found = 0;
    nn = 2;    
    while ((intercept_found == 0) && (nn <= nnodes))
        if (feedbacks(nn) > 0.0)
            xintercept = Tnodes(nn-1) + ...
                (Tgap*(0.0-feedbacks(nn-1) / ...
                (feedbacks(nn)-feedbacks(nn-1))));
            intercept_found = 1;
        end
        nn = nn + 1;
    end
    if (intercept_found == 0)
        % the case where there is no +ve node
        xcs_icehouse = [Tnodes(1) Tnodes(1:nnodes) Tnodes(nnodes)];
        ycs_icehouse = [0 feedbacks(1:nnodes) 0];
        icehT = Tmax;
    else
        xcs_icehouse = [Tnodes(1) Tnodes(1:(nn-2)) xintercept];
        ycs_icehouse = [0 feedbacks(1:(nn-2)) 0];
        icehT = xintercept;
    end
end
if (icehT == Tmin)
    icehT = NaN;   % do not plot if there is no zone of runaway feedback
end


%% calculate the extent of the zone of runaway warming, if there is one

% greenhT = threshold temperature for initiation of runaway greenhouse
greenhT = Tmax;

% at the warm end of the habitable envelope, there can only be a runaway
% feedback to sterility if the last (right-most) node has positive dT/dt
% (tendency for the system to get even warmer when already nearly too warm)
if (feedbacks(nnodes) > 0.0)
    intercept_found = 0;
    nn = nnodes;
    % find the last x-axis intercept (temperature at which the tendency is
    % no longer to get warmer over time)
    while ((intercept_found == 0) && (nn > 0))
        if (feedbacks(nn) < 0.0)
            xintercept = Tnodes(nn) + ...
                (Tgap*(0-feedbacks((nn)) / ...
                (feedbacks(nn+1)-feedbacks((nn)))));
            intercept_found = 1;
            nn = nn - 1;
        else
            nn = nn - 1;
        end;
    end
    if (intercept_found == 0)
        % the case where there is no -ve node
        xcs_greenhouse = [Tnodes(1) Tnodes(1:nnodes) Tnodes(nnodes)];
        ycs_greenhouse = [0 feedbacks(1:nnodes) 0];
        greenhT = Tmin;
    else
        xcs_greenhouse = [Tnodes(nnodes) Tnodes(nnodes:-1:(nn+1)) xintercept];
        ycs_greenhouse = [0 feedbacks(nnodes:-1:(nn+1)) 0];
        greenhT = xintercept;
    end
end
if (greenhT == Tmax)
    greenhT = NaN;   % do not plot if there is no zone of runaway feedback
end
