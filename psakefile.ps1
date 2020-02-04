include "./psake-build-helpers.ps1"

properties {
    $configuration = 'Release'
    $version = '1.0.999'
    $owner = 'Jimmy Bogard'
    $product = 'Contoso University Core'
    $yearInitiated = '2016'
    $projectRootDirectory = "$(resolve-path .)"
    $publish = "$projectRootDirectory/publish"
    $testResults = "$projectRootDirectory/TestResults"
}
 
task default -depends Test
task CI -depends Clean, Test, Publish -description "Continuous Integration process"
task Rebuild -depends Clean, Compile -description "Rebuild the code and database, no testing"

task Info -description "Display runtime information" {
    exec { dotnet --info }
}

task Test -depends Compile -description "Run unit tests" {
    # drop and recreate the test database
    exec { dotnet rh /d=ContosoUniversityDotNetCore-Pages-Test /f=ContosoUniversity/App_Data /s="(LocalDb)\mssqllocaldb" /silent /drop }
    exec { dotnet rh /d=ContosoUniversityDotNetCore-Pages-Test /f=ContosoUniversity/App_Data /s="(LocalDb)\mssqllocaldb" /silent /simple }

    # find any directory that ends in "Tests" and execute a test
    get-childitem . *Tests -directory | foreach-object {
        exec { dotnet test --configuration $configuration --no-build } -workingDirectory $_.fullname
    }
}
 
task Compile -depends Info -description "Compile the solution" {
    exec { set-project-properties $version } -workingDirectory .
    exec { dotnet build --configuration $configuration /nologo } -workingDirectory .
}

task Publish -depends Compile -description "Publish the primary projects for distribution" {
    remove-directory-silently $publish
    exec { publish-project } -workingDirectory ContosoUniversity
}

task Migrate -description "Migrate the changes into the runtime database" {
    exec { dotnet rh /d=ContosoUniversityDotNetCore-Pages /f=ContosoUniversity\App_Data /s="(LocalDb)\mssqllocaldb" /silent }
}
  
task Clean -description "Clean out all the binary folders" {
    exec { dotnet clean --configuration $configuration /nologo } -workingDirectory .
    remove-directory-silently $publish
    remove-directory-silently $testResults
}

task LocalVersion -description "Create a local version number for the build (use along with Compile)" {
    $localVersion = (dotnet gitversion /output json /showvariable SemVer)
    Write-Host "Version: ${localVersion}"
}
  
task ? -alias help -description "Display help content and possible targets" {
    WriteDocumentation
}
