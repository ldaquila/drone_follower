x = load('h_t_mac.mat');
h = x.h;
t = x.t;
mac = x.mac;

hs = [];
times = [];
for i = 1:size(mac)
    if strcmp(mac(i), ' 78:4b:87:a2:b7:57')
        hs = [hs; h(i,1), h(i,2)];
        times = [times; t(i)];
    end
end

figure;
plot(abs(hs(:,1)));
figure;
plot(abs(hs(:,2)));

figure;

%Select h_j for subchannel 1 at all timesteps

plot(unwrap(angle(hs(:,2) ./ hs(:,1))));