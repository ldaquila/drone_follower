% Use this file to compute plots
close all;

measured_theta = 12.88; % The theta that was physically measured
dataset = '5';
% dataset 1 = csi_log_for_angle.txt angle = 12.88
% dataset 2 = csi_log_dec2-1.txt angle = 10
% dataset 3 = csi_log_45_degrees.txt angle = 45
% dataset 4 = csi_log_45_degrees_again.txt angle = 45
% dataset 5 = csi_log_45_degrees_third.txt angle = 45
% dataset 6 = csi_log_45to60degrees.txt angle = 15 
% dataset 7 = csi_log_dec6_left1.txt angle = 32
% dataset 8 = csi_log_dec6_left2.txt angle = 39
% dataset 9 = csi_log_dec6_left3.txt angle = 41
subcarriers = [-26:-1 1:26];

x = load('lab3_process_separate.mat');

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
figure;
plot(abs(H11_1));
hold on;
plot(abs(H21_1));
plot(abs(H11_2));
plot(abs(H21_2));
legend('H11_1','H21_1','H11_2','H21_2');
title('magnitude for first two packets');

figure;
plot(angle(H11_1));
hold on;
plot(angle(H21_1));
title('Angle of two channels for the first packet');

figure;
plot(unwrap(angle(H11_1)));
title('Unwrapped angle of first channel for the first packet');

figure;
plot(angle(H11_1./H21_1));
title('Angle of ratio of two channels for the first packet');

% The fact that the are similar between packets shows that these differences are due to
% noise and not multipath between the two packets. However, the angle should be
% constant across all subcarriers, showing that there are multipath/barrier
% effects taking place (which is why we were seeing that some subcarriers
% were getting better results than others).
figure;
plot(angle(H21_1./H11_1));
hold on;
plot(angle(H21_2./H11_2));
title('Angle of ratio of two channels for the first two packets');


y = load('our_process_separate.mat');
f = 5.2 * 10^9;
c = 299792458;
D = .22;

figure;
theta_degrees = zeros(1,52);
for subc = 1:52
    h=unwrap(angle(y.hs(subc,1,:) ./ y.hs(subc,3,:)));
    h = h(:);
    plot(h); % to do time do y.timestamps , h
    first_h = mean(h(1:15));
    last_h = mean(h(end-14:end));
    theta_radians1 = acos((c/f) * first_h / (2 * pi * D));
    theta_radians2 = acos((c/f) * last_h / (2 * pi * D));
    theta_degrees(subc) = (theta_radians2 - theta_radians1) * 57.2958;
    hold on;
    title(['Angle of Channel Measurement Ratio for Data Set ' dataset]);
    xlabel('Packet');
    ylabel('Angle of Channel Measurement Ratio');
    legend('Each line represents a different subcarrier');
end

theta_degrees = abs(theta_degrees);
figure;
plot(subcarriers,theta_degrees,'*');
hold on;
plot(subcarriers,ones(1,52)*measured_theta);
title(['Theta Across Subcarriers for Data Set ' dataset]);
xlabel('Subcarrier');
ylabel('Angle in Degrees');
legend('Computed Theta', 'Theoretical Theta');
% Print the mean of the theta measured from each of the subcarriers
mean(theta_degrees)

% Integration: Compute delta theta
h_size = size(y.hs);
total_theta = 0;
delta_thetas = zeros(1,h_size(3));

for packet = 1:h_size(3)-1 % Iterate through all the packets and compare to the next successive one
    theta_degrees = zeros(1,52);
    for subc = 1:52
        h=unwrap(angle(y.hs(subc,1,packet:packet+1) ./ y.hs(subc,3,packet:packet+1)));
        theta_radians1 = acos((c/f) * h(1) / (2 * pi * D));
        theta_radians2 = acos((c/f) * h(2) / (2 * pi * D));
        theta_degrees(subc) = (theta_radians2 - theta_radians1) * 57.2958;
    end
    delta_thetas(packet) = mean(theta_degrees);
    total_theta = total_theta + mean(theta_degrees);
end
total_theta
figure;
plot(delta_thetas);
title(['Per-Packet Delta Theta for Data Set ' dataset]);
xlabel('Packet');
ylabel('Mean Delta Theta across Subcarriers(Degrees)');


% Compute resolution  
h_size = size(y.hs);
nSubcarriers = 52;
thetas = zeros(nSubcarriers,h_size(3));
maxTheta = 0;
minTheta = 360;

for packet = 1:h_size(3) % Iterate through all the packets 
    for subc = 1:nSubcarriers
        h=angle(y.hs(subc,1,packet) ./ y.hs(subc,3,packet)); 
        % Laura had an unwrap here ^ but it doesn't seem to make a difference
        theta_radians1 = acos((c/f) * h(1) / (2 * pi * D));
        thetas(subc, packet) = theta_radians1 * 57.2958;
        if thetas(subc, packet) < minTheta
            minTheta = thetas(subc, packet);
        end
        if thetas(subc, packet) > maxTheta
            maxTheta = thetas(subc, packet);
        end
    end
end

figure;
for subc = 1:nSubcarriers
    plot(thetas(subc,:)); %plot(thetas(subc,1:50)); plots for 50 packets
    hold on;
end
resolution = maxTheta - minTheta % in degrees
title(['Per-Packet Theta for Data Set ' dataset]);
xlabel('Packet');
ylabel('Theta (Degrees)');
legend('Each line represents a subcarrier');



%get phase
phase = squeeze(angle(y.hs(:,1,:) ./ y.hs(:,3,:)));
range = pi/(D/((c/f)/2));
phase = unwrap(phase);
figure;
for i=1:52
    figure;
plot(phase(i,:)')
title(i)
end
theta = acos((c/f) * phase / (2*pi*D)); %radians
% theta = unwrap(theta, range/2);

figure;
plot(theta')
title('theta unwrap')