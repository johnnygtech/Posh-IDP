function Get-StringHash
{
    param(
        [parameter()][string]$String
    );
    $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    $utf8 = new-object -TypeName System.Text.UTF8Encoding
    $hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($String)))
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