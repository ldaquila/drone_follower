% compute per-packet residuals for best subcarrier
function [all_times, all_thetas] = unwraptosubc(dataset, best_subc, nSubcarriers, resolution, all_times, all_thetas)
    figure;
    temp_times = all_times(best_subc, :);
    best_subc_times = temp_times(temp_times~=Inf);
    best_subc_thetas = all_thetas(best_subc, :);
    [dontcare, num_packets] = size(best_subc_times);

    for subc = 1:nSubcarriers
        this_subc_times = all_times(subc, :);
        this_subc_thetas = all_thetas(subc, :);
        for packet = 1:num_packets % Iterate through all the packets and compare to the next successive one
            time = best_subc_times(packet);
            index = find(this_subc_times==time);
            
            if ~isempty(index)
                diff_to_best_subc = this_subc_thetas(index) - best_subc_thetas(packet);
                if diff_to_best_subc > resolution/2
                    this_subc_thetas(index) = this_subc_thetas(index) - resolution;
                end
                if diff_to_best_subc < -resolution/2
                    this_subc_thetas(index) = this_subc_thetas(index) + resolution;
                end
            end
        end
        plot(this_subc_times(this_subc_times~=Inf), this_subc_thetas(this_subc_times~=Inf));
        all_thetas(subc, :) = this_subc_thetas;
        hold on;
    end

    title(['Theta Unwrapped by Diff to Best Subcarrier ' dataset]);
    xlabel('Time(seconds)');
    ylabel('Theta (Radians)');
    legend('Each line represents a subcarrier');
end