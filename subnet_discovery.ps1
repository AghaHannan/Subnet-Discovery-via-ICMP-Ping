<#
.SYNOPSIS
  Subnet discovery via ping for Windows (PowerShell)

.DESCRIPTION
  Scans the private IP ranges 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
  by pinging each /24 gateway address.  Defaults: gateway host .1, no delay.
#>

param(
  [int]$Gateway = 1,                                 # Gateway host to ping (default .1)
  [int]$Delay   = 0,                                 # Delay (sec) between pings (default 0)
  [string]$OutputFile = "accessible_subnets.txt"     # Output file for responsive networks
)

# Initialize output file
"#: Accessible /24 Subnets (responded to ping)" | Out-File $OutputFile
"#: Scanned gateway host: .$Gateway, delay: $Delay sec" | Out-File $OutputFile -Append
"#: -----------------------------" | Out-File $OutputFile -Append

# Define ranges
$range10  = 0..255
$range172 = 16..31
$range192 = 0..255

# Helper to test a single IP
function Test-Host($ip) {
    # Send 1 ping and return $true/$false
    return Test-Connection -ComputerName $ip -Count 1 -Quiet -TimeoutSeconds 1
}

# Scan 10.0.0.0/8 networks
foreach ($second in $range10) {
    foreach ($third in $range10) {
        $ip = "10.$second.$third.$Gateway"
        if (Test-Host $ip) {
            Write-Output "$ip replied"
            "10.$second.$third.0/24" | Out-File $OutputFile -Append
        }
        if ($Delay -gt 0) { Start-Sleep -Seconds $Delay }
    }
}

# Scan 172.16.0.0/12 networks
foreach ($second in $range172) {
    foreach ($third in $range10) {
        $ip = "172.$second.$third.$Gateway"
        if (Test-Host $ip) {
            Write-Output "$ip replied"
            "172.$second.$third.0/24" | Out-File $OutputFile -Append
        }
        if ($Delay -gt 0) { Start-Sleep -Seconds $Delay }
    }
}

# Scan 192.168.0.0/16 networks
foreach ($third in $range192) {
    $ip = "192.168.$third.$Gateway"
    if (Test-Host $ip) {
        Write-Output "$ip replied"
        "192.168.$third.0/24" | Out-File $OutputFile -Append
    }
    if ($Delay -gt 0) { Start-Sleep -Seconds $Delay }
}
