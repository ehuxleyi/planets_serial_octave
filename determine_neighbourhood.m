% script to set some parameters characterising the planet's 'neighbourhood'
% 
% The neighbourhood is represented here only in terms of perturbation
% frequencies. Some factors potentially affecting those frequencies are:
%   (a) the type of galaxy that the planet is in (for instance the density
%       of stars in the galaxy affects how often nearby supernovae and GRBs
%       will occur)
%   (b) the position within the galaxy, for the same reason (stars are more
%       closely packed near the centre)
%   (c) the nature of the star that the planet orbits, such as whether
%       that star is prone to flares or superflares and if so how strong
%       and frequent they are
%   (d) the nature of the planetary system within which the planet is
%       located, including the numbers and orbital stabilities of asteroids
%       and comets
%   (e) the frequency with which rogue stars affect the planetary system
%   (f) the intensity of geological activity of the planet
% 
% The range of different neighbourhoods is implemented here by using
% random numbers to set "expected values" (lambda coefficients of a Poisson
% distribution) for each of the three clases of perturbation:
%   (1) frequent minor ones (amplitudes chosen randomly from a normal
%       distribution with mean 2 deg C and standard deviation 1 deg C)
%   (2) occasional moderate ones (amplitudes chosen randomly from a normal
%       distribution with mean 8 deg C and standard deviation 4 deg C), and
%   (3) very infrequent major ones (amplitudes chosen randomly from normal
%       distribution with mean 32 deg C and standard deviation 16 deg C)
%--------------------------------------------------------------------------
 
% use random numbers to determine this planet's "neighbourhood", or in
% other words to determine the expected numbers of perturbations in each
% magnitude class (frequency is made to decline with increasing magnitude:
% there are lots of smaller ones, tens to hundreds of mid-sized ones, and
% at most only a few larger ones). 
% rand returns random numbers (uniform distribution, 0 to 1)
lambda_little = maxavnumber_littlep * (0.2 + 0.8*rand);   % 4,000 to 20,000
lambda_mid =    maxavnumber_midp    * (0.1 + 0.9*rand);   % 40 to 400
lambda_big =    maxavnumber_bigp    * rand;               % 0 to 5
