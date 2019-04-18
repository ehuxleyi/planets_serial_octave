% script to calculate the number and nature of a planet's stable attractors

% Stable attractors emerge if a planet has a suitable set of climate
% feedbacks. A stable attractor occurs at a temperature Ts if the sum of
% feedbacks leads to net warming directly below Ts and net cooling directly
% above Ts

% The following properties are calculated for each attractor:
%   (1) location (temperature of zero crossing point),
%   (2) number of nearest node to left of the crossing point,
%   (3) number of nearest node to right of the crossing point,
%   (4) number of left-most node in the stable attractor,
%   (5) number of right-most node in it,
%   (6) highest dT/dt
%   (7) lowest dT/dt
%   (8) height (highest - lowest dT/dt),
%   (9) leftmost limit of attractor (lowest T from where it returns),
%   (10) rightmost limit of attractor (highest T from where it returns),
%   (11) width (T of next crossing point to the right - T of next crossing
%       point to the left). This is a measure of the range of planetary
%       temperatures over which the stable attractor will return the planet
%       towards the attractor point
%--------------------------------------------------------------------------

% reset all values
nattr = 0;
attr(~isnan(attr)) = NaN;  % reset to NaNs

% find all of the stable attractors. They occur at zero crossing points
% where the line crosses the dT/dt=0 axis with a negative gradient. They
% correspond to stable rather than unstable equilibria

% find x-axis intercepts from +ve to -ve (stable attr)
for kk = 2:nnodes
    if ((feedbacks(kk) < 0) && (feedbacks(kk-1) > 0))  % found an attractor
        nattr = nattr + 1;
        
        % calculate the location of the zero-crossing where this attractor
        % point is situated
        attr(nattr,1) = Tnodes(kk-1) + ...
            ((Tgap*feedbacks(kk-1)) / ...
             (feedbacks(kk-1)-feedbacks(kk)));
        
        % number of the preceding node
        attr(nattr,2) = kk - 1;
        
        % number of the following node
        attr(nattr,3) = kk;
        
        % go backwards in the node list until come to a -ve node or run out
        % of nodes
        mm = kk - 1;
        while ((mm > 1) && (feedbacks(mm-1) > 0))
            mm = mm - 1;
        end
        attr(nattr,4) = mm;
        
        % go forwards in the node list until come to a +ve node or run out
        % of nodes
        mm = kk;
        while ((mm < nnodes) && (feedbacks(mm+1) < 0))
            mm = mm+1;
        end
        attr(nattr,5) = mm;
        
        % find maximum positive feedback (must lie to the left of the
        % attractor point)
        max_adT = 0;
        for mm = attr(nattr,4):attr(nattr,2)
            if (feedbacks(mm) > max_adT)
                max_adT = feedbacks(mm);
            end
        end
        attr(nattr,6) = max_adT;
        
        % find minimum positive feedback (must lie to the right of the
        % attractor point)
        min_adT = 0;
        for mm = attr(nattr,3):attr(nattr,5)
            if (feedbacks(mm) < min_adT)
                min_adT = feedbacks(mm);
            end
        end
        attr(nattr,7) = min_adT;
        
        % calculate the height of this attractor.
        attr(nattr,8) = max_adT - min_adT;
        
        % find left limit to this attractor (i.e. the lowest temperature at
        % which the net feedback is still warming, i.e. will still return
        % the system back towards the attractor point)
        nn = attr(nattr,4);
        if (nn == 1)     % reached left-hand edge
            min_aT = Tmin;
        else      % there exists a node further to the left
            min_aT = Tnodes(nn) - ...
                (feedbacks(nn) * Tgap / (feedbacks(nn)-feedbacks(nn-1)));
        end
        attr(nattr,9) = min_aT;
        
        % find right limit to this attractor (i.e. the highest temperature
        % at which the net feedback is still cooling, i.e. will still
        % return the system back towards the attractor point)
        nn = attr(nattr,5);
        if (nn == nnodes)     % reached right-hand edge
            max_aT = Tmax;
        else      % there exists a node further to the left
            max_aT = Tnodes(nn) + ...
                ((-feedbacks(nn)) * Tgap / (feedbacks(nn+1)-feedbacks(nn)));
        end
        attr(nattr,10) = max_aT;
        
        % calculate the width of this attractor.
        attr(nattr,11) = max_aT - min_aT; 
    end
end

% copy to variables with clearer names
nattractors = nattr;   attractors = attr;
