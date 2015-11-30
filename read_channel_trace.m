function csi = read_channel_trace(filename)
    parsed = xml2struct(filename);
    csi = cell(length(parsed.csi_info.packet),1);
    for i=1:length(parsed.csi_info.packet)
        if(isfield(parsed.csi_info.packet{i},'csi'))
            csi{i} = read_packet(parsed.csi_info.packet{i});
            if(mod(i,100)==0)
                fprintf('Processed %d of %d packets\n',i,length(parsed.csi_info.packet));
            end
        end
    end
    
end

function csi= read_packet(packet)
    csi.dest = packet.destination.Text;
    csi.src = packet.source.Text;
    csi.mode = packet.mode.Text;
    csi.timestamp = str2double(packet.timestamp.Text);
    a = regexp(packet.csi.Text,'\n','split');
    H=[];
    for i=1:length(a)        
        h1=[];
        t = regexp(a{i},',','split');
        if(length(t)>3)
            for j=1:length(t)
                h1 = [h1,str2double(t{j})];
            end
        end
        H = [H;h1];
    end
    csi.H = H;
    
end