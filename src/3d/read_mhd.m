function v=read_mhd(filename)
%for now only deals with 3D, byte data type, one file of raw data

%NDims = 3
%DimSize = 256  320  128
%ElementType = MET_UCHAR
%HeaderSize = -1
%ElementSize = 0.66 0.66 0.66
%ElementByteOrderMSB = False
%ElementDataFile = mrt8_angio2.raw
if(nargin==0)
    [f p] = uigetfile('*.mhd');
    filename = [p f];
end

header = fopen(filename,'r');
path = strtok(filename,'/');

while(~feof(header))
    c = fgetl(header);
    dimSizeStr = 'DimSize = ';
    if(length(c)>length(dimSizeStr))
        if(dimSizeStr == c(1:length(dimSizeStr)) )
            dimSize = str2num(c(length(dimSizeStr)+1:end));
        end
    end

    eDataFileStr = 'ElementDataFile = ';
    if(length(c)>length(eDataFileStr))
        if(eDataFileStr == c(1:length(eDataFileStr)))
            volFileName = c(length(eDataFileStr)+1:end);
        end
    end
    %use fgetl  (or fgets) to:
    %	read the line that contains "DimSize"
    %	read the line that "ElementDataFile"
    %get the three dimension values (%matlab's fscanf?) --> XYZ
    %get the name of the raw file -> FILENAME
    %(here can read ElementType and switch-case)

    %then ....
end
fclose(header)
X = dimSize(1);
Y = dimSize(2);
Z = dimSize(3);
fd=fopen(strcat(path,'/',volFileName));
v=fread(fd,X*Y*Z,'ushort');  %'uchar'? see help fread
v=reshape(v,[X Y Z]);
fclose(fd)