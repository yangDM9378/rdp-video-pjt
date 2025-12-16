. "C:\rdp-video-pjt\rdp_monitor\scripts\common.ps1"
$config = Get-Config

$RecordDir = $config["RECORD_DIR"]
$MoveRootDir = $config["MOVE_RECORD_DIR"]   # chroot 기준 상대 경로
$ServerName = $config["SERVER_NAME"]
$LogDir = $config["LOG_DIR"]

$SftpHost = $config["SFTP_HOST"]
$SftpUser = $config["SFTP_USER"]
$SftpKey = $config["SFTP_KEY"]

$Today = Get-Date -Format "yyyyMMdd"

if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

$LogFile = Join-Path $LogDir "transfer_${ServerName}.log"

function Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts $msg" | Out-File $LogFile -Append -Encoding utf8
}

Log "===== TRANSFER START ====="

$DateDirs = Get-ChildItem $RecordDir -Directory |
Where-Object {
    $_.Name -match '^\d{8}$' -and $_.Name -lt $Today
} |
Sort-Object Name

foreach ($dateDir in $DateDirs) {

    $Date = $dateDir.Name
    Log "---- Date folder: $Date ----"

    $RemoteDateDir = "$MoveRootDir/$ServerName/$Date"

    $InitCmd = @"
mkdir $MoveRootDir
mkdir $MoveRootDir/$ServerName
mkdir $RemoteDateDir
bye
"@

    $InitScript = "$env:TEMP\sftp_init_${ServerName}_${Date}.txt"
    $InitCmd | Out-File $InitScript -Encoding ascii

    sftp -i "$SftpKey" -b "$InitScript" "$SftpUser@$SftpHost" | Out-Null
    Remove-Item $InitScript -Force -ErrorAction SilentlyContinue

    $UserDirs = Get-ChildItem $dateDir.FullName -Directory

    foreach ($userDir in $UserDirs) {

        $RemoteUserDir = "$RemoteDateDir/$($userDir.Name)"

        $UserInitCmd = @"
mkdir $RemoteUserDir
bye
"@

        $UserInitScript = "$env:TEMP\sftp_user_${ServerName}_${Date}_$($userDir.Name).txt"
        $UserInitCmd | Out-File $UserInitScript -Encoding ascii

        sftp -i "$SftpKey" -b "$UserInitScript" "$SftpUser@$SftpHost" | Out-Null
        Remove-Item $UserInitScript -Force -ErrorAction SilentlyContinue

        $WebmFiles = Get-ChildItem $userDir.FullName -Filter *.webm

        foreach ($webm in $WebmFiles) {

            $webmPath = $webm.FullName
            $jsonPath = [System.IO.Path]::ChangeExtension($webmPath, ".json")

            # 0바이트 파일 제거
            if ((Get-Item $webmPath).Length -eq 0) {

                Remove-Item $webmPath -Force
                Log "[CLEANUP] removed 0-byte webm: $($webm.Name)"

                if (Test-Path $jsonPath) {
                    Remove-Item $jsonPath -Force
                    Log "[CLEANUP] removed related json: $(Split-Path $jsonPath -Leaf)"
                }
                continue
            }
            $SftpCmd = @"
cd $RemoteUserDir
put "$webmPath"
$(if (Test-Path $jsonPath) { "put `"$jsonPath`"" })
bye
"@

            $TmpScript = "$env:TEMP\sftp_put_${ServerName}_${Date}_$($webm.BaseName).txt"
            $SftpCmd | Out-File $TmpScript -Encoding ascii

            sftp -i "$SftpKey" -b "$TmpScript" "$SftpUser@$SftpHost"
            $ExitCode = $LASTEXITCODE

            Remove-Item $TmpScript -Force -ErrorAction SilentlyContinue

            if ($ExitCode -eq 0) {

                Remove-Item $webmPath -Force
                Log "[OK] transferred & removed: $($webm.Name)"

                if (Test-Path $jsonPath) {
                    Remove-Item $jsonPath -Force
                    Log "[OK] removed json: $(Split-Path $jsonPath -Leaf)"
                }

            }
            else {
                Log "[FAIL] transfer failed: $($webm.Name)"
                continue
            }

            if ((Get-ChildItem $userDir.FullName -Force).Count -eq 0) {
                Remove-Item $userDir.FullName -Force
                Log "[CLEANUP] removed empty user dir: $($userDir.Name)"
            }
        }
    }

    if ((Get-ChildItem $dateDir.FullName -Directory -Force).Count -eq 0) {
        Remove-Item $dateDir.FullName -Force
        Log "[CLEANUP] removed empty date dir: $Date"
    }
}

Log "===== TRANSFER END ====="
