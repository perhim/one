$ErrorActionPreference = 'Stop'
$jdkPath = 'C:\Users\perhim\jdk17'
if(-not (Test-Path $jdkPath)){
    Write-Error "JDK path not found: $jdkPath"
    exit 1
}
$env:JAVA_HOME = $jdkPath
$env:Path = "$env:JAVA_HOME\bin;" + $env:Path
Write-Output "JAVA_HOME=$env:JAVA_HOME"
Write-Output "java -version:"
& "$env:JAVA_HOME\bin\java" -version

Set-Location -Path "android"
Write-Output "Running gradle assembleDebug (this may take a few minutes)..."
& ".\\gradlew.bat" assembleDebug --no-daemon -x lint --refresh-dependencies --stacktrace --info --debug *>&1 | Tee-Object ..\\gradle_debug_full.log
Write-Output "Gradle finished. Log at: ..\\gradle_debug_full.log"
