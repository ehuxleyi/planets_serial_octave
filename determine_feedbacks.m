% script to set the intrinsic feedback properties for a planet
% 
% This is done by defining the sign and strength of combined feedback
% (individual feedbacks are not represented, only the effect from of all of
% them acting together). Feedbacks need to be defined for all temperature
% values across the habitable range. Here this is implemented by randomly
% allocating a number of nodes to the planet, then randomly determining the
% strengths of the feedbacks at those nodes. Feedback values at
% intermediate temperatures (between nodes) are calculated subsequently (in
% 'planets_ODE') by linear interpolation
%--------------------------------------------------------------------------

% determine how many separate nodes there are for this planet (on the dT/dt
% vs T graph). 'r1' contains random numbers (uniform distribution, 0 to 1)
nnodes = 2 + floor((nnodes_max-1)*r1(ii));    % between 2 and 20
Tgap   = Trange / (nnodes-1.0);               % distance between nodes

% give each node a random feedback strength, either warming or cooling
for nn = 1:nnodes
    % distribute nodes evenly across the temperature range
    Tnodes(nn) = Tmin + Tgap*(nn-1);
    % feedback strengths follow a normal (Gaussian) distribution
    % distribution centred on zero. 'r2' contains random numbers, this time
    % from a normal distribution with mean of 0 and standard dev. of 1
    Tfeedbacks(nn) = r2(ii,nn) * fsd;  % mean=0, sigma=fsd
end

% to enable successful plotting, fill in any gaps at the end with
% duplicates of the last point
for nn = (nnodes+1):nnodes_max
    Tnodes(nn) = NaN;
    Tfeedbacks(nn) = Tfeedbacks(nnodes);
end
