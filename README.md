# ContosoUniversity on ASP.NET Core 3.0 on .NET Core and Razor Pages

Contoso University, the way I would write it.

This example requires some tools and PowerShell modules, you can run `setup.cmd` to install them.

To prepare the database, execute the build script using [PSake](https://psake.readthedocs.io/): `psake migrate`. Open the solution and run!

## Things demonstrated

- CQRS and MediatR
- AutoMapper
- Vertical slice architecture
- Razor Pages
- Fluent Validation
- HtmlTags
- Entity Framework Core

## Versioning

Version numbers can be passed on the build script command line:

```
psake CI -properties ${'version':'1.2.3-dev.5'}
```

Or demonstrate the use of [GitVersion](https://gitversion.net/docs/) locally:
```
psake 'localversion, CI'
```
will generate a semantic version and execute the continuous integration build.
