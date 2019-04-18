% script to plot the initial and final dT/dt values vs T
% 
% plot the rate of temperature change (dT/dt) (arising from the sum of all
% feedbacks) as a function of planetary temperature. Feedbacks outside
% the habitable range are not of interest because recovery from sterility
% is considered to be too late. Stable attractors (x-axis intercepts where
% dT/dt is decreasing, going from +ve to -ve values) are indicated in red.
% Runaway feedback zones are indicated by grey shading.
%
% This script is called once only for each planet
% -------------------------------------------------------------------------

% stop matlab displaying integers using scientific notation
format short;


%% make the window (figure) to contain all the panels (subplots)
%  or clear it if it already exists
fig = figure(1);
clf(fig);
set(fig, 'Units', 'normalized');
set(fig, 'Position', [0.07 0.05 0.86 0.90]);
set(fig, 'MenuBar', 'none');
set(fig, 'doublebuffer','on');

%% make the top-left panel (subplot) in which the initial dT/dt values are
% shown.
h1 = subplot(3, 5, [1 2]);
set(h1, 'Position', [0.10 0.73 0.25 0.20]);

% calculate dT/dt and the attractors for the initial state
feedbacks = Tfeedbacks;
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
hold on;

% show positions of x-axis intercepts from +ve to -ve (stable attractors)
for aa = 1:nattr
    plot(attr(aa,1), 0, 'ro', 'LineWidth', 3, 'MarkerSize', 4);
    plot(attr(aa,1), 0, 'ro', 'LineWidth', 3, 'MarkerSize', 12);
end

% add annotation to showing the strength of the imposed forcing 
str = sprintf('Long-term forcing = %.1f (%cC ky^{-1}) By^{-1}', ...
    trend, char(176));
text(7, -240, str); 

% overlay basins of attraction
for mm = 1:nattr
    % plot a red stippled box of the same width and height as the basin of
    % attraction
    xl = attr(mm,9);   xr = attr(mm,10);
    yb = attr(mm,7);   yu = attr(mm,6);
    plot([xl xr xr xl xl], [yu yu yb yb yu], '-.r', 'LineWidth', 2);
    hold on;
end

% add title, label the axes and show them
str = sprintf('Initial feedbacks (before forcing)');
title(str, 'FontSize', 14);
str2 = ["planetary temperature (", char(176), "C)"];
xlabel(str2);
str3 = ["dT/dt (", char(176), "C ky^{-1})"];
ylabel(str3);
ybot = min(min(Tfeedbacks),(fmin*3/4));
ytop = max(max(Tfeedbacks),(fmax*3/4));
axis([Tmin Tmax ybot ytop]);


%% make the bottom-left panel (subplot) in which the final dT/dt values are
% shown, after the imposition of 3 By of forcing
h3 = subplot(3, 5, [11 12]);
set(h3, 'Position', [0.10 0.13 0.25 0.20]);

% recalculate dT/dt and the attractors for the end of the run
feedbacks = Tfeedbacks + (max_duration/1e6)*trend;
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

% add annotation to showing the lambdas (expected numbers of perturbations)
str2 = sprintf('Expected perturbation numbers = %d, %d & %d', ...
    round(lambda_little), round(lambda_mid), round(lambda_big));
text(3, -240, str2); 

% overlay basins of attraction
for mm = 1:nattr
    % plot a red stippled box of the same width and height as the basin of
    % attraction
    xl = attr(mm,9);   xr = attr(mm,10);
    yb = attr(mm,7);   yu = attr(mm,6);
    plot([xl xr xr xl xl], [yu yu yb yb yu], '-.r', 'LineWidth', 2);
    hold on;
end

% add title, label the axes and show them
str = sprintf('Final (at 3By, if still habitable)');
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
