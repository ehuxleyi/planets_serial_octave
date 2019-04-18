% function defining the central ODE (for dT/dt) of the model
% 
% this function sets out how to calculate the rate of change of planetary
% surface temperature over time (dT/dt) at a given temperature (T),
% depending also on the planet's feedbacks and long-term forcing (which is
% a function of time)
% 
% *******
% Note that planets_ODE and planets_jac go as a pair: changes to one should
% be matched with changes to the other
% ******* 
%--------------------------------------------------------------------------

function [out] = planets_ODE(time, in)

% some variables are made global because difficult to pass as arguments 
global Tmin Tmax Tgap Tnodes nnodes Tfeedbacks trend

% T = current temperature
T = in(1);
out = in;
      
% ----- Differential equation -----

% the value of dT/dt (rate of change of planetary temperature over time)
% depends on the planetary temperature. The value of dT/dt at any precise
% value of T is interpolated between specified values at regular intervals

% work out which 'nodes' this particular value of T is between
node_bef = 1 + floor((T-Tmin)/Tgap);
node_aft = 1 + ceil((T-Tmin)/Tgap);
if (node_bef < 1)
    node_bef = 1;
elseif (node_bef > nnodes)
    node_bef = nnodes;
end
if (node_aft < 1)
    node_aft = 1;
elseif (node_aft > nnodes)
    node_aft = nnodes;
end

% if T is outside the habitable range ...
if ((T < Tmin) || (T > Tmax))
    out(1) = 0.0;       % ... doesn't matter anymore
    
    % if T is exactly at a node, then use the feedback value for that node
elseif (node_bef == node_aft)
    % add the feedbacks and the effect of the trend over time (e.g. due to
    % increasing solar luminosity)
    out(1) = Tfeedbacks(node_aft) + (trend * (time/1e6));
    
    % else if T is between nodes then calculate dT/dt by interpolation
else
    % calculate weightings for dT/dt at nodes before and after T
    weight_bef = (Tnodes(node_aft)-T) / Tgap;
    weight_aft = (T-Tnodes(node_bef)) / Tgap;
    % linear interpolation between dT/dt values at the two nodes
    temp = (Tfeedbacks(node_bef)*weight_bef) + ...
        (Tfeedbacks(node_aft)*weight_aft);
    % add the feedbacks and the effect of the trend over time (e.g. due to
    % increasing solar luminosity)
    out(1) = temp + (trend * (time/1e6));
end

out(2) = 0.0;
