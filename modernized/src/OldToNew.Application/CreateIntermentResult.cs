namespace OldToNew.Application;

public sealed record CreateIntermentResult(bool IsSuccess, string RuleId, string Message)
{
    public static CreateIntermentResult Success() =>
        new(true, "CREATED", "Synthetic interment created successfully.");

    public static CreateIntermentResult Rejected(string ruleId, string message) =>
        new(false, ruleId, message);
}
