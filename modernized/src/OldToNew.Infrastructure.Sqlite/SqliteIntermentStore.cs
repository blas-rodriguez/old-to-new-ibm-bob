using System.Globalization;
using Microsoft.Data.Sqlite;
using OldToNew.Application;
using OldToNew.Domain;

namespace OldToNew.Infrastructure.Sqlite;

public sealed class SqliteIntermentStore(string connectionString) : IIntermentStore
{
    public async Task<Parcel?> FindParcelAsync(
        string parcelCode,
        CancellationToken cancellationToken = default)
    {
        await using var connection = new SqliteConnection(connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText = """
            SELECT Code, Sector, RowNumber, PlotNumber, DisplayName
            FROM parcels
            WHERE Code = $code;
            """;
        command.Parameters.AddWithValue("$code", parcelCode.Trim().ToUpperInvariant());

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        return await reader.ReadAsync(cancellationToken)
            ? new Parcel(
                reader.GetString(0),
                reader.GetString(1),
                reader.GetInt32(2),
                reader.GetInt32(3),
                reader.GetString(4))
            : null;
    }

    public async Task<IntermentPersistenceResult> TryCreateAsync(
        Interment interment,
        CancellationToken cancellationToken = default)
    {
        await using var connection = new SqliteConnection(connectionString);
        await connection.OpenAsync(cancellationToken);
        await using var transaction = connection.BeginTransaction();

        try
        {
            if (!await ParcelExistsAsync(connection, transaction, interment.ParcelCode, cancellationToken))
            {
                return new IntermentPersistenceResult(IntermentPersistenceStatus.ParcelNotFound);
            }

            if (await IntermentExistsAsync(connection, transaction, interment, cancellationToken))
            {
                return new IntermentPersistenceResult(IntermentPersistenceStatus.Duplicate);
            }

            var existingSublevels = await GetExistingSublevelsAsync(
                connection,
                transaction,
                interment.ParcelCode,
                interment.Level,
                cancellationToken);

            for (var expected = 1; expected < interment.Sublevel; expected++)
            {
                if (!existingSublevels.Contains(expected))
                {
                    return new IntermentPersistenceResult(
                        IntermentPersistenceStatus.PriorSublevelMissing,
                        expected);
                }
            }

            await InsertAsync(connection, transaction, interment, cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return new IntermentPersistenceResult(IntermentPersistenceStatus.Created);
        }
        catch (SqliteException exception) when (
            exception.SqliteErrorCode == 19 && exception.SqliteExtendedErrorCode == 2067)
        {
            return new IntermentPersistenceResult(IntermentPersistenceStatus.Duplicate);
        }
        catch (SqliteException exception) when (exception.SqliteErrorCode == 19)
        {
            return new IntermentPersistenceResult(
                IntermentPersistenceStatus.StorageFailure,
                Detail: "A synthetic lookup or database constraint rejected the record.");
        }
        catch (SqliteException)
        {
            return new IntermentPersistenceResult(
                IntermentPersistenceStatus.StorageFailure,
                Detail: "The local synthetic SQLite database could not save the record.");
        }
    }

    private static async Task<bool> ParcelExistsAsync(
        SqliteConnection connection,
        SqliteTransaction transaction,
        string parcelCode,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText = "SELECT EXISTS(SELECT 1 FROM parcels WHERE Code = $code);";
        command.Parameters.AddWithValue("$code", parcelCode);
        return Convert.ToInt32(await command.ExecuteScalarAsync(cancellationToken), CultureInfo.InvariantCulture) == 1;
    }

    private static async Task<bool> IntermentExistsAsync(
        SqliteConnection connection,
        SqliteTransaction transaction,
        Interment interment,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText = """
            SELECT EXISTS(
                SELECT 1 FROM interments
                WHERE ParcelCode = $parcel AND Level = $level AND Sublevel = $sublevel
            );
            """;
        command.Parameters.AddWithValue("$parcel", interment.ParcelCode);
        command.Parameters.AddWithValue("$level", interment.Level);
        command.Parameters.AddWithValue("$sublevel", interment.Sublevel);
        return Convert.ToInt32(await command.ExecuteScalarAsync(cancellationToken), CultureInfo.InvariantCulture) == 1;
    }

    private static async Task<HashSet<int>> GetExistingSublevelsAsync(
        SqliteConnection connection,
        SqliteTransaction transaction,
        string parcelCode,
        int level,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText = """
            SELECT Sublevel
            FROM interments
            WHERE ParcelCode = $parcel AND Level = $level;
            """;
        command.Parameters.AddWithValue("$parcel", parcelCode);
        command.Parameters.AddWithValue("$level", level);

        var values = new HashSet<int>();
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            values.Add(reader.GetInt32(0));
        }

        return values;
    }

    private static async Task InsertAsync(
        SqliteConnection connection,
        SqliteTransaction transaction,
        Interment interment,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText = """
            INSERT INTO interments (
                ParcelCode, Level, Sublevel, DateOfDeath, DeceasedName, Document,
                Sex, RecordNumber, RecordType, TaxAmount, IntermentDate, Ticket,
                ServiceType, FuneralHomeCode, CoffinCode)
            VALUES (
                $parcel, $level, $sublevel, $dateOfDeath, $name, $document,
                $sex, $recordNumber, $recordType, $taxAmount, $intermentDate, $ticket,
                $serviceType, $funeralHomeCode, $coffinCode);
            """;

        command.Parameters.AddWithValue("$parcel", interment.ParcelCode);
        command.Parameters.AddWithValue("$level", interment.Level);
        command.Parameters.AddWithValue("$sublevel", interment.Sublevel);
        command.Parameters.AddWithValue("$dateOfDeath", interment.DateOfDeath.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture));
        command.Parameters.AddWithValue("$name", interment.DeceasedName);
        command.Parameters.AddWithValue("$document", interment.Document);
        command.Parameters.AddWithValue("$sex", interment.Sex);
        command.Parameters.AddWithValue("$recordNumber", interment.RecordNumber);
        command.Parameters.AddWithValue("$recordType", interment.RecordType);
        command.Parameters.AddWithValue("$taxAmount", interment.TaxAmount);
        command.Parameters.AddWithValue("$intermentDate", interment.IntermentDate.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture));
        command.Parameters.AddWithValue("$ticket", interment.Ticket);
        command.Parameters.AddWithValue("$serviceType", interment.ServiceType);
        command.Parameters.AddWithValue("$funeralHomeCode", (object?)interment.FuneralHomeCode ?? DBNull.Value);
        command.Parameters.AddWithValue("$coffinCode", (object?)interment.CoffinCode ?? DBNull.Value);

        await command.ExecuteNonQueryAsync(cancellationToken);
    }
}
