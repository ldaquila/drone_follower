function [h,t,mac]=process_channels_lab3(fn, MAC_ADDR)
    preprocess(fn);
    csi = read_channel_trace('csi_tmp.txt');
    h= zeros(length(csi),2);
    t= zeros(length(csi),1); 
    mac = cell(length(csi),1);
    
    % Add a space
    MAC_ADDR = [' ' MAC_ADDR];
    csi_filtered = {};
    for i=1:length(csi)
            sub =-26:25;
            if ~isempty(csi{i}) && strcmp(csi{i}.src, MAC_ADDR)
                m1 = angle(csi{i}.H(5:56,1));
                slope=regress(unwrap(m1),[sub', ones(length(sub),1)]);
                h(i,1)=mean(csi{i}.H(5:56,1).*exp(-1j*slope(1)*sub')); 
                mac{i} = csi{i}.src;
                m2 = angle(csi{i}.H(5:56,3));
                slope=regress(unwrap(m2),[sub', ones(length(sub),1)]);
                h(i,2)=mean(csi{i}.H(5:56,3).*exp(-1j*slope(1)*sub')); 

                t(i) = csi{i}.timestamp;
                
                csi_filtered{end+1} = csi{i};
            end
    end

    hs = [];
    ts = [];
    for i = 1:size(mac)
        if strcmp(mac(i), MAC_ADDR)
            hs = [hs; h(i,1), h(i,2)];
            ts = [ts; t(i)];
        end
    end
    save('lab3_process_combined', 'hs', 'ts');
    save('lab3_process_separate','csi_filtered');
end

function a= preprocess(fn)
    fid = fopen(fn);
    fout = fopen('csi_tmp.txt','w');
    fprintf(fout,'<csi_info>\n');
    str='';
    while(true)
        l = fgetl(fid);
        if(l==-1)
            break;
        end
        str = strcat(str,'\n',l);
        if(strcmp(l,'</packet>'))
            fprintf(fout,str);
            str='';
        end
    end
    a=1;
    fprintf(fout,'</csi_info>');   
    fclose(fout);
    fclose(fid);
end