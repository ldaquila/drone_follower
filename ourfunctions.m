% find best subcarrier = subcarrier with least residuals


function [best_subc] = findbestsubc(nSubcarriers, nPackets, thetas_unwrapped)
    min = Inf;
    best_subc = 0;
    for subc_to_try = 1:nSubcarriers
        diff_to_base_subc = zeros(nSubcarriers, nPackets);
        for subc = 1:nSubcarriers
            % should have one row of all 0's when subc=subc_to_try
            diff_to_base_subc(subc, :) = thetas_unwrapped(subc, :) - thetas_unwrapped(subc_to_try, :);
        end
        abs_diff = abs(diff_to_base_subc);
        this_sum = nansum(abs_diff(:)); % why does this give me NaN without nansum?
        if this_sum < min
            min = this_sum;
            best_subc = subc_to_try;
        end
    end
end