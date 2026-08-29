namespace OldToNew.Application;

public enum IntermentPersistenceStatus
{
    Created,
    ParcelNotFound,
    Duplicate,
    PriorSublevelMissing,
    StorageFailure,
}

public sealed record IntermentPersistenceResult(
    IntermentPersistenceStatus Status,
    int? MissingSublevel = null,
    string? Detail = null);
