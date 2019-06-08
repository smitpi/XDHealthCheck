#
# Module manifest for module 'CTXHealthCheck'
#
# Generated by: Pierre Smit
#
# Generated on: 2019/06/06
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'CTXHealthCheck.psm1'

# Version number of this module.
ModuleVersion = '0.0.8'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '39f9295c-353e-4bb7-aee5-0c600dfd5eba'

# Author of this module
Author = 'Pierre Smit'

# Company or vendor of this module
CompanyName = ' '

# Copyright statement for this module
Copyright = '(c) 2019 Pierre Smit. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Functions to connect to a Citrix farm and extract details for a healthcheck dashboard'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Get-CitrixConfigurationChanges','Get-CitrixFarmDetails','Get-CitrixLicenseInformation','Get-CitrixServerEventLogs','Get-CitrixSingleServerPerformance','Get-CitrixWebsiteStatus','Get-CitrixXA6RemoteFarmDetails','Get-RDSLicenseInformation','Get-StoreFrontDetails','Get-CitrixObjects','Compare-TwoADUsers','Get-CitrixUserAccessDetails','Get-FullUserDetail','Initialize-CitrixAudit','Initialize-CitrixHealthCheck','Initialize-CitrixUserAccessReport','Initialize-CitrixUserCompare','Initialize-CitrixUserReports','Get-CitrixServerPerformance'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'Citrix'

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/smitpi/XDHealthCheck'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = 'Updated [06/06/2019_06:02] Added the audit script
												Updated [06/06/2019_19:28] Removed unused scripts'

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        ExternalModuleDependencies = @('BetterCredentials',' PSWriteColor','ImportExcel','PSWriteHTML')

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

