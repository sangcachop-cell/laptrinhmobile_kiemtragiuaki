using Xunit;

namespace 2380600189.Tests;

public sealed class MultiTenantFactAttribute : FactAttribute
{
    public MultiTenantFactAttribute()
    {
        if (!2380600189Consts.MultiTenancyEnabled)
        {
            Skip = "MultiTenancy is disabled.";
        }
    }
}
