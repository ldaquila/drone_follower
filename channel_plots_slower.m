% Use this file to compute plots
close all;

measured_theta = 12.88; % The theta that was physically measured
dataset = '14';
start_angle_degrees = 90;
% dataset 1 = csi_log_for_angle.txt angle = 12.88
% dataset 2 = csi_log_dec2-1.txt angle = 10
% dataset 3 = csi_log_45_degrees.txt angle = 45
% dataset 4 = csi_log_45_degrees_again.txt angle = 45
% dataset 5 = csi_log_45_degrees_third.txt angle = 45
% dataset 6 = csi_log_45to60degrees.txt angle = 15 
% dataset 7 = csi_log_dec6_left1.txt angle = 32
% dataset 8 = csi_log_dec6_left2.txt angle = 39
% dataset 9 = csi_log_dec6_left3.txt angle = 41

nSubcarriers = 52;

subcarriers = [-26:-1 1:26]; % subcarrier scale on x-axis

x = load('lab3_process_separate.mat');
y = load('our_process_separate.mat');
% These indices put the subchannels in order from -26 to 26 (see picture on
% my phone)
ordered_H_packet1 = orderSubcarriers(x.csi_filtered{1}.H);
ordered_H_packet2 = orderSubcarriers(x.csi_filtered{2}.H);

% Get the channels for the first packet
H21_1 = ordered_H_packet1(:,3);
H11_1 = ordered_H_packet1(:,1);

% Get the channels for the second packet
H21_2 = ordered_H_packet2(:,3);
H11_2 = ordered_H_packet2(:,1);

% Plot the magnitude. Should be a bell curve without multipath
figure;% 1
plot(subcarriers, abs(H11_1));
hold on;
plot(subcarriers, abs(H21_1));
plot(subcarriers, abs(H11_2));
plot(subcarriers, abs(H21_2));
legend('H11_1','H21_1','H11_2','H21_2');
title('Magnitude for First Two Packets');
xlabel('Subcarrier');
ylabel('Magnitude');

figure; %2
plot(angle(H11_1));
hold on;
plot(angle(H21_1));
title('Angle of two channels for the first packet');

figure; %3
plot(unwrap(angle(H11_1)));
title('Unwrapped angle of first channel for the first packet');

figure; %4
plot(angle(H11_1./H21_1));
title('Angle of ratio of two channels for the first packet');

% The fact that the are similar between packets shows that these differences are due to
% noise and not multipath between the two packets. However, the angle should be
% constant across all subcarriers, showing that there are multipath/barrier
% effects taking place (which is why we were seeing that some subcarriers
% were getting better results than others).
figure; %5
plot(angle(H21_1./H11_1));
hold on;
plot(angle(H21_2./H11_2));
title('Angle of ratio of two channels for the first two packets');

y.timestamps = y.timestamps - y.timestamps(1);
f = 5.2 * 10^9;
c = 299792458;
D = .22;

% Equivalent to floor(2 * pi * D * cosd(start_angle_degrees) / (c / f) / pi / 2)
% Subtract 2*pi*k from all the data
first_k = D * cosd(start_angle_degrees) / (c / f);
if first_k < 0
    % ceil of -3.5 is -3
    k = ceil(first_k);
else
    % floor of 3.5 is 3
    k = floor(first_k); 
end

figure; %6 good
theta_degrees = zeros(1,52); 
% ^difference between the average of first 15 and average of last 15 packets by subcarrier
h_size = size(y.hs);
nPackets = h_size(3);
thetas = zeros(nSubcarriers,nPackets); % actual value of theta for every packet and every subcarrier
phi_bysubc = zeros(nSubcarriers, nPackets);
thetas_unwrapped = zeros(nSubcarriers, nPackets);
for subc = 1:nSubcarriers
    phi = angle(y.hs(subc,1,:) ./ y.hs(subc,3,:));
    phi_bysubc(subc, :) = angle(y.hs(subc,1,:) ./ y.hs(subc,3,:));
    phi = phi + 2*k*pi;
    % phi_bysubc(subc, :) = phi_bysubc(subc, :) + 2*k*pi; % this doesn't
    % seem to make a difference for the later parts
    thetas_unwrapped(subc, :) = acos(-(c/f) * phi_bysubc(subc, :) / (2 * pi * D));
    
    h=unwrap(phi); % phase change
    theta_radians = acos(-(c/f) * h / (2 * pi * D));% need to
    thetas(subc,:) = squeeze(theta_radians)*57.2958;
    h = h(:);
    plot(y.timestamps, h); % to do time do y.timestamps , h
    first_h = mean(h(1:15));
    last_h = mean(h(end-14:end));
    theta_radians1 = acos(-(c/f) * first_h / (2 * pi * D));
    theta_radians2 = acos(-(c/f) * last_h / (2 * pi * D));
    theta_degrees(subc) = (theta_radians2 - theta_radians1) * 57.2958;
    hold on;
    title(['Angle of Channel Measurement Ratio for Data Set ' dataset]);
    xlabel('Time');
    ylabel('Angle of Channel Measurement Ratio');
    legend('Each line represents a different subcarrier');
