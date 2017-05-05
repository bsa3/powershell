
param(
  [string]$HOSTNAME = $(HOSTNAME),
  [string]$NR_Alert_CPU_condition_id = "123456",
  [parameter(ValueFromPipeline=$True)]
  [string[]]$NR_API_KEY = ""
)

echo $NR_API_KEY

if (!$NR_API_KEY) { Write-Output "Required NR_API_KEY not specified." 
  return
}

#test api key
try {
  Invoke-RestMethod -Uri "https://api.newrelic.com/v2/alerts_policies.json" -H @{"X-API-KEY"=$($NR_API_KEY)}
} catch {
  throw 'Check NR_API_KEY; NR API does not seem to work'
  return
}

#Try to find current hostname on relic server
try {
  $Res=Invoke-RestMethod -Uri "https://api.newrelic.com/v2/servers.json?filter[host]=$($HOSTNAME)" -H @{"X-API-KEY"=$($NR_API_KEY)}
  # $Res.servers.id
} catch { }

$t = 3
$trys = 10 
While (!$Res.servers.id)
{
  if (!$Res.servers.id) { Write-Output "Waiting $trys * $t seconds for NewRelic to register new entity $($HOSTNAME)" }
  $i +=1
  Write-Output $i
  if ($i -gt $trys) {break} ### timeout 100*3=300s or 5min
  Start-Sleep $t # and try again
  $Res=Invoke-RestMethod -Uri "https://api.newrelic.com/v2/servers.json?filter[host]=$($HOSTNAME)" -H @{"X-API-KEY"=$($NR_API_KEY)}
}  

if (!$Res.servers.id) { Write-Host "Timeout reached; HOSTNAME not found on Relic server." 
  return
}

$url="https://api.newrelic.com/v2/alerts_entity_conditions/$($Res.servers.id).json"

$nrdata = @{
    entity_type="Server"
    condition_id="123456"
}

#Add to cpu condition
$nrdata.condition_id=$NR_Alert_CPU_condition_id
$RP=Invoke-RestMethod -Method Put -Uri $url -Body $(ConvertTo-Json $nrdata) -H @{"X-API-KEY"=$($NR_API_KEY)} -ContentType 'application/json'

#
###
