# XDHealthCheck
 
## Description
Creates daily health check and config reports for your on-premise Citrix farm. To get started, you need to run Install-ParametersFile.
This will capture and save needed farm details, to allow scripts to run automatically.
 
## Getting Started
```
- Install-Module -Name XDHealthCheck -Verbose
```
OR
```
git clone https://github.com/smitpi/XDHealthCheck (Join-Path (get-item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath XDHealthCheck)
```
Then:
```
- Import-Module XDHealthCheck -Verbose -Force
 
- Get-Command -Module XDHealthCheck
- Get-Help about_XDHealthCheck
```
