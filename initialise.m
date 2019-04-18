% script to carry out various initialisation tasks
% 
% do several things that are needed before the simulation can start. For
% instance, declare global variables, allocate values to constants, set
% flags, declare arrays and fill with zeros, set up arrays of structures
% and create large sets of random numbers for later use
%--------------------------------------------------------------------------

% close all windows, clear all memory  
clear all; close all; clc;

% share these variables with the function planets_ODE
global Tmin Tmax nnodes Tgap Tnodes Tfeedbacks trend max_duration 
global nplanets nreruns rndmode

% first of all set flags
verbose = 1;        % '1' = lots of print statements and plots, '0' = few
rndmode = 1;        % '1' = truly random, '2' = deterministically random (same every run)
paused  = 0;        % '1' = paused, '0' = not paused

% define constants
nplanets = 100;           % number of distinct planets
nreruns = 4;               % number of times each planet is rerun
nruns = nplanets*nreruns;  % total number of runs to carry out
max_duration = 3e6;        % length of run: 3 billion y = 3 million ky
Tmin = double(-10.0);      % min habitable temperature (lower T limit) (degrees C)
Tmax = double(60.0);       % max habitable temperature (upper T limit) (degrees C)
Trange = Tmax-Tmin;        % width of habitable envelope (degrees C)
nnodes_max = 20;           % max number of node points at which dT/dt needs to be specified
fsd = 100.0;               % standard deviation of feedback strengths (degrees C per ky)
fmax = +4 * fsd;           % maximum likely feedback strength (4 sigma) (degrees C per ky)
fmin = -4 * fsd;           % minimum likely feedback strength (-4 sigma) (degrees C per ky)
frange = 2 * fsd * 4;      % range of likely feedback values (+/- 4 sigma) (degrees C per ky)
trendsd = 50.0;            % standard deviation of trends in dT/dt (degrees C per ky per By)
trendmax = +4 * trendsd;   % maximum likely trend in dT/dt (degrees C per ky per By)
trendmin = -4 * trendsd;   % minimum likely trend in dT/dt (degrees C per ky per By)
trendrange = 2*4*trendsd;  % range of likely trend values (+/- 4 sigma) (degrees C per ky per By)
nbinsd = 20;               % default number of bins for the histograms

% parameters controlling numbers of 3 different classes of perturbations.
% These numbers are the maximum average numbers, i.e. the largest expected
% values, i.e. the values corresponding to those neighbourhoods in which
% there is the greatest frequency of perturbations
maxavnumber_littlep = 20000;
maxavnumber_midp = 400;
maxavnumber_bigp = 5;
% parameters controlling magnitudes of 3 different classes of perturbations
littlep_mean = 2.0;
littlep_std = 1.0;
midp_mean = 8.0;
midp_std = 4.0;
bigp_mean = 32.0;
bigp_std = 16.0;
% likely upper limit on magnitude of largest perturbation (99.994% of a
% normal distribution lies within +/- 4 standard deviations) 
exp_pmax = bigp_mean+(4.0*bigp_std);

% initialise arrays
Tnodes = double(zeros([1 nnodes_max]));    % T at each node
Tfeedbacks = double(zeros([1 nnodes_max]));% feedback (dT/dt) at each node
attractors = double(zeros([nnodes_max 14]));  % cannot be more attractors than nodes
attr       = double(zeros([nnodes_max 14]));

% set up structures and arrays to store information about each planet, to
% be used in later analysis 
for pp = 1:nplanets
    planets(pp).pnumber = pp;        % id number
    planets(pp).nnodes = NaN;         % number of nodes
    planets(pp).nattractors = NaN;    % number of stable attractors
    planets(pp).trend = NaN;          % heating or cooling trend
    planets(pp).lambda_big = NaN;     % big P freq (av number)
    planets(pp).lambda_mid = NaN;     % mid P freq (av number)
    planets(pp).lambda_little = NaN;  % little P freq (av number)
    planets(pp).pcrunaway = NaN;    % percentage of temperature range susceptible to runaway feedbacks
    for qq = 1:nnodes_max
        planets(pp).Tnodes(qq) = NaN;         % T of node
        planets(pp).Tfeedbacks(qq) = NaN;     % dT/dt of node
    end
end

% set up structures and arrays to store information about each run, to be
% used in later analysis
for rr = 1:nruns
    runs(rr).planetnumber = NaN;       % number of the planet
    runs(rr).rerunnumber = NaN;        % which rerun it is
    runs(rr).result = 0;               % outcome of run (whether it stayed habitable for 3 By or not)
end

% seed the random number generator
init_sim_rng;

% generate sets of random numbers to be used later for planet properties
r1 = rand([1 nplanets]);
r2 = randn([nplanets nnodes_max]); % normally-distributed: mean=0, sigma=1
r3 = randn([1 nplanets]);          % normally-distributed: mean=0, sigma=1

warning ("off", "Octave:shadowed-function"); % suppress some warning messages
pkg load odepkg; % make ODE solver routines available
graphics_toolkit('fltk'); % stops crashes for some reason
more off; % don't feed console output to the paging program 'more'

% graphics settings
set (0, "defaultaxesfontname", "Helvetica");
set (0, "defaultaxesfontsize", 12);
set (0, "defaulttextfontname", "Helvetica");
set (0, "defaulttextfontsize", 12) ;