end
figure; %7 good
for subc = 1:nSubcarriers
    plot(y.timestamps, real(thetas(subc,:)));
    hold on;
end
title('Theta As a Function of Time')
xlabel('Time');
ylabel('Theta');

integrated_delta_theta = 0;
thetas = real(thetas); %get rid of weird small imaginary part (above 180?)
delta_theta = zeros(nSubcarriers,nPackets-1);
for packet = 1:nPackets-1
    for subc = 1:nSubcarriers
        delta_theta(subc,packet) = thetas(subc,packet+1) - thetas(subc,packet);
    end
end

integrated_theta = zeros(1,nSubcarriers);
for subc = 1:nSubcarriers
    integrated_theta(subc) = sum(delta_theta(subc,:));
end
figure; %8
plot(subcarriers, integrated_theta);
hold on;
plot(ones(size(integrated_theta))*measured_theta);
mean(integrated_theta);
title('Integrated Theta');
xlabel('Subcarrier');
ylabel('Theta (Degrees)');

figure; %9
plot(subcarriers,real(theta_degrees),'*');
hold on;
plot(subcarriers,ones(1,52)*measured_theta);
title(['Theta Across Subcarriers for Data Set ' dataset]);
xlabel('Subcarrier');
ylabel('Angle in Degrees');
legend('Computed Theta', 'Theoretical Theta');
% Print the mean of the theta measured from each of the subcarriers
mean(theta_degrees);

% Integration: Compute delta theta
% y.hs subcarriers, channels, packets
total_theta = 0;

figure; %10
for subc = 1:nSubcarriers
    plot(y.timestamps, thetas(subc,:)); %plot(thetas(subc,1:50)); plots for 50 packets
    hold on;
end

title(['Per-Packet Theta for Data Set ' dataset]);
xlabel('Time (Seconds)');
ylabel('Theta (Degrees)');
legend('Each line represents a subcarrier');


resolution = pi/7.63; % in rad


% find best subcarrier = subcarrier with least residuals
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

best_subc

% compute per-packet residuals for best subcarrier
signif_diff = zeros(nSubcarriers, nPackets);
diff_to_best_subc = zeros(nSubcarriers, nPackets);
for packet = 1:nPackets % Iterate through all the packets and compare to the next successive one
    for subc = 1:nSubcarriers
        diff_to_best_subc(subc, packet) = thetas_unwrapped(subc, packet) - thetas_unwrapped(best_subc, packet);
        if abs(diff_to_base_subc(subc, packet)) > resolution/2
            signif_diff(subc, packet) = diff_to_best_subc(subc, packet);
        end
    end
end

figure; % 11
for subc = 1:nSubcarriers
    plot(y.timestamps,diff_to_best_subc(subc,:)); %plot(thetas(subc,1:50)); plots for 50 packets
    hold on;
end
title(['Difference Between Subcarriers ' dataset]);
xlabel('Time(seconds)');
ylabel('Residuals to Best Subcarrier');
legend('Each line represents a subcarrier');

figure; % 12
sum_by_subc = nansum(diff_to_best_subc,2);
abs_sub_by_subc = nansum(abs(diff_to_best_subc), 2);
plot(subcarriers, sum_by_subc, subcarriers, abs_sub_by_subc);

title(['Difference Between Subcarriers ' dataset]);
xlabel('Subcarrier');
ylabel('Residuals to Best Subcarrier');
legend('Sum(Residuals)', 'Sum(Abs(Residuals))');


figure; % 13
for subc = 1:nSubcarriers
    plot(y.timestamps, signif_diff(subc, :));
    hold on;
end
title(['Difference Between Subcarriers greater than Resolution/2 ' dataset]);
xlabel('Time (Seconds)');
ylabel('Significant Differences');
legend('Each line represents a subcarrier');


% unwrap based on siginificant differences in subcarriers
figure; %14
subplot(1,2,1);

for subc = 1:nSubcarriers
    plot(y.timestamps,thetas_unwrapped(subc,:)); %plot(thetas(subc,1:50)); plots for 50 packets
    hold on;
end

title(['Uncorrected Theta for Data Set ' dataset]);
xlabel('Time(seconds)');
ylabel('Theta (Radians)');
legend('Each line represents a subcarrier');

for packet = 1:nPackets 
    for subc = 1:nSubcarriers
        if signif_diff(subc, packet) < 0
            thetas_unwrapped(subc, packet) = thetas_unwrapped(subc, packet)+ resolution;
        end
        if signif_diff(subc, packet) > 0
            thetas_unwrapped(subc, packet) = thetas_unwrapped(subc, packet)- resolution;
        end
    end
end

subplot(1,2,2);
for subc = 1:nSubcarriers
    plot(y.timestamps,thetas_unwrapped(subc,:)); %plot(thetas(subc,1:50)); plots for 50 packets
    hold on;
end

title(['Theta Unwrapped by Diff to Subcarrier for Data Set ' dataset]);
xlabel('Time(seconds)');
ylabel('Theta (Radians)');
legend('Each line represents a subcarrier');



