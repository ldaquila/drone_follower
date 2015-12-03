% Use this file to compute plots
close all;

dataset = '1';
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
measured_theta = 12.88; % The theta that was physically measured

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
