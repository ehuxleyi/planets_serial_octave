% script to initialise the random number generator prior to a simulation
%--------------------------------------------------------------------------

if (rndmode == 1) % 'truly random'
    % seed the random number generator based on the current time
    time = clock;                % get the current time
    secs = time(6);              % in seconds (ie SS in HH:MM:SS)
    msecs = round(1000 * secs);  % decimal seconds to milliseconds
    rand('seed', msecs);
else % 'deterministically random' (same set of random numbers every time)
    rand('seed', nplanets);
    error('rndmode should be 1');
end
