namespace OldToNew.Domain;

public sealed record Interment(
    string ParcelCode,
    int Level,
    int Sublevel,
    DateOnly DateOfDeath,
    string DeceasedName,
    string Document,
    string Sex,
    string RecordNumber,
    string RecordType,
    decimal TaxAmount,
    DateOnly IntermentDate,
    string Ticket,
    string ServiceType,
    int? FuneralHomeCode,
    int? CoffinCode);
