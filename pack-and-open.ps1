# pack-and-open.ps1
# Automates npm install, Capacitor android add (if needed), copy, and open Android Studio.
# Run in project root where this file and package.json are located.

param(
    [switch]$ForceAddAndroid
)

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-ErrorMsg($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

Write-Info "Checking Node and npm..."
try {
    $node = & node --version 2>$null
    $npm = & npm --version 2>$null
} catch {
    $node = $null; $npm = $null
}
if (-not $node -or -not $npm) {
    Write-ErrorMsg "Node.js and npm are required. Install Node.js (https://nodejs.org/) and try again."; exit 1
}
Write-Info "Node: $node  npm: $npm"

Write-Info "Running npm install..."
$rc = & npm install
if ($LASTEXITCODE -ne 0) { Write-ErrorMsg "npm install failed. Check output above."; exit $LASTEXITCODE }

# Ensure Capacitor CLI is available locally via node_modules/.bin
$capCmd = "npx"

# Add Android platform if android folder doesn't exist or if forced
$androidDir = Join-Path -Path (Get-Location) -ChildPath 'android'
if (-not (Test-Path $androidDir) -or $ForceAddAndroid) {
    Write-Info "Adding Android platform via Capacitor..."
    $addOut = & $capCmd cap add android
    if ($LASTEXITCODE -ne 0) { Write-ErrorMsg "npx cap add android failed. See output above."; exit $LASTEXITCODE }
} else {
    Write-Info "Android platform already exists; skipping cap add. Use -ForceAddAndroid to force re-add." 
}

Write-Info "Copying web assets to native project (npx cap copy)..."
& $capCmd cap copy
if ($LASTEXITCODE -ne 0) { Write-ErrorMsg "npx cap copy failed."; exit $LASTEXITCODE }

Write-Info "Opening Android project in Android Studio (npx cap open android)..."
& $capCmd cap open android
if ($LASTEXITCODE -ne 0) { Write-ErrorMsg "npx cap open android failed."; exit $LASTEXITCODE }

Write-Info "Done. Android Studio should open. If it didn't, open the 'android' folder manually in Android Studio."