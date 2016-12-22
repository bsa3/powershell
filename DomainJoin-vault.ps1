#create your header obj
$h=@{"X-Vault-Token"="< YOUR TOKEN HERE >"}
$OUPath = "OU=WEB,OU=Stage, YOUR FULL OU PATH HERE "

$res = Invoke-RestMethod -Method GET -H $h "https:// <YOUR VAULT URI> /v1/secret/ <YOUR VAULT PATH>"

# Set DNS setting asumming you put them to your vault secret
Set-DnsClientServerAddress -InterfaceAlias (Get-NetAdapter).Name -ServerAddresses ($res.data.DNS1,$res.data.DNS2,$res.data.DNS3,$res.data.DNS4)

# Confirm DNS setting
# (Get-DnsClientServerAddress -AddressFamily IPv4 -InterfaceAlias (Get-NetAdapter).Name).ServerAddresses

# Run one of below commands
#tzutil /s "Pacific Standard Time"
#tzutil /s "Eastern Standard Time"
tzutil /s "GMT Standard Time”

# To confirm
tzutil /g

# Join Computer to Domain
$secpasswd = ConvertTo-SecureString $res.data.password -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($res.data.djuser, $secpasswd)
Add-Computer -domainname $res.data.FQDN -credential $mycreds -OUPath $OUPath

# Troubleshooting Ideas
# nslookup your $res.data.FQDN
# Test-NetConnection $res.data.DNS1 -port 53 -Verbose
