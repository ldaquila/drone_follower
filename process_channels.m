function process_channels(filePath, MAC)
    MODE = '0x140';
    %number of subchannels
    nSubChannels = 52;

    %% Load the data
    data = importdata(filePath);
    data = data';

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
            % whether or not to process this packet
            processPacket = strcmp(source,MAC);
            continue;
        end
        
        %Check mode
        if findstr(line, '<mode>')
            pattern = '0x[0-9]*';
            mode_ = char(regexpi(line, pattern, 'match'));
            %whether or not to process this packet
            processPacket = strcmp(mode_, MODE);
            if processPacket
                %initialize h
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
                if i > 4 % skip pilots
                    h(i-4,ind) = eval(char(line(ind)));
                end
            end
            continue;
        end

        %End of packet: save packet values
        if findstr(line,'</packet>,')
            timestamps = [timestamps timestamp];
            % hs is 3 dimensional. First dimension is number of subchannels.
            % Second dimension is number of h_ijs (4). Third dimensions is
            % number of packets from the Edison.
            hs = cat(3, hs, h);
        end
    end

%     timestamps = (timestamps - timestamps(1))/10^3;

    save('our_process_separate','hs','timestamps');

%     %% Plot
%     hold('on')
% 
%     % Plot the magnitude for each of the packets as a function of the
%     % subcarrier.
%     for j = [1,3]
%         figure
%         %Select h_j for subchannel 1 at all timesteps
%         for subc = 1:nSubChannels
%             h = squeeze(abs(hs(:,j,:)));
%             plot(timestamps,h,'color',rand(1,3))
%         end
%         xlabel('time (s)')
%         ylabel(['|h_',num2str(j),'|'])
%         title(['Left to Right Movement |h_',num2str(j),'| for each subchannel']);
%     end
% 
%     figure
%     %Select h_j for subchannel 1 at all timesteps
%     for i = 1:nSubChannels
%         h = squeeze(angle(hs(:,1,:)))-squeeze(angle(hs(:,3,:)));
%         plot(timestamps,h,'color',rand(1,3))
%     end
%     xlabel('time (s)')
%     ylabel(['h_1/h_3'])
%     title(['Left to Right Movement phase ratio for each subchannel']);
end

