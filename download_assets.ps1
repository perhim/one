# PowerShell script to download assets listed in download_links_template.csv
# Usage: Open PowerShell in the repository folder and run: .\download_assets.ps1

$csv = Import-Csv -Path .\download_links_template.csv

if (!(Test-Path -Path .\assets)) {
    New-Item -ItemType Directory -Path .\assets | Out-Null
}

foreach ($row in $csv) {
    $id = $row.asset_id
    $url = $row.url_to_download
    $target = $row.suggested_filename
    if ([string]::IsNullOrWhiteSpace($url)) {
        Write-Host ("Skipping {0} - no URL provided" -f $id) -ForegroundColor Yellow
        continue
    }

    try {
        Write-Host "Downloading $id from $url -> $target"
        Invoke-WebRequest -Uri $url -OutFile $target -UseBasicParsing
        Write-Host "Saved $target" -ForegroundColor Green
    } catch {
        Write-Host ("Failed to download {0} from {1}: {2}" -f $id, $url, $_) -ForegroundColor Red
    }
}

Write-Host 'Done. Verify files in .\assets and then reload the game.'