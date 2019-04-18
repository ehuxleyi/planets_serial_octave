% display a summary of the results obtained across all planets simulated
%--------------------------------------------------------------------------

% calculate and display how many planets and runs survived
if (verbose)
    ngoodruns = 0;  ngoodplanets = 0;  nperfectplanets = 0;
    for pp = 1:nplanets
        a_run_survived = 0; all_runs_survived = 1;
        for kk = 1:nreruns
            rr = (pp-1)*nreruns+kk;   % calculate the run number
            % if the run was successful (remained habitable)...
            if (runs(rr).result == 1)
                % set a flag to show that this planet had at least one
                % successful run
                a_run_survived = 1;
                ngoodruns = ngoodruns + 1;
            else
                all_runs_survived = 0;
            end
        end
        % if at least one instance of this planet survived...
        if (a_run_survived == 1)
            ngoodplanets = ngoodplanets + 1;
        end
        % if all instances of this planet survived...
        if (all_runs_survived == 1)
            nperfectplanets = nperfectplanets + 1;
        end
    end
    fprintf ('\nOVERALL SUMMARY:');
    fprintf('\n   %d out of %d planets survived sometimes (%d reruns each)', ...
        ngoodplanets, nplanets, nreruns);
    fprintf('\n   %d out of %d planets were perfect', ...
        nperfectplanets, nplanets);
    fprintf('\n   %d out of %d runs were successful\n', ...
        ngoodruns, (nplanets*nreruns));
end
