using OldToNew.Domain;

namespace OldToNew.Application;

public sealed class GetParcelUseCase(IIntermentStore store)
{
    public Task<Parcel?> ExecuteAsync(string parcelCode, CancellationToken cancellationToken = default) =>
        store.FindParcelAsync(parcelCode.Trim().ToUpperInvariant(), cancellationToken);
}
