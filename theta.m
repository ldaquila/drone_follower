f = 5.2 * 10^9;
c = 299792458;
D = .22; %0.2032;
% delta_phi = -1.1254;
% 
% % x between -1 and 1, acos(x) between 0 and pi
% theta_radians = acos((c/f) * delta_phi / (2 * pi * D))
% theta_degrees = theta_radians * 57.2958

% original plot: first delta phi was 1, second delta phi was -4.38

theta_radians1 = acos((c/f) * -1.1 / (2 * pi * D))
theta_radians2 = acos((c/f) * -8.2 / (2 * pi * D))

(theta_radians2 - theta_radians1) * 57.2958