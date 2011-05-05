% Fit Spline function for fitting 2D spline surface to data

function [PositionData] = FitSpline(PositionData, Rows, Columns, Deformations)

[SizeY, SizeX] = size(PositionData);

%if sum(Deformations) == 0
%    return 
%end

DeformationData = zeros(SizeY, SizeX);
ColumnsList = [];

for IteratorX = 1:SizeX
    IndexInColumns = find(uint8(Columns) == IteratorX);
    if ~isempty(IndexInColumns)
        ColumnsList = [ColumnsList IteratorX];
        TempRows = Rows(IndexInColumns);
        TempDeformations = Deformations(IndexInColumns);
        FittedSpline = spline(TempRows, TempDeformations, 1:SizeY);
        DeformationData(:,IteratorX) = FittedSpline';
    end
end

for IteratorY = 1:SizeY
        TempColumns = ColumnsList;
        TempDeformations = DeformationData(IteratorY, TempColumns);
        FittedSpline = spline(TempColumns, TempDeformations, 1:SizeX);
        DeformationData(IteratorY,:) = FittedSpline;
end

PositionData = PositionData + DeformationData;

end