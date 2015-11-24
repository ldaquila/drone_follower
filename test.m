% for j = 1
%     figure
%     %Select h_j for subchannel 1 at all timesteps
%     for subc = 1:10
%         h = squeeze(abs(hs(subc,j,:)));
%         plot(timestamps',h,'color',rand(1,3))
%         hold on;
%     end
%     xlabel('time (s)')
%     ylabel(['|h_',num2str(j),'|'])
%     title(['Left to Right Movement |h_',num2str(j),'| for each subchannel']);
% end

% figure;
% axis([0 35 -4 4]);
% %Select h_j for subchannel 1 at all timesteps
% for subc = 30:31
%     subc
%     keyboard;
%     %h = squeeze(angle(hs(subc,1,:)))/squeeze(angle(hs(subc,3,:)));
%     h=angle(hs(subc,1,:) ./ hs(subc,3,:));
%     h = h(:);
%     plot(timestamps,h);%,'color',rand(1,3));
%     hold on;
% end
% xlabel('time (s)')
% ylabel(['h_1/h_3'])
% title(['Phase ratio for each subchannel']);

figure;
axis([0 35 -4 4]);
%Select h_j for subchannel 1 at all timesteps
for packet = 1:80
    h=angle(hs(:,1,packet) ./ hs(:,3,packet));
    plot(1:nSubChannels,h);%,'color',rand(1,3));
    hold on;
end
xlabel('Subcarrier Index')
ylabel(['h_1/h_3'])
title(['Phase Ratios for Packets (Each Line is a Different Packet)']);