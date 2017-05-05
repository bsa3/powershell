## CREDIT: https://gist.github.com/Sam-Martin/1955ac4ef3972bb9e8a8
## requirement KMS/CMS policy setup

param(
  [string]$secretPath = "d:\secret.txt",
  [string]$region = "us-west-1",
  [hashtable]$encryptionContext = @{"Key" = "value"}
)

function ConvertFrom-Base64toMemoryStream{
    param(
        [parameter(Mandatory)]
        [string]$Base64Input
    )

    [byte[]]$bytearray = [System.Convert]::FromBase64String($Base64Input)
    $stream = New-Object System.IO.MemoryStream($bytearray,0,$bytearray.Length)
    return $stream
}

# Get the enrcrypted stream from Amazon if key policy allows 

$DecryptedOutputStream = Invoke-KMSDecrypt -encryptionContext $encryptionContext -CiphertextBlob $(ConvertFrom-Base64toMemoryStream -Base64Input $(Get-Content $secretPath)) -region $region

function ConvertFrom-StreamToString{
    param(
        [parameter(Mandatory)]
        [System.IO.MemoryStream]$inputStream
    )
    $reader = New-Object System.IO.StreamReader($inputStream);
    $inputStream.Position = 0;
    return $reader.ReadToEnd()
}

# Convert the decrypted stream to a strimg
$DecryptedOutput = ConvertFrom-StreamToString -inputStream $DecryptedOutputStream.Plaintext

Write-Host $DecryptedOutput

#example: $secretArg=(powershell thisscript.ps1 xyzparams) ; powershell consumer.ps1 $secretArg ; $secretArg=""#clear the var
