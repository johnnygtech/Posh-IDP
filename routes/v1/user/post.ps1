<#
Polaris - Post
Used to create a new user record
    Posh-Pwd - Github/JohnnyGTech
#>
$env:PSModulePath += ":$psScriptRoot/modules"
#Load Dependancies
#region modules
Try
{
    Import-Module Posh-Pwd
    #https://github.com/johnnygtech/Posh-Pwd
}
catch
{
    Write-Error "Could not load Posh-Pwd"
    $response.send($(ConvertTo-Json -inputObject @{"statusCode"=500;"error"="error_loading_module";"message"="server error"}))
    return
}
try
{
    . ./modules/sharedFunctions.ps1
}
catch
{
    Write-Error "Could not load shared functions"
    $response.send($(ConvertTo-Json -inputObject @{"statusCode"=500;"error"="error_loading_module";"message"="server error"}))
    return 
}
#TODO: Share config and funtions across routes
$config = $(ConvertFrom-Json $(Get-Content -Path ./config.json -Raw))
#end region
$username = $request.Body.username;
#$password = $request.Body.password; #In favor of passing direct result
$email = $request.Body.email;
$fName = $request.Body.fName;
$lName = $request.Body.lName;
#TODO: If username and email already doesn't exist
#TODO: Also verify code injection nonsense/santiize inputs
$sanitizedUsername = ""
try
{
    $sanitizedUsername = get-sanitizedString -string $username -Tolower
}
catch
{
    $response.send($(ConvertTo-Json -inputObject @{"statusCode"=500;"error"="error_parsing_username";"message"="server error"}))
    return   
}
$userNameHash = ""
try 
{
    $userNameHash = Get-StringHash -string $sanitizedUsername
}
catch 
{
    $response.send($(ConvertTo-Json -inputObject @{"statusCode"=500;"error"="error_parsing_username";"message"="server error"}))
    return   
}
if(!$(Test-Path -Path "./$($Config.dataDir)/$usernameHash.json"))
{
    #Also, should eventually separate out the "profile data"
    #TODO: Also sanitize name email fname lname
    #Initialize Account Status to "Pending", then require something?  email...
    $output = @{
        "username"=$sanitizedUsername;
        "password"=$(New-Rfc2898StringHash -string $($request.Body.password));
        "email"=$email;
        "fName"=$fname;
        "lName"=$lName
        "status"="pending"
        "schema"="v1"
    }
    try
    {
        Set-Content -Path "./$($Config.dataDir)/$usernameHash.json" -Value "$(ConvertTo-Json $output)" -ErrorAction SilentlyContinue
        $response.send($(ConvertTo-Json -inputObject @{"statusCode"=201;"message"="User: $username sucessfully created"}))
        return      
    }
    catch
    {
        $response.send($(ConvertTo-Json -inputObject @{"statusCode"=500;"error"="error_creating_user";"message"="server error"}))
        return
    }
}
else 
{
    $response.send($(ConvertTo-Json -inputObject @{"statusCode"=409;"error"="conlict_username_unavailable";"message"="That username is already taken, please try a new username"}))    
    return
}
$response.send($(ConvertTo-Json -inputObject @{"statusCode"=500;"error"="unknown";"message"="server error"}))    
return