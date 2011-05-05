function save_deformed_mhd(origfilename, newfilename, image)

  %%save new .mhd header
  origheader = fopen(strcat(origfilename,'.mhd'), 'r');
  newheader = fopen(strcat(newfilename,'.mhd'), 'w');

  while(~feof(origheader))
      line = fgetl(origheader);
      param = strtok(line,' = ');
      if (strcmp(param,'ElementDataFile') == 1)
          [path,rest] = strtok(newfilename,'/');
          newfname = strtok(rest,'/');
          fprintf(newheader,'%s %s %s\r\n',['ElementDataFile = ',newfname,'.raw']);
      else
          fprintf(newheader,'%s\r\n',line);
      end
  end
  
  fclose(newheader);
  fclose(origheader);
  
  
  %%save raw data
  fid = fopen(strcat(newfilename,'.raw'),'w');
  fwrite(fid, image, 'uint16');
  fclose(fid);
  


end