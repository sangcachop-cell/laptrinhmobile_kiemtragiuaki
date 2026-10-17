using Abp.AspNetCore;
using Abp.AspNetCore.TestBase;
using Abp.Modules;
using Abp.Reflection.Extensions;
using 2380600189.EntityFrameworkCore;
using 2380600189.Web.Startup;
using Microsoft.AspNetCore.Mvc.ApplicationParts;

namespace 2380600189.Web.Tests;

[DependsOn(
    typeof(2380600189WebMvcModule),
    typeof(AbpAspNetCoreTestBaseModule)
)]
public class 2380600189WebTestModule : AbpModule
{
    public 2380600189WebTestModule(2380600189EntityFrameworkModule abpProjectNameEntityFrameworkModule)
    {
        abpProjectNameEntityFrameworkModule.SkipDbContextRegistration = true;
    }

    public override void PreInitialize()
    {
        Configuration.UnitOfWork.IsTransactional = false; //EF Core InMemory DB does not support transactions.
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(2380600189WebTestModule).GetAssembly());
    }

    public override void PostInitialize()
    {
        IocManager.Resolve<ApplicationPartManager>()
            .AddApplicationPartsIfNotAddedBefore(typeof(2380600189WebMvcModule).Assembly);
    }
}