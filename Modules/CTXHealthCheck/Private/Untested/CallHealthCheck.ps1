[string]$ScriptPath = $PSScriptRoot
[xml]$Parameters = Get-Content .\Parameters.xml # Read content of XML file


import-module CTXHealthCheck -Force -Verbose
Initialize-CitrixHealthCheck -XMLParameter $Parameters -ScriptPath $ScriptPath -Verbose
