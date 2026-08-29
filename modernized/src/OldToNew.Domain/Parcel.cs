namespace OldToNew.Domain;

public sealed record Parcel(
    string Code,
    string Sector,
    int RowNumber,
    int PlotNumber,
    string DisplayName);
