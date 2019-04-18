% script to update the plot of current dT/dt values vs T
% 
% plot the rate of temperature change (dT/dt) (arising from the sum of all
% feedbacks) as a function of planetary temperature. Feedbacks outside
% the habitable range are not of interest because recovery from sterility
% is considered to be too late. Stable attractors (x-axis intercepts where
% dT/dt is decreasing, going from +ve to -ve values) are indicated in red.
% Runaway feedback zones are indicated by grey shading.
%
% This script is called maybe 20 times during a long run, tracking how
% dT/dt vs T changes with elapsed time as the long-term forcing becomes
% more influential
% -------------------------------------------------------------------------

% stop matlab displaying integers using scientific notation
format short;
  

%% make the middle-left panel (subplot) in which the current dT/dt values 
% are shown, after the imposition of the forcing at the current time
h2 = subplot(3, 5, [6 7]);
cla;
%h2 = subplot(3, 5, [6 7]);
hold off;
set(h2, 'Position', [0.10 0.43 0.25 0.20]);

% recalculate dT/dt and the attractors for the current time
feedbacks = Tfeedbacks + (t(end)/1e6)*trend;
calc_attractor_properties;

% calculate regions where there are runaway (positive) feedbacks to
% uninhabitability and indicate them to the plot
calc_runaways;
hold on;
if (~isnan(icehT))
    fill(xcs_icehouse, ycs_icehouse, [0.8 0.8 0.8]);
end
if (~isnan(greenhT))
    fill(xcs_greenhouse, ycs_greenhouse, [0.8 0.8 0.8]);
end

% plot dT/dt vs T
plotx1 = Tnodes(1:nnodes);
ploty1 = feedbacks(1:nnodes);
plot(plotx1, ploty1, '-ko', 'LineWidth', 3);
box on;
hold on;

% set the fontsize and linewidth for these axes
h=get(gcf, "currentaxes");
set(h, "fontsize", 14, "linewidth", 2);

% axis
line([Tmin Tmax], [0 0], 'LineWidth', 2, 'Color', [0 0 0]);

% show positions of x-axis intercepts from +ve to -ve (stable attractors)
for aa = 1:nattr
    plot(attr(aa,1), 0, 'ro', 'LineWidth', 3, 'MarkerSize', 4);
    plot(attr(aa,1), 0, 'ro', 'LineWidth', 3, 'MarkerSize', 12);
end

% overlay basins of attraction
for mm = 1:nattr
    % plot a red stippled box of the same width and height as the basin of
    % attraction
    xl = attr(mm,9);   xr = attr(mm,10);
    yb = attr(mm,7);   yu = attr(mm,6);
    plot([xl xr xr xl xl], [yu yu yb yb yu], '-.r', 'LineWidth', 2);
    hold on;
end

% show the current temperature
Tnow = y(end,1);
if (Tnow < Tmin)
    Tnow = Tmin;
elseif (Tnow > Tmax)
    Tnow = Tmax;
end
plot(Tnow, 0, 'co', 'LineWidth', 2, 'MarkerEdgeColor', 'none', ...
    'MarkerFaceColor', 'c', 'MarkerSize', 16);
hold on;

% add title, label the axes and show them
str = sprintf('Current (time = %d My)', round(t(end)/1000));
title(str);
str2 = ["planetary temperature (", char(176), "C)"];
xlabel(str2);
str3 = ["dT/dt (", char(176), "C ky^{-1})"];
ylabel(str3);
ybot = min(min(feedbacks),(fmin*3/4));
ytop = max(max(feedbacks),(fmax*3/4));
axis([Tmin Tmax ybot ytop]);

drawnow;
hold off;
