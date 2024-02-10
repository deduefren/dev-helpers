# Intervar to perform host checks
[Parameter]
[Int]
$hostCheckUpInterval = 2000

function Invoke-HostUpCheck {
  param (
  )
  $hostsToCheck = @("www.google.com", "www.microsoft.com", "www.apple.com")
  Write-Host "Checking hosts... "
  $upHostCount = 0
  foreach ($currentHost in $hostsToCheck) {
    $result = Test-NetConnection -ComputerName $currentHost
    if ($result.PingSucceeded) {
      $upHostCount++
    }
  }

  if ($upHostCount -eq $hostsToCheck.Count) {
    Write-Host "All hosts are up"
    return $true
  }
  else {
    $seconds = $hostCheckUpInterval / 1000
    Write-Host "Some hosts are down - Retry in $seconds seconds"
  }
}

function GetMilis () {
  return [System.DateTimeOffset]::Now.ToUnixTimeMilliseconds()
}

$stopSignal = $false
$lastHostCheck = GetMilis
do {
  $currentMilis = GetMilis

  # Repeat this pattern as many times as you need
  if ($lastHostCheck + $hostCheckUpInterval -lt $currentMilis) {
    $shouldStop = Invoke-HostUpCheck
  
    if ($shouldStop) {
      $stopSignal = $true
    }
    $lastHostCheck = GetMilis
  }

  # Other checks or actions here

} while (-not $stopSignal)

Write-Host "Script finished"

