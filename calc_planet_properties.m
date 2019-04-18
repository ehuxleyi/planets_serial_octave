% script to calculate some derived properties of a planet
%--------------------------------------------------------------------------

% calculate the number and properties of any stable attractors
feedbacks = Tfeedbacks;
calc_attractor_properties;

% calculate if there are any runaway feedback zones and, if so, their
% properties
calc_runaways;

% calculate the percentage of the habitable temperature range that
% is susceptible to a runaway icehouse or a runaway greenhouse positive
% feedback
if (isnan(icehT) && isnan(greenhT))
    pc_runaway = 0.0;
elseif isnan(icehT)
    pc_runaway = 100.0 * (Tmax-greenhT) / Trange;
elseif isnan(greenhT)
    pc_runaway = 100.0 * (icehT-Tmin) / Trange;    
else
    pc_runaway = 100.0 * ((icehT-Tmin) + (Tmax-greenhT)) / Trange;
end

% store planet information in a structure
planets(ii).nnodes = nnodes;       % number of nodes
planets(ii).nattractors = nattractors; % number of stable attractors
planets(ii).trend = trend;       % heating or cooling trend
planets(ii).lambda_big = lambda_big;       % perturbation expected Ns
planets(ii).lambda_mid = lambda_mid;
planets(ii).lambda_little = lambda_little;
% including coordinates of nodes
for qq = 1:nnodes_max
    planets(ii).Tnodes(qq) = NaN;
    planets(ii).Tfeedbacks(qq) = NaN;
end
for qq = 1:nnodes
    planets(ii).Tnodes(qq) = Tnodes(qq);
    planets(ii).Tfeedbacks(qq) = Tfeedbacks(qq);
end

% print out planet properties
if (verbose)
    fprintf('  number of nodes = %d\n', nnodes);
    fprintf('  number of attractors = %d\n', nattractors);
    if isnan(pc_runaway)
        pc_runaway = 0.0;
    end
    fprintf('  %d%% of habitable range occ. by runaway feedbacks\n', round(pc_runaway));
    if (icehT > Tmin)
        fprintf('  runaway cooling predicted below %.0f C\n', round(icehT));
    end
    if (greenhT < Tmax)
        fprintf('  runaway warming predicted above %.0f C\n', round(greenhT));
    end
    fprintf('  long-term forcing = %d (C ky-1) By-1\n', round(trend));
    fprintf('  expected number of large perturbations = %d \n', round(lambda_big));
    fprintf('  expected number of mid-sized perturbations = %d \n', round(lambda_mid));
    fprintf('  expected number of small perturbations = %d \n\n', round(lambda_little));
end
