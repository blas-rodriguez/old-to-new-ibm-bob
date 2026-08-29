using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Markup.Xaml;
using OldToNew.Application;
using OldToNew.Desktop.ViewModels;
using OldToNew.Desktop.Views;
using OldToNew.Infrastructure.Sqlite;

namespace OldToNew.Desktop;

public partial class App : Avalonia.Application
{
    public override void Initialize()
    {
        AvaloniaXamlLoader.Load(this);
    }

    public override void OnFrameworkInitializationCompleted()
    {
        if (ApplicationLifetime is IClassicDesktopStyleApplicationLifetime desktop)
        {
            var dataDirectory = Path.Combine(AppContext.BaseDirectory, "data");
            Directory.CreateDirectory(dataDirectory);
            var databasePath = Path.Combine(dataDirectory, "old-to-new-synthetic.db");
            var connectionString = SqliteDatabase.BuildConnectionString(databasePath);

            var initializer = new SqliteDatabaseInitializer(connectionString);
            initializer.InitializeAsync().GetAwaiter().GetResult();

            var store = new SqliteIntermentStore(connectionString);
            desktop.MainWindow = new MainWindow
            {
                DataContext = new MainViewModel(
                    new GetParcelUseCase(store),
                    new CreateIntermentUseCase(store)),
            };
        }

        base.OnFrameworkInitializationCompleted();
    }
}
