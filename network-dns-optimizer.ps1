# network-dns-optimizer.ps1
# Network & DNS Optimization for Gaming
# Run as Administrator
#
# Support this project:
#   PayPal: https://www.paypal.com/donate/?business=UNP6WN3E95EAL&currency_code=USD
#   GitHub: https://github.com/anon2k24-design

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: Run this script as Administrator." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Network & DNS Optimizer v1.2" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Support this project:" -ForegroundColor Cyan
Write-Host "PayPal: https://www.paypal.com/donate/?business=UNP6WN3E95EAL&currency_code=USD" -ForegroundColor White
Write-Host "GitHub: https://github.com/anon2k24-design" -ForegroundColor White
Write-Host ""

Write-Host "[1/6] Flushing DNS Cache..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Host "✓ DNS Cache Flushed" -ForegroundColor Green

Write-Host ""
Write-Host "[2/6] Resetting TCP/IP Stack..." -ForegroundColor Yellow
netsh int ip reset | Out-Null
netsh winsock reset | Out-Null
Write-Host "✓ TCP/IP Stack Reset" -ForegroundColor Green
Write-Host "✓ Winsock Reset" -ForegroundColor Green

Write-Host ""
Write-Host "[3/6] Applying TCP Settings..." -ForegroundColor Yellow
netsh interface tcp set global autotuninglevel=disabled | Out-Null
Write-Host "✓ TCP Autotuning: Disabled" -ForegroundColor Green

Write-Host ""
Write-Host "[4/6] Setting DNS to Fast Providers..." -ForegroundColor Yellow

$dnsServers = @("1.1.1.1", "1.0.0.1", "8.8.8.8", "8.8.4.4")
$activeAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

foreach ($adapter in $activeAdapters) {
    try {
        Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses $dnsServers -ErrorAction Stop
        Write-Host "✓ DNS Set for: $($adapter.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ Skipping DNS change for: $($adapter.Name)" -ForegroundColor Yellow
    }
}

Write-Host "✓ Primary DNS: 1.1.1.1 (Cloudflare)" -ForegroundColor Green
Write-Host "✓ Secondary DNS: 8.8.8.8 (Google)" -ForegroundColor Green

Write-Host ""
Write-Host "[5/6] Optimizing Network Adapter Settings..." -ForegroundColor Yellow

foreach ($adapter in $activeAdapters) {
    try {
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Interrupt Moderation" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Large Send Offload V2 (IPv4)" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Large Send Offload V2 (IPv6)" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
        Write-Host "✓ Optimized Adapter: $($adapter.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ Adapter advanced settings not available for: $($adapter.Name)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[6/6] Testing Connectivity..." -ForegroundColor Yellow

$googlePing = Test-Connection -ComputerName 8.8.8.8 -Count 4 -Quiet -ErrorAction SilentlyContinue
$cloudflarePing = Test-Connection -ComputerName 1.1.1.1 -Count 4 -Quiet -ErrorAction SilentlyContinue

if ($googlePing) {
    Write-Host "✓ Google DNS (8.8.8.8): Reachable" -ForegroundColor Green
}
else {
    Write-Host "⚠ Google DNS (8.8.8.8): Unreachable" -ForegroundColor Yellow
}

if ($cloudflarePing) {
    Write-Host "✓ Cloudflare DNS (1.1.1.1): Reachable" -ForegroundColor Green
}
else {
    Write-Host "⚠ Cloudflare DNS (1.1.1.1): Unreachable" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  ✓ NETWORK OPTIMIZATION COMPLETE!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Changes Applied:" -ForegroundColor Cyan
Write-Host "  • DNS Cache: Flushed" -ForegroundColor White
Write-Host "  • TCP/IP Stack: Reset" -ForegroundColor White
Write-Host "  • Winsock: Reset" -ForegroundColor White
Write-Host "  • TCP Autotuning: Disabled" -ForegroundColor White
Write-Host "  • DNS Servers: Cloudflare + Google" -ForegroundColor White
Write-Host "  • Network Adapter: Optimized" -ForegroundColor White
Write-Host ""
Write-Host "Restart required for some changes!" -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to exit"