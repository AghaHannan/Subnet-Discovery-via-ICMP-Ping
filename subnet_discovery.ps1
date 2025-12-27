<#
.SYNOPSIS
  Subnet discovery via ICMP ping for Windows

.DESCRIPTION
  Scans private IPv4 ranges (10/8, 172.16/12, 192.168/16)
  by pinging each /24 gateway (.1 by default).
#>

param(
  [int]$Gateway = 1,
  [int]$Delay   = 0,
  [string]$OutputFile = "accessible_subnets.txt"
)

# Initialize output file
"#: Accessible /24 Subnets (responded to ping)" | Out-File $OutputFile
"#: Gateway: .$Gateway | Delay: $Delay sec" | Out-File $OutputFile -Append
"#: ----------------------------------------" | Out-File $OutputFile -Append

# Define ranges
$range10  = 0..255
$range172 = 16..31
$range192 = 0..255

# Test a single IP (PowerShell 5.1 compatible)
function Test-Host($ip) {
    Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue
}

# ---- 10.0.0.0/8 ----
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

# ---- 172.16.0.0/12 ----
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

# ---- 192.168.0.0/16 ----
foreach ($third in $range192) {
    $ip = "192.168.$third.$Gateway"
    if (Test-Host $ip) {
        Write-Output "$ip replied"
        "192.168.$third.0/24" | Out-File $OutputFile -Append
    }
    if ($Delay -gt 0) { Start-Sleep -Seconds $Delay }
}
