function Load-Config {
    param(
        [string]$configFile = "C:\rdp_monitor\scripts\config.txt"
    )

    $config = @{}

    if (Test-Path $configFile) {
        Get-Content $configFile | ForEach-Object {
            if ($_ -match "^\s*#") { return }   # 주석 제외
            if ($_ -match "^\s*$") { return }   # 빈 줄 제외

            $parts = $_ -split "=", 2
            if ($parts.Count -eq 2) {
                $key = $parts[0].Trim()
                $value = $parts[1].Trim()
                $config[$key] = $value
            }
        }
    }

    return $config
}
