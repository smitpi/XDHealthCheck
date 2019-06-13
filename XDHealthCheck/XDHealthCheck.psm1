#Get public and private function definition files.
<#


foreach ($folder in @('public'))
{
    $root = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if (Test-Path -Path $root)
    {
        Write-Verbose "processing folder $root"
        $files = Get-ChildItem -Path $root -Filter *.ps1 -Recurse

        # dot source each file
        $files | where-Object { $_.name -NotLike '*.Tests.ps1'} | 
            ForEach-Object {Write-Verbose $_.basename; . $_.FullName}
    }
}

Export-ModuleMember -function (Get-ChildItem -Path "$PSScriptRoot\public\*.ps1").basename
 # 
#>
#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
#$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )


#Dot source the files
Foreach($import in @($Public))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $Public.Basename