<#
Polaris - Post
Used to login a user (generate a new token)
    Posh-Pwd - Github/JohnnyGTech
    Posh-Jwt - Github/JohnnyGTech
#>
$env:PSModulePath += ":$psScriptRoot/modules"
#Load Dependancies
#region modules
Try
{
    Import-Module Posh-Jwt
}
catch
{
    Write-Error "Could not load Posh-Jwt"
    $response.send($(ConvertTo-Json -inputObject @{"statusCode"=500;"error"="error_loading_module";"message"="server error"}))
    return
}
Try
{
    Import-Module Posh-Pwd
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

$username = $request.Body.username;
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
$antiTiming = Get-Date
try 
{
    if($(Test-Path -Path "./$($Config.dataDir)/$usernameHash.json"))
    {
        $userdata = ConvertFrom-Json $(Get-Content -Path "./$($Config.dataDir)/$usernameHash.json" -Raw)
        $newHash = New-Rfc2898StringHash -string $($request.Body.password) -iterations $($userData.password.iterations) -salt $($userData.password.salt)
        if($newHash.hash -eq $userdata.password.hash)
        {
            #user provided valid credentials
            #Go ahead and create a JWT
            $header = New-JwtHeader -algorithm HS256
            $payload = New-JwtPayload
            $payload.iss = $config.jwtIssuerId
            $payload.sub = $userData.username
            $payload.add("aud",$config.jwtAudience)
            $payload.name = "$($userData.fName) $($userData.lName)"
            $id= $([guid]::newGuid()).GUID
            $payload.jti = $id
            $secret = $config.jwtSigningKey
            if(!$secret){throw}
            $jwtToken = New-Jwt -header $header -payload $payload -secret $secret
            if(!(Test-Path -path "./$($config.tokenDir)/$id.json"))
            {
                Add-Content -path "./$($config.logDir)/log.txt" -value "$(Get-Date) created token for $username - $id"
                Set-Content -path "./$($config.tokenDir)/$id.json" -Value $jwtToken
                $response.send($(ConvertTo-Json -inputObject @{"statusCode"=200;"message"="The login was successful";"token"=$jwtToken}))
                return
            }
            else
            {
                throw    
            }
        }
        else 
        {
            throw
        }
    }
    else
    {
        throw    
    }
}
catch 
{
    #Possibly a misguided attempt to make all failures take the same amount of time
    # HashTag, I read a document somewhere.
    $testTime = Get-Date
    $span = New-TimeSpan $antiTiming $testTime
    $waitTime = 2 - $span.Seconds
    $abs = [Math]::Abs($waitTime);
    Start-Sleep -Seconds $abs
    $response.send($(ConvertTo-Json -InputObject @{"statusCode"=404;"error"="Invalid_Username_Or_Password";"message"="The username is not found or the password was incorrect"}))
}
return