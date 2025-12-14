function Send-MetaToApi {
    param (
        [string]$MetaFile,
        [string]$LogDir
    )

    . "C:\rdp-video-pjt\rdp_monitor\scripts\common.ps1"
    $config = Get-Config
    $ApiUrl = $config["METADATA_API_URL"]

    if (!(Test-Path $MetaFile)) { return $false }

    try {
        $meta = Get-Content $MetaFile -Raw | ConvertFrom-Json

        if ($meta.uploaded -eq 1) {
            return $true
        }

        $body = $meta | ConvertTo-Json -Depth 5

        $response = Invoke-RestMethod `
            -Uri $ApiUrl `
            -Method POST `
            -Body $body `
            -ContentType "application/json" `
            -TimeoutSec 5

        if ($response.result -eq "ok") {
            $meta.uploaded = 1
            $meta.upload_time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $meta | ConvertTo-Json -Depth 5 | Out-File $MetaFile -Encoding utf8
            return $true
        }
    }
    catch {
        if (!(Test-Path $LogDir)) {
            New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        } 
        $msg = "[{0}] META SEND FAIL: {1}" -f `
            (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $_.Exception.Message
        Add-Content -Path "$LogDir\meta_send_error.log" -Value $msg
    }

    return $false
}
