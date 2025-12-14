function Get-Config {
    $ConfigPath = "C:\rdp-video-pjt\rdp_monitor\scripts\config.txt"
    if (!(Test-Path $ConfigPath)) {
        throw "Config file not found: $ConfigPath"
    }

    $cfg = @{}
    Get-Content $ConfigPath | ForEach-Object {
        if ($_ -match "^\s*$" -or $_ -match "^\s*#") { return }
        $kv = $_ -split "=", 2
        if ($kv.Count -eq 2) {
            $cfg[$kv[0].Trim()] = $kv[1].Trim()
        }
    }
    return $cfg
}
