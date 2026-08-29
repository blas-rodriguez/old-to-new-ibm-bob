using OldToNew.Domain;

namespace OldToNew.Application;

public sealed class CreateIntermentUseCase(IIntermentStore store)
{
    public async Task<CreateIntermentResult> ExecuteAsync(
        CreateIntermentCommand command,
        CancellationToken cancellationToken = default)
    {
        var normalizedParcelCode = command.ParcelCode.Trim().ToUpperInvariant();
        if (await store.FindParcelAsync(normalizedParcelCode, cancellationToken) is null)
        {
            return CreateIntermentResult.Rejected(
                "BR-060",
                "Parcel code does not exist. Verify the synthetic parcel and try again.");
        }

        var rangeViolation = IntermentRules.ValidateLevelAndSublevel(command.Level, command.Sublevel);
        if (rangeViolation is not null)
        {
            return CreateIntermentResult.Rejected(rangeViolation.RuleId, rangeViolation.Message);
        }

        var serviceViolation = IntermentRules.ValidateServiceType(command.ServiceType);
        if (serviceViolation is not null)
        {
            return CreateIntermentResult.Rejected(serviceViolation.RuleId, serviceViolation.Message);
        }

        var interment = new Interment(
            normalizedParcelCode,
            command.Level,
            command.Sublevel,
            command.DateOfDeath,
            command.DeceasedName.Trim(),
            command.Document.Trim(),
            command.Sex.Trim().ToUpperInvariant(),
            command.RecordNumber.Trim(),
            command.RecordType.Trim().ToUpperInvariant(),
            command.TaxAmount,
            command.IntermentDate,
            command.Ticket.Trim().ToUpperInvariant(),
            command.ServiceType.Trim().ToUpperInvariant(),
            command.FuneralHomeCode,
            command.CoffinCode);

        var persistence = await store.TryCreateAsync(interment, cancellationToken);
        return persistence.Status switch
        {
            IntermentPersistenceStatus.Created => CreateIntermentResult.Success(),
            IntermentPersistenceStatus.ParcelNotFound => CreateIntermentResult.Rejected(
                "BR-060",
                "Parcel code does not exist. Verify the synthetic parcel and try again."),
            IntermentPersistenceStatus.Duplicate => CreateIntermentResult.Rejected(
                "BR-061",
                "An interment already exists for this parcel, level, and sublevel."),
            IntermentPersistenceStatus.PriorSublevelMissing => CreateIntermentResult.Rejected(
                "BR-062",
                $"Sublevel {persistence.MissingSublevel} must be created first."),
            _ => CreateIntermentResult.Rejected(
                "TARGET-STORAGE",
                persistence.Detail ?? "The synthetic database rejected the operation."),
        };
    }
}
