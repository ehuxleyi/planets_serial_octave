% script to set the random perturbations for a run
% 
% The perturbations are near-instantaneous changes to the planet's surface
% temperature. Over billions of years, many external and internal events
% can lead to temporary perturbations to the planet's temperature. Examples
% include the impacts of comets and asteroids, supernovas, volcanic  
% eruptions, outpourings of large amounts of basalt and stellar flares.
% 
% This is implemented by adding together three clases of perturbations: 
% (1) frequent minor ones (amplitude chosen randomly from a normal
%     distribution with mean 2 deg C and standard deviation 1 deg C)
% (2) occasional moderate ones (amplitude chosen randomly from a normal
%     distribution with mean 8 deg C and standard deviation 4 deg C), and
% (3) very infrequent major ones (amplitude chosen randomly from a normal
%     distribution with mean 32 deg C and standard deviation 16 deg C)
% If two perturbations of different magnitudes occur simultaneously, the
% smaller one is ignored. All perturbations are equally likely to be
% positive or negative.
%--------------------------------------------------------------------------

% use random numbers from a Poisson distribution to calculate the numbers
% of actual perturbations in each magnitude class. This is numerically
% identical to, but computationally far more efficient than, going through
% each time period one by one (there are 3 million ky) and calculating if
% there are any perturbations in that ky
bpcounter = poissrnd(lambda_big,1,1);
mpcounter = poissrnd(lambda_mid,1,1);
lpcounter = poissrnd(lambda_little,1,1);

pcounter = bpcounter + mpcounter + lpcounter;

% set up an array to hold the information about the perturbations
perturbations = double(zeros([pcounter 2]));

max_perturbation = 0.0;

% for each major perturbation
for ppp = 1:bpcounter
    ptime = rand * max_duration;    % equal prob to occur at any time
    magnitude = normrnd(bigp_mean, bigp_std);     % degrees C
    sign = round(rand)*2 - 1;  % randomly an increase or a decrease
    perturbations(ppp, 1) = ptime;              % store time...
    perturbations(ppp, 2) = magnitude * sign;    % ...and severity
    % keep track of the size of the largest perturbation in this run
    if (magnitude > abs(max_perturbation))
        max_perturbation = perturbations(ppp, 2);
    end
end

% for each moderate perturbation
for ppp = (bpcounter+1):(bpcounter+mpcounter)
    ptime = rand * max_duration;    % equal prob to occur at any time
    magnitude = normrnd(midp_mean, midp_std);     % degrees C
    sign = round(rand)*2 - 1;  % randomly an increase or a decrease
    perturbations(ppp, 1) = ptime;              % store time...
    perturbations(ppp, 2) = magnitude * sign;    % ...and severity
    % keep track of the size of the largest perturbation in this run
    if (magnitude > abs(max_perturbation))
        max_perturbation = perturbations(ppp, 2);
    end
end

% for each little perturbation
for ppp = (bpcounter+mpcounter+1):pcounter
    ptime = rand * max_duration;    % equal prob to occur at any time
    magnitude = normrnd(littlep_mean, littlep_std);     % degrees C
    sign = round(rand)*2 - 1;  % randomly an increase or a decrease
    perturbations(ppp, 1) = ptime;              % store time...
    perturbations(ppp, 2) = magnitude * sign;    % ...and severity
    % keep track of the size of the largest perturbation in this run
    if (magnitude > abs(max_perturbation))
        max_perturbation = perturbations(ppp, 2);
    end
end

% sort the perturbations into chronological order
perturbations = sortrows(perturbations,1);
