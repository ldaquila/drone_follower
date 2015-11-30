function [h,t,mac]=process_channels_lab3(fn)
    preprocess(fn);
    csi = read_channel_trace('csi_tmp.txt');
%     x = load('csi_log_for_angle.mat');
%     csi = x.csi;
    h= zeros(length(csi),2);
    t= zeros(length(csi),1); 
    mac = cell(length(csi),1);
    % save('csi_log_for_angle','csi');

    for i=1:length(csi)
            sub =-26:25;
            if ~isempty(csi{i})
                m1 = angle(csi{i}.H(5:56,1));
                slope=regress(unwrap(m1),[sub', ones(length(sub),1)]);
                h(i,1)=mean(csi{i}.H(5:56,1).*exp(-1j*slope(1)*sub')); 
                mac{i} = csi{i}.src;
                m2 = angle(csi{i}.H(5:56,3));
                slope=regress(unwrap(m2),[sub', ones(length(sub),1)]);
                h(i,2)=mean(csi{i}.H(5:56,3).*exp(-1j*slope(1)*sub')); 

                t(i) = csi{i}.timestamp;
            end
    end
    save('h_t_mac', 'h', 't', 'mac');
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