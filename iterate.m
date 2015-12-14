function [new_all_times, new_all_thetas] = iterate(dataset, threshold, resolution, nSubcarriers, nPackets, old_all_times, old_all_thetas, v)
    u = num2str(v-1);
    figure; %17
    new_all_times = Inf(nSubcarriers, nPackets);
    new_all_thetas = Inf(nSubcarriers, nPackets);
    for subc = 1:nSubcarriers
        temp = old_all_times(subc,:);
        last_t = temp(temp~=Inf);
        temp2 = old_all_thetas(subc,:);
        last_thetas = temp2(temp2~=Inf);

        subplot(1,2,1);
        title(['v' u ' After Dropping Packets and Unwrapping Data Set ' dataset]);
        plot(last_t, last_thetas); 
        hold on;

        new_packets_todrop = zeros(size(last_thetas));
        for packet = 2:length(last_t)-1
            delta = last_thetas(packet) - last_thetas(packet-1);
            if delta > threshold
                if delta > resolution/2 % this is a trend, unwrap
                    last_thetas(packet) = last_thetas(packet) - resolution;
                else % one weird packet, drop
                    %remove this subc, packet entry from thetas
                    new_packets_todrop(packet) = 1;
                end
            end
            if delta < -threshold
                if delta < -resolution/2 % this is a trend, unwrap
                    last_thetas(packet) = last_thetas(packet) + resolution;
                else % one weird packet, drop
                    %remove this subc, packet entry from thetas
                    new_packets_todrop(packet) = 1;
                end
            end
        end
        v_t = last_t(new_packets_todrop(:)~=1);
        v_thetas = last_thetas(new_packets_todrop(:)~=1);

        new_all_times(subc, 1:size(v_t, 2)) = v_t;
        new_all_thetas(subc, 1:size(v_thetas, 2)) = v_thetas;

        subplot(1,2,2);
        plot(v_t, v_thetas);
        hold on;
    end

    title(['v' num2str(v) 'After Dropping Packets and Unwrapping Data Set ' dataset]);
    xlabel('Time (Seconds)');

end