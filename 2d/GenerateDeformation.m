% Generates Deformation Field
% Add coordinates in the InitialList and FinalList

function [Rows, Columns, XDeformations, YDeformations] = GenerateDeformation(IndexList, PositionList)

if isempty(IndexList)
    return
else
    [DimY, DimX] = size(IndexList);
    Rows            = IndexList(1:2:DimX);
    Columns         = IndexList(2:2:DimX);
    XDeformations   = PositionList(1:2:DimX)-IndexList(1:2:DimX);
    YDeformations   = PositionList(2:2:DimX)-IndexList(2:2:DimX);
end

return