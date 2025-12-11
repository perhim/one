$ErrorActionPreference = 'Stop'
$m2 = 'C:\Users\perhim\.m2\repository'
$paths = @(
    'com\android\tools\build\gradle\8.0.0',
    'com\google\gms\google-services\4.3.15'
)
foreach($p in $paths){
    $full = Join-Path $m2 $p
    if(-not (Test-Path $full)){
        New-Item -Path $full -ItemType Directory -Force | Out-Null
    }
}

$files = @(
    @{ url = 'https://dl.google.com/dl/android/maven2/com/android/tools/build/gradle/8.0.0/gradle-8.0.0.pom'; out = Join-Path $m2 'com\android\tools\build\gradle\8.0.0\gradle-8.0.0.pom' },
    @{ url = 'https://dl.google.com/dl/android/maven2/com/android/tools/build/gradle/8.0.0/gradle-8.0.0.jar'; out = Join-Path $m2 'com\android\tools\build\gradle\8.0.0\gradle-8.0.0.jar' },
    @{ url = 'https://dl.google.com/dl/android/maven2/com/google/gms/google-services/4.3.15/google-services-4.3.15.pom'; out = Join-Path $m2 'com\google\gms\google-services\4.3.15\google-services-4.3.15.pom' },
    @{ url = 'https://dl.google.com/dl/android/maven2/com/google/gms/google-services/4.3.15/google-services-4.3.15.jar'; out = Join-Path $m2 'com\google\gms\google-services\4.3.15\google-services-4.3.15.jar' }
)

foreach($f in $files){
    Write-Output "Downloading $($f.url) -> $($f.out)"
    Invoke-WebRequest -Uri $f.url -OutFile $f.out -UseBasicParsing -TimeoutSec 60
}

Write-Output 'SEED_DONE'
