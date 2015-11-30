close all;

x = load('csi_log_for_angle.mat');

% These indices put the subchannels in order from -26 to 26 (see picture on
% my phone)
H21=[x.csi{110}.H(5:9,3);x.csi{110}.H(1,3);x.csi{110}.H(10:22,3);x.csi{110}.H(2,3);x.csi{110}.H(23:34,3);x.csi{110}.H(3,3);x.csi{110}.H(35:47,3);x.csi{110}.H(4,3);x.csi{110}.H(48:52,3)];
H11=[x.csi{110}.H(5:9,1);x.csi{110}.H(1,1);x.csi{110}.H(10:22,1);x.csi{110}.H(2,1);x.csi{110}.H(23:34,1);x.csi{110}.H(3,1);x.csi{110}.H(35:47,1);x.csi{110}.H(4,1);x.csi{110}.H(48:52,1)];

figure;
plot(angle(H11));
hold on;
plot(angle(H21));

figure;
plot(unwrap(angle(H11)));

figure;
plot(angle(H11./H21));

H2_0=[x.csi{110}.H(5:9,3);x.csi{110}.H(1,3);x.csi{110}.H(10:22,3);x.csi{110}.H(2,3);x.csi{110}.H(23:34,3);x.csi{110}.H(3,3);x.csi{110}.H(35:47,3);x.csi{110}.H(4,3);x.csi{110}.H(48:52,3)];
H1_0=[x.csi{110}.H(5:9,1);x.csi{110}.H(1,1);x.csi{110}.H(10:22,1);x.csi{110}.H(2,1);x.csi{110}.H(23:34,1);x.csi{110}.H(3,1);x.csi{110}.H(35:47,1);x.csi{110}.H(4,1);x.csi{110}.H(48:52,1)];

% The fact that the are similar between packets shows that these differences are due to
% noise and not multipath between the two packets. However, the angle should be
% constant across all subcarriers, showing that there are multipath/barrier
% effects taking place (which is why we were seeing that some subcarriers
% were getting better results than others).
H2_1=[x.csi{124}.H(5:9,3);x.csi{124}.H(1,3);x.csi{124}.H(10:22,3);x.csi{124}.H(2,3);x.csi{124}.H(23:34,3);x.csi{124}.H(3,3);x.csi{124}.H(35:47,3);x.csi{124}.H(4,3);x.csi{124}.H(48:52,3)];
H1_1=[x.csi{124}.H(5:9,1);x.csi{124}.H(1,1);x.csi{124}.H(10:22,1);x.csi{124}.H(2,1);x.csi{124}.H(23:34,1);x.csi{124}.H(3,1);x.csi{124}.H(35:47,1);x.csi{124}.H(4,1);x.csi{124}.H(48:52,1)];
figure;
plot(angle(H1_1./H2_1));
hold on;
plot(angle(H1_0./H2_0));


y = load('veronica_parse.mat');
f = 5.2 * 10^9;
c = 299792458;
D = .22;

figure;
theta_degrees = zeros(1,52);
for subc = 1:52
    h=unwrap(angle(y.hs(subc,1,:) ./ y.hs(subc,3,:)));
    h = h(:);
    plot(y.timestamps,h);
    first_h = mean(h(1:15));
    last_h = mean(h(end-14:end));
    theta_radians1 = acos((c/f) * first_h / (2 * pi * D));
    theta_radians2 = acos((c/f) * last_h / (2 * pi * D));
    theta_degrees(subc) = (theta_radians2 - theta_radians1) * 57.2958;
    hold on;
end

theta_degrees = abs(theta_degrees);
figure;
plot(theta_degrees,'*');
hold on;
plot(ones(1,52)*12.88);
mean(theta_degrees)