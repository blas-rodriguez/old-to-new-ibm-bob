using OldToNew.Application;
using OldToNew.Domain;

namespace OldToNew.Domain.Tests;

public sealed class IntermentRuleTests
{
    [Theory]
    [InlineData(1, 1)]
    [InlineData(3, 6)]
    public void BR_064_accepts_boundary_values(int level, int sublevel)
    {
        Assert.Null(IntermentRules.ValidateLevelAndSublevel(level, sublevel));
    }

    [Theory]
    [InlineData(0, 1)]
    [InlineData(4, 1)]
    [InlineData(1, 0)]
    [InlineData(1, 7)]
    public void BR_064_rejects_values_outside_verified_ranges(int level, int sublevel)
    {
        var violation = IntermentRules.ValidateLevelAndSublevel(level, sublevel);

        Assert.NotNull(violation);
        Assert.Equal("BR-064", violation.RuleId);
    }

    [Theory]
    [InlineData("S")]
    [InlineData("s")]
    [InlineData("T")]
    [InlineData("t")]
    public void BR_063_accepts_verified_service_types(string serviceType)
    {
        Assert.Null(IntermentRules.ValidateServiceType(serviceType));
    }

    [Theory]
    [InlineData("")]
    [InlineData("X")]
    [InlineData(null)]
    public void BR_063_rejects_unverified_service_types(string? serviceType)
    {
        var violation = IntermentRules.ValidateServiceType(serviceType);

        Assert.NotNull(violation);
        Assert.Equal("BR-063", violation.RuleId);
    }

    [Theory]
    [InlineData(IntermentPersistenceStatus.ParcelNotFound, "BR-060")]
    [InlineData(IntermentPersistenceStatus.Duplicate, "BR-061")]
    [InlineData(IntermentPersistenceStatus.PriorSublevelMissing, "BR-062")]
    public async Task Use_case_maps_persistence_checks_to_verified_rule_ids(
        IntermentPersistenceStatus status,
        string expectedRuleId)
    {
        var store = new StubIntermentStore(
            new IntermentPersistenceResult(status, MissingSublevel: 1));
        var useCase = new CreateIntermentUseCase(store);

        var result = await useCase.ExecuteAsync(ValidCommand());

        Assert.False(result.IsSuccess);
        Assert.Equal(expectedRuleId, result.RuleId);
    }

    [Fact]
    public async Task Valid_command_returns_created_result()
    {
        var store = new StubIntermentStore(
            new IntermentPersistenceResult(IntermentPersistenceStatus.Created));
        var useCase = new CreateIntermentUseCase(store);

        var result = await useCase.ExecuteAsync(ValidCommand());

        Assert.True(result.IsSuccess);
        Assert.Equal("CREATED", result.RuleId);
    }

    private static CreateIntermentCommand ValidCommand() => new(
        "D010101",
        1,
        1,
        new DateOnly(2026, 8, 20),
        "PERSONA FICTICIA TEST",
        "99000003",
        "F",
        "ACTA-DEMO-TEST",
        "I",
        0,
        new DateOnly(2026, 8, 21),
        "BOLETO-DEMO-TEST",
        "S",
        1001,
        2001);

    private sealed class StubIntermentStore(IntermentPersistenceResult result) : IIntermentStore
    {
        public Task<Parcel?> FindParcelAsync(
            string parcelCode,
            CancellationToken cancellationToken = default) =>
            Task.FromResult<Parcel?>(new Parcel(parcelCode, "D01", 1, 1, "PARCELA DEMO TEST"));

        public Task<IntermentPersistenceResult> TryCreateAsync(
            Interment interment,
            CancellationToken cancellationToken = default) =>
            Task.FromResult(result);
    }
}
