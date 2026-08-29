namespace OldToNew.Domain;

public static class IntermentRules
{
    public static RuleViolation? ValidateLevelAndSublevel(int level, int sublevel)
    {
        if (level is < 1 or > 3)
        {
            return new RuleViolation("BR-064", "Level must be between 1 and 3.");
        }

        if (sublevel is < 1 or > 6)
        {
            return new RuleViolation("BR-064", "Sublevel must be between 1 and 6.");
        }

        return null;
    }

    public static RuleViolation? ValidateServiceType(string? serviceType)
    {
        var normalized = serviceType?.Trim().ToUpperInvariant();
        return normalized is "S" or "T"
            ? null
            : new RuleViolation("BR-063", "Service type must be S (burial) or T (transfer).");
    }
}
