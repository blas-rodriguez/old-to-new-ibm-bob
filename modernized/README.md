# Old to New — WF-004 Proof of Concept

This is a manual post-Bob-budget implementation of the Gate-3-approved
**WF-004 New Inhumation** workflow. It implements only:

- BR-060 — parcel must exist;
- BR-061 — parcel/level/sublevel must not already exist;
- BR-062 — prior sublevels must exist;
- BR-063 — service type is `S` or `T`;
- BR-064 — level 1–3 and sublevel 1–6.

BR-065 and every other legacy workflow are out of scope.

## Safety

- The application uses its own SQLite database below the build output.
- It never reads or writes the root legacy PRG/DBF files.
- All seeded values are visibly synthetic.
- No production or network connection is used at runtime.

## Build and test

```powershell
dotnet restore OldToNew.sln
dotnet build OldToNew.sln --no-restore
dotnet test OldToNew.sln --no-build
```

## Run

```powershell
dotnet run --project src/OldToNew.Desktop/OldToNew.Desktop.csproj
```

Suggested demo scenarios are displayed inside the application.
