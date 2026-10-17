using 2380600189.Models.TokenAuth;
using 2380600189.Web.Controllers;
using Shouldly;
using System.Threading.Tasks;
using Xunit;

namespace 2380600189.Web.Tests.Controllers;

public class HomeController_Tests : 2380600189WebTestBase
{
    [Fact]
    public async Task Index_Test()
    {
        await AuthenticateAsync(null, new AuthenticateModel
        {
            UserNameOrEmailAddress = "admin",
            Password = "123qwe"
        });

        //Act
        var response = await GetResponseAsStringAsync(
            GetUrl<HomeController>(nameof(HomeController.Index))
        );

        //Assert
        response.ShouldNotBeNullOrEmpty();
    }
}