close all
clear all
G=config();
G=config_run_MinnesotaLab(G);
%G=config_run_monowar_Memphis_Smoking(G);
PS_LIST=G.PS_LIST;
puff_numm=3;

for puff_numm=2:4
    file_name = ['LapseDay_smoking_epi_time_' num2str(puff_numm) 'puffs_1.csv'];
fid=fopen(file_name,'w');

% fid=fopen(['false_epi__summary_' puff_numm '_puff.csv'],'w');
    for pp=1:size(PS_LIST,1)
        pid=char(PS_LIST{pp,1});
        slist=PS_LIST{pp,2};
        for s=slist
            sid=char(s);
             ssid=str2num(sid(2:end));
             if (ssid ==01 | ssid ==2)
                 fprintf(fid,'%s,%s,\n',pid,sid);
                 continue;
             end
             
            fprintf('pid=%s sid=%s :: ',pid,sid);
%             fprintf(fid,'%s,%s,',pid,sid);
            INDIR='svm_output';indir=[G.DIR.DATA G.DIR.SEP INDIR];infile=[pid '_' sid '_' INDIR '.mat'];if exist([indir G.DIR.SEP infile],'file')~=2,return;end;load([indir G.DIR.SEP infile]);

            lapse_time=0;

            for i=1:2
                print_str='';

                epi_count=0;            
                previous_epi_time=0;
             
                indc = find(P.wrist{i}.gyr.segment.svm_predict==1);
                if length(indc)==0
                    continue;
                end
                timestamps =  P.wrist{i}.gyr.segment.starttimestamp(indc);

                for j=1:(length(timestamps)-puff_numm+1)
                    t1=timestamps(j);
                    t2=timestamps(j+puff_numm-1);
                    if (t2-t1) <puff_numm*60*1000 & (t1-previous_epi_time) >5*60*1000
                        epi_count = epi_count+1;
                        previous_epi_time=t2;
                        if lapse_time == 0 
                            lapse_time = t1;
                        end
                        cc=convert_timestamp_time(G,t1);
                        if t1==0
                            cc='0';
                        end
                        print_str=[print_str ',' num2str(t1) ',' cc];
             
                    end                
                end
                lapse_date_time = convert_timestamp_time(G,lapse_time);
                if(lapse_time == 0)
                    lapse_date_time ='0';
                end
                fprintf('(%d: lapse_time=%s epi_count=%d)',i,lapse_date_time,epi_count);
%                  fprintf(fid,'%d,%s,%d,',i,lapse_date_time,epi_count);
   fprintf(fid,[pid ',' sid ',' num2str(i) ',' num2str(epi_count) ',' print_str]);
             fprintf(fid,'\n');
            end
                fprintf('\n');
               

    %         disp('abc');
        end
        disp('');
    end
     fclose(fid);
end