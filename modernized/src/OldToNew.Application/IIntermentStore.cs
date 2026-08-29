using OldToNew.Domain;

namespace OldToNew.Application;

public interface IIntermentStore
{
    Task<Parcel?> FindParcelAsync(string parcelCode, CancellationToken cancellationToken = default);

    Task<IntermentPersistenceResult> TryCreateAsync(
        Interment interment,
        CancellationToken cancellationToken = default);
}
