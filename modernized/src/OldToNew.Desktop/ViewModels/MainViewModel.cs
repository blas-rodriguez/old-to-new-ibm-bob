using System.Globalization;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using OldToNew.Application;

namespace OldToNew.Desktop.ViewModels;

public partial class MainViewModel(
    GetParcelUseCase getParcel,
    CreateIntermentUseCase createInterment) : ViewModelBase
{
    public IReadOnlyList<string> ServiceTypeOptions { get; } = ["S", "T"];
    public IReadOnlyList<string> SexOptions { get; } = ["F", "M"];

    [ObservableProperty]
    public partial string ParcelCode { get; set; } = "D010101";

    [ObservableProperty]
    public partial string ParcelSummary { get; set; } = "Search a synthetic parcel to begin.";

    [ObservableProperty]
    public partial string LevelText { get; set; } = "1";

    [ObservableProperty]
    public partial string SublevelText { get; set; } = "1";

    [ObservableProperty]
    public partial DateTimeOffset? DateOfDeath { get; set; } =
        new(2026, 8, 20, 0, 0, 0, TimeSpan.Zero);

    [ObservableProperty]
    public partial string DeceasedName { get; set; } = "PERSONA FICTICIA NUEVA";

    [ObservableProperty]
    public partial string Document { get; set; } = "99000002";

    [ObservableProperty]
    public partial string Sex { get; set; } = "F";

    [ObservableProperty]
    public partial string RecordNumber { get; set; } = "ACTA-DEMO-02";

    [ObservableProperty]
    public partial string RecordType { get; set; } = "I";

    [ObservableProperty]
    public partial string TaxAmountText { get; set; } = "0";

    [ObservableProperty]
    public partial DateTimeOffset? IntermentDate { get; set; } =
        new(2026, 8, 21, 0, 0, 0, TimeSpan.Zero);

    [ObservableProperty]
    public partial string Ticket { get; set; } = "BOLETO-DEMO-02";

    [ObservableProperty]
    public partial string ServiceType { get; set; } = "S";

    [ObservableProperty]
    public partial string FuneralHomeCodeText { get; set; } = "1001";

    [ObservableProperty]
    public partial string CoffinCodeText { get; set; } = "2001";

    [ObservableProperty]
    public partial string StatusMessage { get; set; } =
        "Ready. This prototype accepts synthetic demo data only.";

    [ObservableProperty]
    public partial bool IsBusy { get; set; }

    [RelayCommand]
    private async Task FindParcelAsync()
    {
        if (IsBusy)
        {
            return;
        }

        IsBusy = true;
        try
        {
            var parcel = await getParcel.ExecuteAsync(ParcelCode);
            ParcelSummary = parcel is null
                ? "BR-060: Parcel not found. Try D010101, D010102, or D020101."
                : $"{parcel.Code} · Sector {parcel.Sector} · Row {parcel.RowNumber:00} · Plot {parcel.PlotNumber:00}\n{parcel.DisplayName}";
        }
        finally
        {
            IsBusy = false;
        }
    }

    [RelayCommand]
    private async Task CreateIntermentAsync()
    {
        if (IsBusy)
        {
            return;
        }

        if (!TryBuildCommand(out var command, out var inputError))
        {
            StatusMessage = $"INPUT: {inputError}";
            return;
        }

        IsBusy = true;
        try
        {
            var result = await createInterment.ExecuteAsync(command!);
            StatusMessage = $"{result.RuleId}: {result.Message}";
        }
        finally
        {
            IsBusy = false;
        }
    }

    private bool TryBuildCommand(
        out CreateIntermentCommand? command,
        out string error)
    {
        command = null;

        if (!int.TryParse(LevelText, NumberStyles.Integer, CultureInfo.InvariantCulture, out var level) ||
            !int.TryParse(SublevelText, NumberStyles.Integer, CultureInfo.InvariantCulture, out var sublevel))
        {
            error = "Level and sublevel must be whole numbers.";
            return false;
        }

        if (!decimal.TryParse(TaxAmountText, NumberStyles.Number, CultureInfo.InvariantCulture, out var taxAmount))
        {
            error = "Tax amount must be numeric.";
            return false;
        }

        if (!TryParseOptionalCode(FuneralHomeCodeText, out var funeralHomeCode) ||
            !TryParseOptionalCode(CoffinCodeText, out var coffinCode))
        {
            error = "Funeral-home and coffin codes must be whole numbers or blank.";
            return false;
        }

        if (DateOfDeath is null || IntermentDate is null)
        {
            error = "Both dates are required for this demo form.";
            return false;
        }

        command = new CreateIntermentCommand(
            ParcelCode,
            level,
            sublevel,
            DateOnly.FromDateTime(DateOfDeath.Value.DateTime),
            DeceasedName,
            Document,
            Sex,
            RecordNumber,
            RecordType,
            taxAmount,
            DateOnly.FromDateTime(IntermentDate.Value.DateTime),
            Ticket,
            ServiceType,
            funeralHomeCode,
            coffinCode);
        error = string.Empty;
        return true;
    }

    private static bool TryParseOptionalCode(string value, out int? result)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            result = null;
            return true;
        }

        if (int.TryParse(value, NumberStyles.Integer, CultureInfo.InvariantCulture, out var parsed))
        {
            result = parsed;
            return true;
        }

        result = null;
        return false;
    }
}
