% script to set the long-term forcing for a planet. 
% 
% In reality, planets are subject over their lifetimes to one or more
% gradual changes to the major terms in their radiation budgets. For
% instance, over 3 billion years the brightness (luminosity, i.e. the
% heating effect on the planet) of a planet's star will change according to
% well-understood patterns determined by the class of the star, its mass
% and its metallicity. Other factors can also drive long-term trends, for
% instance biological evolution on inhabited planets can lead to
% progressive removal of greenhouse gases from the atmosphere, especially
% when they are a source of essential nutrient as in the case of carbon
% dioxide for land plants. Likewise, an increase in albedo could occur, as
% it has on Earth, for a planet experiencing plate tectonics, if this leads
% to an increase in the area of continents over time (land has higher
% albedo than ocean).
% 
% In the model, the sum of all long-term forcings is combined into one
% overall forcing (referred to as the 'trend' in the code), and implemented
% by adding a time-dependent amount to the ODE for dT/dt. This
% time-dependent amount ramps up linearly over time, from zero at the
% beginning of the run to three times the forcing value (per By) by the end 
% of the run. The trend can be positive (tending to make the planet warmer 
% over time), negative (tending to make it cooler) or zero (no trend).
%--------------------------------------------------------------------------

% 'r3' contains random numbers from a normal distribution with a mean of 0
% and standard deviation of 1
trend = r3(ii) * trendsd;  % mean=0, sigma=trendsd
