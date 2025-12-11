# download_and_wire_audio.ps1
# Reads download_audio_template.csv. For each row:
# - if url_to_download is present, download to suggested_filename
# - otherwise create a short silent WAV placeholder
# Then update local_assets_map.json to point audio asset ids to the created files

$cwd = Get-Location
$csvPath = Join-Path $cwd 'download_audio_template.csv'
$mapPath = Join-Path $cwd 'local_assets_map.json'
$assetsDir = Join-Path $cwd 'assets'

if (-not (Test-Path $csvPath)) { Write-Error "CSV not found: $csvPath"; exit 1 }
if (-not (Test-Path $assetsDir)) { New-Item -Path $assetsDir -ItemType Directory | Out-Null }

function Create-SilentWav {
    param(
        [string] $path,
        [double] $seconds = 0.5,
        [int] $sampleRate = 22050,
        [int] $bitsPerSample = 16,
        [int] $channels = 1
    )
    $numSamples = [int]($sampleRate * $seconds)
    $byteRate = $sampleRate * $channels * ($bitsPerSample / 8)
    $blockAlign = $channels * ($bitsPerSample / 8)
    $dataBytes = $numSamples * $channels * ($bitsPerSample / 8)

    $fs = [System.IO.File]::Open($path, [System.IO.FileMode]::Create)
    $bw = New-Object System.IO.BinaryWriter($fs)
    try {
        # RIFF header
        $bw.Write([System.Text.Encoding]::ASCII.GetBytes('RIFF'))
        $bw.Write([int](36 + $dataBytes))
        $bw.Write([System.Text.Encoding]::ASCII.GetBytes('WAVE'))
        # fmt chunk
        $bw.Write([System.Text.Encoding]::ASCII.GetBytes('fmt '))
        $bw.Write([int]16) # subchunk1 size
    $bw.Write([int16]1) # PCM
    $bw.Write([int16]$channels)
        $bw.Write([int]$sampleRate)
        $bw.Write([int]$byteRate)
    $bw.Write([int16]$blockAlign)
    $bw.Write([int16]$bitsPerSample)
        # data chunk header
        $bw.Write([System.Text.Encoding]::ASCII.GetBytes('data'))
        $bw.Write([int]$dataBytes)
        # write silence (zeros)
        for ($i=0; $i -lt $numSamples * $channels; $i++) {
            if ($bitsPerSample -eq 16) { $bw.Write([int16]0) } else { $bw.Write([byte]0) }
        }
    } finally {
        $bw.Close(); $fs.Close()
    }
}

$rows = Import-Csv $csvPath
$created = @()
$errors = @()
foreach ($r in $rows) {
    $id = $r.asset_id
    $suggested = $r.suggested_filename
    $url = $r.url_to_download
    if (-not $suggested) { $errors += "Missing suggested filename for $id"; continue }
    $outPath = Join-Path $cwd $suggested
    $outDir = [System.IO.Path]::GetDirectoryName($outPath)
    if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
    try {
        if ($url -and $url.Trim() -ne '') {
            Write-Host "Downloading $id from $url -> $suggested"
            Invoke-WebRequest -Uri $url -OutFile $outPath -UseBasicParsing -ErrorAction Stop
            $created += @{ id=$id; file=$suggested; action='downloaded' }
        } else {
            Write-Host "Creating silent placeholder for $id -> $suggested"
            Create-SilentWav -path $outPath -seconds 0.5
            $created += @{ id=$id; file=$suggested; action='placeholder' }
        }
    } catch {
        $errors += ("Failed to create/download for {0}: {1}" -f $id, ($_.Exception.Message))
    }
}

# Update local_assets_map.json
if (-not (Test-Path $mapPath)) {
    Write-Host "local_assets_map.json not found; creating new manifest.";
    $mapObj = @{}
} else {
    try { $mapObj = Get-Content $mapPath -Raw | ConvertFrom-Json } catch { $errors += ("Failed to parse local_assets_map.json: {0}" -f ($_.Exception.Message)); $mapObj = @{} }
}

$mapChanged = $false
foreach ($c in $created) {
    $id = $c.id
    $file = $c.file -replace '^\\.\\/',''
    # ensure path uses forward slashes
    $url = $file -replace '\\','/'
    if ($null -eq $mapObj.$id -or $mapObj.$id -eq $null) {
        $mapObj | Add-Member -MemberType NoteProperty -Name $id -Value @{ type='audio'; url=$url } -Force
        $mapChanged = $true
    } else {
        # if existing entry is null or missing url, set it
        if ($mapObj.$id -eq $null -or ($mapObj.$id.url -eq $null)) {
            $mapObj.$id = @{ type='audio'; url=$url }
            $mapChanged = $true
        } else {
            # leave existing non-null entry alone
        }
    }
}
if ($mapChanged) {
    $mapObj | ConvertTo-Json -Depth 6 | Out-File -Encoding UTF8 $mapPath
    Write-Host "Updated local_assets_map.json"
} else {
    Write-Host "No changes to local_assets_map.json"
}

Write-Output "CREATED_COUNT=$( $created.Count )"
$created | ConvertTo-Json -Depth 3 | Write-Output
if ($errors.Count -gt 0) { Write-Output "ERRORS:"; $errors | ForEach-Object { Write-Output $_ } }
Write-Output "DONE"
