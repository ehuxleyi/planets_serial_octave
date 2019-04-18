% PROGRAM TO CALCULATE TEMPERATURE TRAJECTORIES OF A DIVERSITY OF PLANETS
%
% This program calculates the climate evolutions of a variety of different
% planets, based on a simple representation of their climate feedbacks. The
% underlying scientific question which the sinulation is designed to
% address is to understand how the Earth stayed habitable for over 3
% billion years, an immense span of time. There are several reasons for
% being surprised that it did so:
%
% 1. a short residence time (<1 million years) of atmospheric CO2,
%    potentially driving climate volatility;
% 2. increase in the heat received from the Sun, by more than 40% over the
%    lifespan of the Earth (hence the Faint Young Sun problem); and
% 3. prominent reminders of the ease of uninhabitability in the form of
%    Earth's nearest neighbours: Mars (too cold) and Venus (too hot).
%
% The question is addressed here by examining the occurrence of
% habitability in a large and diverse population of planets. A large number
% of model planets are created and each allocated a random set of climate
% feedbacks. Each planet is initialised at a random temperature and then
% simulated through time to see how its temperature history develops, under
% the influence of both its feedbacks and external factors. In this way the
% model is able to evaluate whether planets are able to maintain their
% temperatures within the habitable range in the face of potentially
% destabilising factors such as long-term forcings and perturbations.
%
% units:
%    (1) thousands of years (ky) for time
%    (2) degrees centigrade for temperature
%
% Octave version 4.2.1
%
% This version of the Planets model is the Octave serial version
% It is a close but not identical copy of the Matlab serial version
%
% You are free to use, modify and share this code according to the terms of
% this license:  https://creativecommons.org/licenses/by-nc-sa/4.0/
%                                         Toby Tyrrell & Mark Garnett, 2017
%--------------------------------------------------------------------------
  
initialise;
  
