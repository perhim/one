# fix_asset_extensions.ps1
# Detect real image formats in ./assets, rename files to correct extensions, and update local_assets_map.json
$cwd = Get-Location
$assetsDir = Join-Path $cwd "assets"
$mapPath = Join-Path $cwd "local_assets_map.json"
$renamed = @()
$errors = @()
if (-not (Test-Path $assetsDir)) {
    Write-Output "ERROR: assets directory not found: $assetsDir"
    exit 1
}
Get-ChildItem -Path $assetsDir -File | ForEach-Object {
    $f = $_
    try {
        $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
        $preview = ''
        if ($bytes.Length -gt 0) { $preview = [System.Text.Encoding]::UTF8.GetString($bytes,0,[Math]::Min(512,$bytes.Length)) }
        $currentExt = $f.Extension.ToLower()
        $detectedExt = $currentExt
        if ($preview -match '<svg' -or $preview.TrimStart().StartsWith('<?xml')) { $detectedExt = '.svg' }
        elseif ($preview -match 'RIFF' -and $preview -match 'WEBP') { $detectedExt = '.webp' }
        elseif ($bytes.Length -ge 4 -and $bytes[0] -eq 0x89 -and $bytes[1] -eq 0x50 -and $bytes[2] -eq 0x4E -and $bytes[3] -eq 0x47) { $detectedExt = '.png' }
        elseif ($bytes.Length -ge 3 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xD8 -and $bytes[2] -eq 0xFF) { $detectedExt = '.jpg' }
        else { $detectedExt = $currentExt }
        if ($detectedExt -ne $currentExt) {
            $newFull = [System.IO.Path]::ChangeExtension($f.FullName, $detectedExt)
            if (Test-Path $newFull) { Remove-Item -LiteralPath $newFull -Force }
            Move-Item -LiteralPath $f.FullName -Destination $newFull -Force
            $renamed += @{ old = $f.Name; new = [System.IO.Path]::GetFileName($newFull); ext = $detectedExt }
        }
    } catch {
        $errors += "Error processing $($f.Name): $_"
    }
}
# Update local_assets_map.json if present
$mapUpdated = $false
if (Test-Path $mapPath) {
    try {
        $mapJson = Get-Content $mapPath -Raw | ConvertFrom-Json
        foreach ($r in $renamed) {
            $oldName = $r.old
            $newName = $r.new
            foreach ($prop in $mapJson.PSObject.Properties) {
                $val = $mapJson.$($prop.Name)
                if ($null -ne $val -and $val.url -ne $null) {
                    if ($val.url -eq ("assets/" + $oldName) -or $val.url -eq ("./assets/" + $oldName)) {
                        $mapJson.$($prop.Name).url = "assets/" + $newName
                        $mapUpdated = $true
                    }
                }
            }
        }
        if ($mapUpdated) {
            $mapJson | ConvertTo-Json -Depth 6 | Out-File -Encoding UTF8 $mapPath
        }
    } catch {
        $errors += "Error updating local_assets_map.json: $_"
    }
}
Write-Output "RENAMED_COUNT=$( $renamed.Count )"
if ($renamed.Count -gt 0) { $renamed | ConvertTo-Json -Depth 3 | Write-Output }
Write-Output "MAP_UPDATED=$mapUpdated"
if ($errors.Count -gt 0) { Write-Output "ERRORS:"; $errors | ForEach-Object { Write-Output $_ } }
Write-Output "DONE"