% unwrap based on siginificant differences in packets
% Compute delta thetas between successive packets
all_delta_thetas_rad = zeros(nSubcarriers,nPackets-1);
for packet = 1:nPackets-1 % Iterate through all the packets and compare to the next successive one
    for subc = 1:nSubcarriers
         all_delta_thetas_rad(subc, packet) = thetas_unwrapped(subc, packet+1) - thetas_unwrapped(subc, packet);
    end
end

figure; %15
subplot(1,2,1);
for subc = 1:nSubcarriers
    plot(y.timestamps,thetas_unwrapped(subc,:)); %plot(thetas(subc,1:50)); plots for 50 packets
    hold on;
end

title(['Theta Unwrapped by Diff to Subcarrier ' dataset]);
xlabel('Time(seconds)');
ylabel('Theta (Radians)');
legend('Each line represents a subcarrier');

% attempt to do our own unwrap based on successive packets
threshold = 5/57.2958;
subcs_packets_todrop = zeros(size(thetas_unwrapped)-[0,1]); % put a 1 in if we want to drop that entry
for packet = 2:nPackets-2 % Iterate through all the packets and compare to the next successive one
    for subc = 1:nSubcarriers
        if all_delta_thetas_rad(subc, packet) > threshold 
            % see if this is a trend or just one weird packet
            previous_packet_theta = thetas_unwrapped(subc, packet-1);
            next_packet_theta = thetas_unwrapped(subc, packet+1);
            delta = next_packet_theta - previous_packet_theta;
            if delta > resolution/2 % this is a trend, unwrap
                thetas_unwrapped(subc, packet) = thetas_unwrapped(subc, packet) - resolution;
            else % one weird packet, drop it
                %remove this subc, packet entry from thetas
                subcs_packets_todrop(subc, packet) = 1;
            end
        end
        if all_delta_thetas_rad(subc, packet) < -threshold
            % see if this is a trend or just one weird packet
            previous_packet_theta = thetas_unwrapped(subc, packet-1);
            next_packet_theta = thetas_unwrapped(subc, packet+1);
            delta = next_packet_theta - previous_packet_theta;
            if delta < -resolution/2 % this is a trend, unwrap
                thetas_unwrapped(subc, packet) = thetas_unwrapped(subc, packet) + resolution;
            else % one weird packet, drop
                %remove this subc, packet entry from thetas
                subcs_packets_todrop(subc, packet) = 1;
            end
        end
    end 
end

subplot(1,2,2);
for subc = 1:nSubcarriers
    plot(y.timestamps,thetas_unwrapped(subc,:)); %plot(thetas(subc,1:50)); plots for 50 packets
    hold on;
end

title(['Theta Unwrapped by Diff between Packets ' dataset]);
xlabel('Time(seconds)');
ylabel('Theta (Radians)');
legend('Each line represents a subcarrier');

% unwrapping by diff between packets seems to just adds noise


% bad_subc = [];
% for packet = 1:10 % Iterate through all the packets and compare to the next successive one
%     for subc = 1:nSubcarriers
%         if abs(diff_to_best_subc(subc, packet)) > 0.4 % rad
%             bad_subc = [bad_subc subc];
%         end
%     end
% end


figure; %16
subplot(1,3,1);

for subc = 1:nSubcarriers
    plot(y.timestamps,thetas_unwrapped(subc,:)); 
    hold on;
end

title(['Thetas Unwrapped by Subc and Packet for Data Set ' dataset]);
xlabel('Time(seconds)');
ylabel('Theta (Radians)');
legend('Each line represents a subcarrier');


for subc = 1:nSubcarriers
    new_t = y.timestamps(subcs_packets_todrop(subc,:)~=1);
    new_thetas = thetas_unwrapped(subc,:);
    new_thetas = new_thetas(subcs_packets_todrop(subc,:)~=1);
    
    subplot(1,3,2);
    title(['After Dropping Packets: Data Set ' dataset]);
    plot(new_t, new_thetas); 
    hold on;
    
    new_packets_todrop = zeros(size(new_thetas));
    for packet = 2:length(new_t)-1
        delta = new_thetas(packet) - new_thetas(packet-1);
        if delta > threshold
            if delta > resolution/2 % this is a trend, unwrap
                new_thetas(packet) = new_thetas(packet) - resolution;
            else % one weird packet, drop
                %remove this subc, packet entry from thetas
                new_packets_todrop(packet) = 1;
            end
        end
        if delta < -threshold
            if delta < -resolution/2 % this is a trend, unwrap
                new_thetas(packet) = new_thetas(packet) + resolution;
            else % one weird packet, drop
                %remove this subc, packet entry from thetas
                new_packets_todrop(packet) = 1;
            end
        end
    end
    v2_t = new_t(new_packets_todrop(:)~=1);
    v2_thetas = new_thetas(new_packets_todrop(:)~=1);
    
    subplot(1,3,3);
    %ylim([0 180 ]);
    plot(v2_t, v2_thetas);
    hold on;
end

title(['Corrected Per-Packet Per Subcarrier Theta for Data Set ' dataset]);
xlabel('Time (Seconds)');
