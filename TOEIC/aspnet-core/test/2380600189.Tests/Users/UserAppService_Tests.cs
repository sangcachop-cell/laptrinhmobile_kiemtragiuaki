using 2380600189.Users;
using 2380600189.Users.Dto;
using Microsoft.EntityFrameworkCore;
using Shouldly;
using System.Threading.Tasks;
using Xunit;

namespace 2380600189.Tests.Users;

public class UserAppService_Tests : 2380600189TestBase
{
    private readonly IUserAppService _userAppService;

    public UserAppService_Tests()
    {
        _userAppService = Resolve<IUserAppService>();
    }

    [Fact]
    public async Task GetUsers_Test()
    {
        // Act
        var output = await _userAppService.GetAllAsync(new PagedUserResultRequestDto { MaxResultCount = 20, SkipCount = 0 });

        // Assert
        output.Items.Count.ShouldBeGreaterThan(0);
    }

    [Fact]
    public async Task CreateUser_Test()
    {
        // Act
        await _userAppService.CreateAsync(
            new CreateUserDto
            {
                EmailAddress = "john@volosoft.com",
                IsActive = true,
                Name = "John",
                Surname = "Nash",
                Password = "123qwe",
                UserName = "john.nash"
            });

        await UsingDbContextAsync(async context =>
        {
            var johnNashUser = await context.Users.FirstOrDefaultAsync(u => u.UserName == "john.nash");
            johnNashUser.ShouldNotBeNull();
        });
    }
}
