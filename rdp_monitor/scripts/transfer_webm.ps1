. "C:\rdp-video-pjt\rdp_monitor\scripts\common.ps1"
$config = Get-Config

$RecordDir = $config["RECORD_DIR"]
$MoveRootDir = $config["MOVE_RECORD_DIR"] 
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

function Ensure-SftpDir {
    param([string]$RemoteDir)

    $parts = $RemoteDir.Split('/')
    $path = ""

    foreach ($p in $parts) {
        if ($p -eq "") { continue }
        $path = if ($path) { "$path/$p" } else { $p }

        $cmd = @"
mkdir $path
bye
"@
        $tmp = "$env:TEMP\sftp_mkdir_$($path.Replace('/','_')).txt"
        $cmd | Out-File $tmp -Encoding ascii

        sftp -i "$SftpKey" -b "$tmp" "$SftpUser@$SftpHost" | Out-Null
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    }
}

function Remove-SftpDirIfEmpty {
    param([string]$RemoteDir)

    $cmd = @"
rmdir $RemoteDir
bye
"@
    $tmp = "$env:TEMP\sftp_rmdir_$($RemoteDir.Replace('/','_')).txt"
    $cmd | Out-File $tmp -Encoding ascii

    sftp -i "$SftpKey" -b "$tmp" "$SftpUser@$SftpHost" | Out-Null
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
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

    $UserDirs = Get-ChildItem $dateDir.FullName -Directory

    foreach ($userDir in $UserDirs) {

        $WebmFiles = Get-ChildItem $userDir.FullName -Filter *.webm

        foreach ($webm in $WebmFiles) {

            $webmPath = $webm.FullName
            $jsonPath = [System.IO.Path]::ChangeExtension($webmPath, ".json")

            if ((Get-Item $webmPath).Length -eq 0) {
                Remove-Item $webmPath -Force
                Log "[CLEANUP] removed 0-byte webm: $($webm.Name)"

                if (Test-Path $jsonPath) {
                    Remove-Item $jsonPath -Force
                    Log "[CLEANUP] removed related json: $(Split-Path $jsonPath -Leaf)"
                }
                continue
            }

            $RemoteUserDir = "$MoveRootDir/$ServerName/$Date/$($userDir.Name)"

            Ensure-SftpDir $RemoteUserDir

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
        }

        $RemoteUserDir = "$MoveRootDir/$ServerName/$Date/$($userDir.Name)"
        Remove-SftpDirIfEmpty $RemoteUserDir

        # 로컬 사용자 폴더 정리
        if ((Get-ChildItem $userDir.FullName -Force).Count -eq 0) {
            Remove-Item $userDir.FullName -Force
            Log "[CLEANUP] removed empty local user dir: $($userDir.Name)"
        }
    }

    $RemoteDateDir = "$MoveRootDir/$ServerName/$Date"
    Remove-SftpDirIfEmpty $RemoteDateDir

    if ((Get-ChildItem $dateDir.FullName -Directory -Force).Count -eq 0) {
        Remove-Item $dateDir.FullName -Force
        Log "[CLEANUP] removed empty local date dir: $Date"
    }
}

Log "===== TRANSFER END ====="
