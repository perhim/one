# install_jdk17_and_build.ps1
$ErrorActionPreference = 'Stop'

$tmp = Join-Path $env:TEMP 'jdk17_extract'
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Path $tmp | Out-Null

$zip = Join-Path $env:TEMP 'temurin17.zip'
Write-Host "[DOWNLOAD] Fetching Temurin JDK 17..."
Invoke-WebRequest -Uri 'https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse' -OutFile $zip

Write-Host "[EXTRACT] Extracting..."
Expand-Archive -Path $zip -DestinationPath $tmp -Force

$ex = (Get-ChildItem -Directory $tmp | Select-Object -First 1).FullName
$dest = Join-Path $env:USERPROFILE 'jdk17'
if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
Move-Item -Path $ex -Destination $dest

Remove-Item $zip -Force
Remove-Item $tmp -Recurse -Force

Write-Host "[DONE] JDK extracted to $dest"

$env:JAVA_HOME = $dest
$env:Path = "$env:JAVA_HOME\bin;" + $env:Path

Write-Host "[JAVA] java -version:"
java -version

Write-Host "[BUILD] Running Gradle assembleDebug..."

Set-Location -Path "C:\Users\perhim\Desktop\New folder (5) - Copy - Copy - Copy\android"
& .\gradlew.bat assembleDebug

Write-Host "[BUILD DONE] Check android\app\build\outputs\apk\debug\app-debug.apk"
