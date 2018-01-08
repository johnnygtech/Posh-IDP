#Set Context
$env:PSModulePath += ":$psScriptRoot/modules"

set-location $PSScriptRoot
Try
{
    Import-Module Polaris
    #https://github.com/johnnygtech/Polaris
}
catch
{
    Write-error "Could not load Polaris"
}

#Cleanup Any Existing Tokens
Get-ChildItem ./tokens | Remove-Item -Recurse -Force

#Setup Polaris Routes
New-PolarisPOSTRoute -Path "/v1/user" -ScriptPath ./routes/v1/user/post.ps1 -Verbose
New-PolarisGetRoute -Path "/v1/user" -ScriptPath ./routes/v1/user/get.ps1 -Verbose
New-PolarisPOSTRoute -Path "/v1/login" -ScriptPath ./routes/v1/login/post.ps1 -Verbose
$port = 8080
$minRunspaces = 1
$maxRunspaces = 1
$ctx = Start-Polaris -Port $port -MinRunspaces $minRunspaces -MaxRunspaces $maxRunspaces -UseJsonBodyParserMiddleware -Verbose

read-host "hit enter to stop polaris"

Stop-Polaris -ServerContext $ctx
Remove-PolarisRoute -Path "/v1/user" -Method post
Remove-PolarisRoute -Path "/v1/user" -Method get
Remove-PolarisRoute -Path "/v1/login" -Method post
#Make a final call to ensure thread closes
INvoke-WebRequest -uri http://localhost:$port | Out-Null