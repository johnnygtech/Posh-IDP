<#
    Polaris - Post
    Used to create a new user record
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

if ($request.QueryParameters['username']) {
    try
    {
        $sanitizedUsername = get-sanitizedString -string $request.QueryParameters['username'] -Tolower
        $usernameHash = Get-StringHash -string $sanitizedUsername
        if(!$(Test-Path -Path "./$($Config.dataDir)/$usernameHash.json"))
        {
            $response.send($(ConvertTo-Json -InputObject @{"statusCode"=200;"status"="Username_Available";"message"="The username: $($request.QueryParameters['username']) is available"}))
        }
        else 
        {
            $response.send($(ConvertTo-Json -InputObject @{"statusCode"=200;"status"="Username_Unavailable";"message"="The username: $($request.QueryParameters['username']) not available"}))
        }
    }
    catch{
        $response.send($(ConvertTo-Json -InputObject @{"statusCode"=400;"error"="Userlookup_Failed";"message"="Unable to find user record"}))
    }
} else {
    $response.Send($(ConvertTo-Json -InputObject @{"statusCode"=400;"error"="username_not_specified";"message"="The username paremter was missing or invalid"}))
}
