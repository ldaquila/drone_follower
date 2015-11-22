%File path
filePath = 'Desktop/csi_log_lr.txt'
%MAC address of edison
EDISON = '78:4b:87:a0:16:6d';
%number of subchannels
nSubChannels = 52;


%% Load the data
% data = importdata(filePath);
% data = data';

%% Initialize values
%Channel values matrix: subchannel, h_j, timestep
hs = [];
timestamps = [];
processPacket = false;

%% Process the file
for cell = data
    line = char(cell);
    
    % New packet
    if findstr(line,'<packet>')
        processPacket = true;
        continue;
    end
    % Not an edison packet, skip this line
    if ~processPacket
        continue
    end
    
    % Get the timestamp
    if findstr(line,'<timestamp>')
        pattern = '[0-9]*';
        timestamp = str2num(char(regexp(line, pattern, 'match')));
        continue;
    end
    % Check source MAC address
    if findstr(line,'<source>')
        pattern = '([0-9A-Fa-f]{1,2}[:]){5}([0-9A-Fa-f]{1,2})';
        source = char(regexpi(line, pattern, 'match'));
        processPacket = strcmp(source,EDISON);
        if processPacket
            h = zeros(nSubChannels,4); 
            i = 0;
        end
        continue;
    end
            
    % Add subchannel values to h matrix
    if findstr(line,'j,')
        i = i + 1;
        line = strsplit(line,',');
        for ind = 1:max(size(line))
            h(i,ind) = eval(char(line(ind)));
        end
        continue;
    end
    
    %End of packet: save packet values
    if findstr(line,'</packet>,')
        timestamps = [timestamps timestamp];
        hs = cat(3, hs, h);
    end
end

timestamps = (timestamps - timestamps(1))/10^3;

%% Plot
hold('on')

for j = [1,3]
    figure
    %Select h_j for subchannel 1 at all timesteps
    for i = 1:nSubChannels
        h = squeeze(abs(hs(:,j,:)));
        plot(timestamps,h,'color',rand(1,3))
    end
    xlabel('time (s)')
    ylabel(['|h_',num2str(j),'|'])
    title(['Left to Right Movement |h_',num2str(j),'| for each subchannel']);
end

figure
%Select h_j for subchannel 1 at all timesteps
for i = 1:nSubChannels
    h = squeeze(angle(hs(:,1,:)))-squeeze(angle(hs(:,3,:)));
    plot(timestamps,h,'color',rand(1,3))
end
xlabel('time (s)')
ylabel(['h_1/h_3'])
title(['Left to Right Movement phase ratio for each subchannel']);

