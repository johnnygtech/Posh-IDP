function Get-StringHash
{
    param(
        [parameter()][string]$String,
        [parameter()][switch]$removeDash
    );
    $sha = new-object -TypeName System.Security.Cryptography.SHA256CryptoServiceProvider
    $utf8 = new-object -TypeName System.Text.UTF8Encoding
    $hash = [System.BitConverter]::ToString($sha.ComputeHash($utf8.GetBytes($String)))
    if($removeDash)
    {
        return $($hash -replace "-","")
    }
    return $hash
}

function Get-SanitizedString
{
    param(
        [Parameter()]
        [string]
        $string
        ,[Parameter()]
        [switch]
        $toLower
    )
    $newString = "";
    if($toLower)
    {
        $newString = $string.TrimStart().TrimEnd().ToLower();
    }
    else {
        $newString = $string.TrimStart().TrimEnd();
    }
    return $newString;
}