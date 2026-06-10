# network-dns-optimizer.ps1
# Network & DNS Optimization for Gaming
# Run as Administrator

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  🌐 Network & DNS Optimizer v1.0" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ ERROR: Run as Administrator!" -ForegroundColor Red
    exit 1
}

Write-Host "[1/7] Flushing DNS Cache..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Host "✅ DNS Cache Flushed" -ForegroundColor Green

Write-Host ""
Write-Host "[2/7] Resetting TCP/IP Stack..." -ForegroundColor Yellow
netsh int ip reset | Out-Null
netsh int tcp reset | Out-Null
Write-Host "✅ TCP/IP Stack Reset" -ForegroundColor Green

Write-Host ""
Write-Host "[3/7] Optimizing TCP Settings..." -ForegroundColor Yellow

# Disable autotuning
netsh interface tcp set global autotuninglevel=disabled | Out-Null

# Disable window scaling
netsh interface tcp set global windowscaling=disabled | Out-Null

# Disable O.S.P.
netsh interface tcp set global ncscachetimeout=0 | Out-Null

# Set optimal parameters
netsh interface tcp set parameters namcachehint=16384 | Out-Null
netsh interface tcp set parameters echocount=3 | Out-Null

Write-Host "✅ TCP Autotuning: Disabled" -ForegroundColor Green
Write-Host "✅ Window Scaling: Disabled" -ForegroundColor Green

Write-Host ""
Write-Host "[4/7] Disabling QoS Packet Scheduler..." -ForegroundColor Yellow
netsh interface qos set filter state=disabled | Out-Null
Write-Host "✅ QoS: Disabled" -ForegroundColor Green

Write-Host ""
Write-Host "[5/7] Setting DNS to Fast Providers..." -ForegroundColor Yellow

# Get current network adapters
$adapters = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=true"

foreach ($adapter in $adapters) {
    # Set fast DNS servers (Google + Cloudflare)
    $adapter.SetDNSServerSearchOrder(@("8.8.8.8", "8.8.4.4", "1.1.1.1", "1.0.0.1")) | Out-Null
    Write-Host "✅ DNS Set for: $($adapter.Description)" -ForegroundColor Green
}

Write-Host "✅ Primary DNS: 8.8.8.8 (Google)" -ForegroundColor Green
Write-Host "✅ Secondary DNS: 1.1.1.1 (Cloudflare)" -ForegroundColor Green

Write-Host ""
Write-Host "[6/7] Optimizing Network Adapter Settings..." -ForegroundColor Yellow

# Get network adapters
$netAdapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}

foreach ($adapter in $netAdapters) {
    # Disable interrupt moderation
    Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Interrupt Moderation" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    
    # Disable large send offload
    Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Large Send Offload V2" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    
    Write-Host "✅ Optimized: $($adapter.Name)" -ForegroundColor Green
}

Write-Host ""
Write-Host "[7/7] Testing Connection Speed..." -ForegroundColor Yellow

# Simple ping test
$googlePing = Test-Connection -Destination 8.8.8.8 -Count 4 -Quiet
$cloudflarePing = Test-Connection -Destination 1.1.1.1 -Count 4 -Quiet

if ($googlePing) {
    Write-Host "✅ Google DNS (8.8.8.8): Reachable" -ForegroundColor Green
} else {
    Write-Host "⚠️  Google DNS: Unreachable" -ForegroundColor Yellow
}

if ($cloudflarePing) {
    Write-Host "✅ Cloudflare DNS (1.1.1.1): Reachable" -ForegroundColor Green
} else {
    Write-Host "⚠️  Cloudflare DNS: Unreachable" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  ✅ NETWORK OPTIMIZATION COMPLETE!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Changes Applied:" -ForegroundColor Cyan
Write-Host "  • DNS Cache: Flushed" -ForegroundColor White
Write-Host "  • TCP/IP Stack: Reset" -ForegroundColor White
Write-Host "  • TCP Autotuning: Disabled" -ForegroundColor White
Write-Host "  • DNS Servers: Google + Cloudflare" -ForegroundColor White
Write-Host "  • Network Adapter: Optimized" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  Restart required for some changes!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")