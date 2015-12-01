% x = load('h_t_mac.mat');
% h = x.h;
% t = x.t;
% mac = x.mac;
% MAC_ADDR = ' 78:4b:87:a2:b7:57';
% 
% hs = [];
% times = [];
% for i = 1:size(mac)
%     if strcmp(mac(i), MAC_ADDR)
%         hs = [hs; h(i,1), h(i,2)];
%         times = [times; t(i)];
%     end
% end

MAC_ADDR = ' 78:4b:87:a2:b7:57';
MAC_ADDR = ' 14:cc:20:d0:26:7c';


hs1 = [];
times1 = [];
y = load('csi_log_for_angle.mat');
for i = 1:size(y.csi)
    if strcmp(y.csi{i}.src, MAC_ADDR)
        %hs1 = [hs1; y.csi{i}.H, y.csi{i}.H];
        %times1 = [times1; y.csi{i}.timestamp];
        H21=[y.csi{110}.H(5:9,3);y.csi{110}.H(1,3);y.csi{110}.H(10:22,3);y.csi{110}.H(2,3);y.csi{110}.H(23:34,3);y.csi{110}.H(3,3);y.csi{110}.H(35:47,3);y.csi{110}.H(4,3);y.csi{110}.H(48:52,3)];
        H11=[y.csi{110}.H(5:9,1);y.csi{110}.H(1,1);y.csi{110}.H(10:22,1);y.csi{110}.H(2,1);y.csi{110}.H(23:34,1);y.csi{110}.H(3,1);y.csi{110}.H(35:47,1);y.csi{110}.H(4,1);y.csi{110}.H(48:52,1)];
        figure;
        plot(abs(H11));
        hold on;
        plot(abs(H21));
        title('Magnitude of H11 and H21 for a single packet');
        keyboard;
    end
end



figure;
plot(abs(hs(:,1)));
figure;
plot(abs(hs(:,2)));

figure;

%Select h_j for subchannel 1 at all timesteps

plot(unwrap(angle(hs(:,2) ./ hs(:,1))));