% for each planet
for ii = 1:nplanets
    
    if (verbose)
        fprintf('Planet number %d\n', ii);
        close all;
    end
    
    % Randomly initialise the climate feedbacks for this planet
    determine_feedbacks;
    
    % Randomly determine an overall tendency for progressive cooling or
    % warming (the long-term forcing or 'trend') for this planet
    determine_trend;
    
    % Randomly initialise the planet's 'neighbourhood' (expected
    % numbers of small, moderate and large perturbations)
    determine_neighbourhood;
    
    % calculate some derived planet properties
    calc_planet_properties;
    
    % plot the initial and final dT/dt vs T for this planet
    plot_feedbacks;
          
    % zero some counters / tallies
    nsurvived = 0;  ndied = 0;  sumduration = 0.0;
  
    % for each rerun of this planet
    for jj = 1:nreruns
        
        %% set up this run
        
        run_number = (ii-1)*nreruns + jj;
        if (verbose)
            fprintf('planet %d, rerun %d (nreruns = %d)\n', ...
                ii, jj, nreruns);
        end
        
        % initialise the random number generator for this run
        init_run_rng;
        
        % Randomly initialise the planet's surface temperature
        Tinit = determine_initial_T(Tmin, Trange);
        
        % Randomly calculate a set of perturbations (instantaneous changes
        % to the planet's surface temperature) for this run
        determine_perturbations;
        
        % ----- set some options for the ODE solver -----
        options = odeset('Refine', 1, 'RelTol', 1e-4, 'AbsTol', 0.05, ...
            'MaxStep', 1000, 'InitialStep', 0.01, 'Jacobian', @planets_jac);
            
        %% run the planet through its complete history or until it goes
        % sterile, using matlab's ode23s ODE solver
        
        % first stage - up to the first perturbation
        
        % ----- initial conditions -----
        y0 = [ Tinit 0.0 ];             % start temperature
        tstart	= 0;                    % start time
        tfinal	= perturbations(1,1);   % end time
        stcounter = 0;                  % stage counter
                 
        % Solve until the temperature exceeds habitable bounds or the end
        % of the run is reached
        % No solvers in Octave work as well on this problem as ode23s
        % does in Matlab. odesx is used here. The implementation of 
        % ode23s in Octave does not work well
        % planets_ODE = the function defining the ODE
        % [tstart tfinal] = start and end times of the run (if no event)
        % y0 = initial conditions
        % options = options defined above using odeset
        [t,y,te,ye,ie] = odesx(@planets_ODE, [tstart tfinal], y0, options);
        % t = vector containing the time at each timestep
        % y = vector containing T at each timestep
        % te = time at which an event occurred (planet went sterile)
        % ye = value of T when this occurred
        % ie = index of event, indicating which occurred
        
        t1 = t;
        y1 = y;
        
        time = 0;  tlastplot = 0;  tic;  % timers
        update_feedbacks;  % update the current dT/dt vs T plot
        plot_history;      % update the temperature history plot
  
        % continue the run from perturbation to perturbation until end is
        % reached or planet has gone sterile
        while (((round(t(end))) < max_duration) && (y(end,1) > Tmin) && ...
                (y(end,1) < Tmax) && (stcounter < pcounter))
            
            % next stage of run
            
            % ----- Sort out mechanics/parameterisation of simulation -----
            stcounter = stcounter + 1;    % increment stage counter
            tstart	= t(end);     % continue from end of last stage
            if (stcounter < pcounter)   % if more perturbations left to do
                tfinal	= perturbations((stcounter+1),1); % until next P
            else     % if all perturbations done
                tfinal	= max_duration; % until end of run
            end
            
            % ----- Set up initial conditions -----
            y(end,1) = y(end,1) + perturbations(stcounter,2);  % add P
            y0 = y(end,:);
            
            % Solve until the temperature exceeds habitable bounds or the
            % end of the run is reached
            % No solvers in Octave work as well on this problem as ode23s
            % does in Matlab. odesx is used here. The implementation of 
            % ode23s in Octave does not work well
            [t,y,te,ye,ie] = odesx(@planets_ODE, [tstart tfinal], y0, options);
            
            % accumulate results in arrays
            t = [t1; t];   y = [y1; y];   t1 = t;   y1 = y;
            
            % do not update temperature history plot and current feedbacks
            % plot every single time, but rather only if sufficient time
            % has elapsed since it was last done
            time = toc;
            if (time > 1.0)   % if > 1 second real time since last updated
                time = 0;   tic;
                update_feedbacks;  % update the current dT/dt vs T plot
                % if > 50 My model time since last updated
                if((t(end) - tlastplot) > 5e4)
                    % only plot every 50 My otherwise everything slows
                    % down after 1 or 2 By when there is a lot to plot
                    tlastplot = t(end);
                    plot_history;  % update the temperature history plot
                end
            end
            
        end  % of a rerun (all stageposts from one perturbation to another)
             
        % update plots one last time after run has finished
        update_feedbacks;  % update the current dT/dt vs T plot
        plot_history;      % update the temperature history plot
        if (verbose)
            fprintf ('   survival time was %.3f By\n\n', (t(end)/1e6));
        end
        
        % run was successful if remained habitable throughout the whole 3By
        runs(run_number).planetnumber = ii;
        runs(run_number).rerunnumber = jj;
        if (abs((max_duration-t(end))/max_duration) < 0.001)
            runs(run_number).result = 1;
            nsurvived = nsurvived + 1;
        else
            ndied = ndied + 1;
        end
        sumduration = sumduration + t(end);
        
        % pause before next rerun
        pause(2);
        
    end  % of all reruns of the same planet
    
    % pause before starting next planet
    pause(6);
    
    if (verbose)
        fprintf ('PLANET #%d SUMMARY: of %d reruns, %d remained habitable,\n', ...
            ii, nreruns, nsurvived);
        fprintf ('     %d went sterile, average survival time was %.3f By\n\n', ...
            ndied, (sumduration/nreruns/1e6));
    end
              
end  % of all planets
  
% show a summary of simulation results (how many planets and runs survived)
summary;
