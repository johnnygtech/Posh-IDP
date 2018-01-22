$job = Start-Job -FilePath ./start.ps1

$newUser = @"
{
    "username": "ja",
    "lName": "gleason",
    "fName": "john",
    "email": "j@g.c",
    "password": "p"
  }
"@

$login = @"
{
    "username": "ja",
    "password": "p"
}
"@

Invoke-RestMethod -uri http://localhost:8080/v1/user -Method POST -Body $newUser

if(!$?)
{
    return $false
}

Invoke-RestMethod -Uri http://localhost:8080/v1/login -Method Post -Body $login

if(!$?)
{
    return $false
}

Invoke-RestMethod -Uri http://localhost:8080/v1/user -Method Delete -Headers @{"Authorization"="Bearer $($r2.token)"}

Stop-Job $job