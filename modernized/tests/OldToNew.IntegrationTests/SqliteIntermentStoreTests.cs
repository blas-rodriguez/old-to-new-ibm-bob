using OldToNew.Application;
using OldToNew.Domain;
using OldToNew.Infrastructure.Sqlite;

namespace OldToNew.IntegrationTests;

public sealed class SqliteIntermentStoreTests : IAsyncLifetime
{
    private readonly string _databasePath;
    private readonly string _connectionString;
    private SqliteIntermentStore _store = null!;

    public SqliteIntermentStoreTests()
    {
        var testDataDirectory = Path.Combine(AppContext.BaseDirectory, "test-data");
        Directory.CreateDirectory(testDataDirectory);
        _databasePath = Path.Combine(testDataDirectory, $"interment-{Guid.NewGuid():N}.db");
        _connectionString = SqliteDatabase.BuildConnectionString(_databasePath);
    }

    public async Task InitializeAsync()
    {
        await new SqliteDatabaseInitializer(_connectionString).InitializeAsync();
        _store = new SqliteIntermentStore(_connectionString);
    }

    public Task DisposeAsync()
    {
        if (File.Exists(_databasePath))
        {
            File.Delete(_databasePath);
        }

        return Task.CompletedTask;
    }

    [Fact]
    public async Task BR_060_rejects_a_missing_parcel()
    {
        var result = await _store.TryCreateAsync(ValidInterment("Z999999", 1, 1));

        Assert.Equal(IntermentPersistenceStatus.ParcelNotFound, result.Status);
    }

    [Fact]
    public async Task BR_061_rejects_duplicate_parcel_level_and_sublevel()
    {
        var result = await _store.TryCreateAsync(ValidInterment("D010102", 1, 1));

        Assert.Equal(IntermentPersistenceStatus.Duplicate, result.Status);
    }

    [Fact]
    public async Task BR_062_rejects_a_gap_without_leaving_a_partial_row()
    {
        var rejected = await _store.TryCreateAsync(ValidInterment("D020101", 1, 2));
        var first = await _store.TryCreateAsync(ValidInterment("D020101", 1, 1));
        var second = await _store.TryCreateAsync(ValidInterment("D020101", 1, 2));

        Assert.Equal(IntermentPersistenceStatus.PriorSublevelMissing, rejected.Status);
        Assert.Equal(1, rejected.MissingSublevel);
        Assert.Equal(IntermentPersistenceStatus.Created, first.Status);
        Assert.Equal(IntermentPersistenceStatus.Created, second.Status);
    }

    [Fact]
    public async Task Verified_happy_path_creates_the_first_sublevel()
    {
        var result = await _store.TryCreateAsync(ValidInterment("D010101", 1, 1));

        Assert.Equal(IntermentPersistenceStatus.Created, result.Status);
        var duplicate = await _store.TryCreateAsync(ValidInterment("D010101", 1, 1));
        Assert.Equal(IntermentPersistenceStatus.Duplicate, duplicate.Status);
    }

    private static Interment ValidInterment(string parcelCode, int level, int sublevel) => new(
        parcelCode,
        level,
        sublevel,
        new DateOnly(2026, 8, 20),
        "PERSONA FICTICIA INTEGRACION",
        "99000004",
        "F",
        "ACTA-DEMO-INTEGRACION",
        "I",
        0,
        new DateOnly(2026, 8, 21),
        "BOLETO-DEMO-INTEGRACION",
        "S",
        1001,
        2001);
}
