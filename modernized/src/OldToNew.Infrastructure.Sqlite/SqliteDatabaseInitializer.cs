using Microsoft.Data.Sqlite;

namespace OldToNew.Infrastructure.Sqlite;

public sealed class SqliteDatabaseInitializer(string connectionString)
{
    public async Task InitializeAsync(CancellationToken cancellationToken = default)
    {
        await using var connection = new SqliteConnection(connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText = SchemaAndSyntheticSeedSql;
        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private const string SchemaAndSyntheticSeedSql = """
        PRAGMA foreign_keys = ON;

        CREATE TABLE IF NOT EXISTS parcels (
            Code        TEXT    NOT NULL PRIMARY KEY,
            Sector      TEXT    NOT NULL,
            RowNumber   INTEGER NOT NULL,
            PlotNumber  INTEGER NOT NULL,
            DisplayName TEXT    NOT NULL,
            UNIQUE (Sector, RowNumber, PlotNumber)
        );

        CREATE TABLE IF NOT EXISTS funeral_homes (
            Code INTEGER NOT NULL PRIMARY KEY,
            Name TEXT    NOT NULL
        );

        CREATE TABLE IF NOT EXISTS coffin_catalog (
            Code        INTEGER NOT NULL PRIMARY KEY,
            Description TEXT    NOT NULL
        );

        CREATE TABLE IF NOT EXISTS interments (
            Id                  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            ParcelCode          TEXT    NOT NULL,
            Level               INTEGER NOT NULL CHECK (Level BETWEEN 1 AND 3),
            Sublevel            INTEGER NOT NULL CHECK (Sublevel BETWEEN 1 AND 6),
            DateOfDeath         TEXT    NOT NULL,
            DeceasedName        TEXT    NOT NULL,
            Document            TEXT    NOT NULL,
            Sex                 TEXT    NOT NULL,
            RecordNumber        TEXT    NOT NULL,
            RecordType          TEXT    NOT NULL,
            TaxAmount           NUMERIC NOT NULL,
            IntermentDate       TEXT    NOT NULL,
            Ticket              TEXT    NOT NULL,
            ServiceType         TEXT    NOT NULL CHECK (ServiceType IN ('S', 'T')),
            FuneralHomeCode     INTEGER NULL,
            CoffinCode          INTEGER NULL,
            FOREIGN KEY (ParcelCode) REFERENCES parcels(Code),
            FOREIGN KEY (FuneralHomeCode) REFERENCES funeral_homes(Code),
            FOREIGN KEY (CoffinCode) REFERENCES coffin_catalog(Code),
            UNIQUE (ParcelCode, Level, Sublevel)
        );

        CREATE INDEX IF NOT EXISTS ix_interments_parcel
            ON interments (ParcelCode);

        INSERT OR IGNORE INTO parcels (Code, Sector, RowNumber, PlotNumber, DisplayName)
        VALUES
            ('D010101', 'D01', 1, 1, 'PARCELA DEMO LIBRE'),
            ('D010102', 'D01', 1, 2, 'PARCELA DEMO CON SUBNIVEL 1'),
            ('D020101', 'D02', 1, 1, 'PARCELA DEMO PARA ERROR SECUENCIAL');

        INSERT OR IGNORE INTO funeral_homes (Code, Name)
        VALUES (1001, 'COCHERIA DEMO');

        INSERT OR IGNORE INTO coffin_catalog (Code, Description)
        VALUES (2001, 'ATAUD DEMO');

        INSERT OR IGNORE INTO interments (
            ParcelCode, Level, Sublevel, DateOfDeath, DeceasedName, Document,
            Sex, RecordNumber, RecordType, TaxAmount, IntermentDate, Ticket,
            ServiceType, FuneralHomeCode, CoffinCode)
        VALUES (
            'D010102', 1, 1, '2026-08-01', 'PERSONA FICTICIA EXISTENTE', '99000001',
            'F', 'ACTA-DEMO-01', 'I', 0, '2026-08-02', 'BOLETO-DEMO-01',
            'S', 1001, 2001);
        """;
}
