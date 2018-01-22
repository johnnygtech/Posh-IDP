<#
    Polaris - Delete
    Used to delete a user record
    Requires:
        Posh-Jwt - Github/JohnnyGTech
        Posh-Pwd - Github/JohnnyGTech
#>
$env:PSModulePath += ":$psScriptRoot/modules"
try
{
    . ./modules/sharedFunctions.ps1
}
catch
{
    Write-Error "Could not load shared functions"
    $response.send($(ConvertTo-Json -inputObject @{"statusCode"=500;"error"="error_loading_module";"message"="server error"}))    
}

