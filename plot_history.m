% script to plot how temperature changes over time during a run

% plot the temperature evolution, from the starting point (time at which
% life first evolved) up until the current time. The initial temperature is
% indicated with a green square, positions of attractors with red circles
% and times and magnitudes of perturbations with red triangles at the
% bottom of the plot
% -------------------------------------------------------------------------

% define some colours to be used
skyblue = [0.7 0.7 1.0];
lightblue = [56 195 253] ./ 255;
lightgrey = [0.8 0.8 0.8];
darkgrey = [0.2 0.2 0.2];
black = [0 0 0];

% set some variables for local use
ltime = t;
est = y(:,1);
jumps = perturbations;
njumps = pcounter;


%% make the right-hand panel (subplot) in which the temperature history is
% shown
h4 = subplot(3, 5, [3 4 5 8 9 10 13 14 15]);
cla;
set(h4, 'Position', [0.48 0.13 0.45 0.80]);

% show axes at the top and right of the plot as well as at left and bottom
ax = gca; set(gca, 'Box', 'on'); set(gca', 'FontSize', 12);
hold on;

% generate a legend by plotting different symbols outside the visible axes
% (none of these will show up)
plot (-2000, 12000, 'gs', 'LineWidth', 2, 'MarkerEdgeColor', 'k', ...
    'MarkerFaceColor', 'g', 'MarkerSize', 8);
hold on;
plot(-4000, 12000, 'co', 'LineWidth', 1, 'MarkerEdgeColor', 'none', ...
    'MarkerFaceColor', 'c', 'MarkerSize', 16);
hold on;
plot(-10000, 12000, '-ko', 'LineWidth', 2);
hold on;
plot(-8000, 12000, 'ro', 'LineWidth', 3, 'MarkerSize', 12);
hold on;
plot(-6000, 12000, '^r', 'LineWidth', 1, 'MarkerSize', 15);
hold on;
plot (-2000, 12000, 'gs', 'LineWidth', 2, 'MarkerEdgeColor', [0.8 0.8 0.8], ...
    'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerSize', 17);
hold on;
lgd = legend('initial T', 'current T', 'feedbacks', ...
    'attractor', 'perturbation', 'runaway zone', ...
    'Location', 'south', 'Orientation', 'horizontal');
set(lgd, 'FontSize', 14);

% plot the planet's surface temperature against time (in My)
li = plot((ltime/1e3), est, 'Color', lightblue, 'LineWidth', 1);
ylim([(Tmin-5) (Tmax+5)]);
gg = xlim;
plotxmin = gg(1);
plotxmax = (ltime(end)/1e3);
hold on;

% set the fontsize and linewidth for these axes
h=get(gcf, "currentaxes");
set(h, "fontsize", 14, "linewidth", 2);

% plot on zones of runaway warming or runaway cooling
if (~isnan(icehT))
    fill([0 0 plotxmax plotxmax], [Tmin icehT icehT Tmin], lightgrey, ...
        'EdgeColor', 'none');
    hold on;
end
if (~isnan(greenhT))
    fill([0 0 plotxmax plotxmax], [greenhT Tmax Tmax greenhT], ...
        lightgrey, 'EdgeColor', 'none');
    hold on;
end

% plot on habitability limits
fill([0 0 plotxmax plotxmax], [Tmin-5 Tmin Tmin Tmin-5], darkgrey, ...
    'EdgeColor', 'k');
hold on;
fill([0 0 plotxmax plotxmax], [Tmin-0.5 Tmin Tmin Tmin-0.5], black, ...
    'EdgeColor', 'k');
hold on;
fill([0 0 plotxmax plotxmax], [Tmax Tmax+5 Tmax+5 Tmax], darkgrey, ...
    'EdgeColor', 'k');
hold on;
fill([0 0 plotxmax plotxmax], [Tmax Tmax+0.5 Tmax+0.5 Tmax], black, ...
    'EdgeColor', 'k');
hold on;

% plot perturbations as triangles on a blue strip below
fill([0 0 plotxmax plotxmax], [Tmin-15 Tmin-5 Tmin-5 Tmin-15], skyblue, ...
    'EdgeColor', 'k');
% only show those perturbations that are both large and which occur before
% the end of the run (before planet has gone sterile)
jumps2 = jumps;
njumps2 = 0;
njumps3 = 0;
for kk = 1:njumps
    if  (abs(jumps(kk,2)) > 5.0)
        njumps3 = njumps3 + 1;   % counter for all large jumps
        if (jumps(kk,1) < ltime(end))
            njumps2 = njumps2 + 1;   % counter for large jumps before end
            jumps2(njumps2,:) = jumps(kk,:);
        end
    end
end
% show them as triangles whose size is proportional to the size of the
% impact
for kk = 1:njumps2
    symsize = round(10.0*abs(jumps2(kk,2)/5.0)); % symbol size shows P size
    if (jumps2(kk,2) > 0.0)    % point triangle upwards for T increase
        plot((jumps2(kk,1)/1e3), (Tmin-10), '^r', 'MarkerSize', symsize, ...
        'LineWidth', 1);
    else                      % point triangle downwards for T decrease
        plot((jumps2(kk,1)/1e3), (Tmin-10), 'vr', 'MarkerSize', symsize, ...
        'LineWidth', 1);
    end
    hold on;
end

% set axes limits
xlim([0 plotxmax]);
ylim([(Tmin-15) (Tmax+5)]);
hold on;

% make the time units be plotted in normal (not scientific) notation
set(gca, 'XTick', linspace(0, plotxmax, 10));
xt = get(gca, 'xtick');
for i = 1:length(xt)
    % use an appropriate number of decimal places
    if (xt(2) < 0.0001)
        xticklabel{i} = sprintf('%1.5f', xt(i));
    elseif (xt(2) < 0.001)
        xticklabel{i} = sprintf('%1.4f', xt(i));
    elseif (xt(2) < 0.01)
        xticklabel{i} = sprintf('%1.3f', xt(i));
    elseif (xt(2) < 0.1)
        xticklabel{i} = sprintf('%1.2f', xt(i));
    elseif (xt(2) < 1)
        xticklabel{i} = sprintf('%1.1f', xt(i));
    else
        xticklabel{i} = sprintf('%1.0f', xt(i));
    end
end
xticklabel{1} = sprintf('0');
set(gca, 'xticklabel', xticklabel);

% give the plot a title
if (nreruns == 1)
    str = sprintf('Temperature history of planet %d', ii);
else
    str = sprintf('Temperature history of planet %d (rerun %d)', ii, jj);
end
title(str, 'FontSize', 16);
xlabel('time (My)', 'FontSize', 14);
str2 = ["planetary temperature (", char(176), "C)"];
ylabel(str2, 'FontSize', 14);

% plot the axes again, to bring them to the top
plot([0 0 plotxmax plotxmax], [(Tmin-15) (Tmax+5) (Tmax+5) (Tmin-15)], '-k', ...
    'LineWidth', 2);
hold on;

% show the starting temperature
plot(0, Tinit, 'gs', 'LineWidth', 2, 'MarkerEdgeColor', 'k', ...
    'MarkerFaceColor', 'g', 'MarkerSize', 8);
hold on;

% show the positions of stable attractors
for kk = 1:nattractors
    plot(0, attractors(kk,1), 'ro', 'LineWidth', 3, 'MarkerSize', 4);
    plot(0, attractors(kk,1), 'ro', 'LineWidth', 3, 'MarkerSize', 12);
end

% plot the planet's surface temperature again, to bring it on top
li = plot((ltime/1e3), est, 'Color', lightblue, 'LineWidth', 1);
ylim([(Tmin-5) (Tmax+5)]);
gg = xlim;
plotxmin = gg(1);
plotxmax = (ltime(end)/1e3);
hold on;

% set axes limits
xlim([0 plotxmax]);
ylim([(Tmin-15) (Tmax+5)]);
hold on;

drawnow;
