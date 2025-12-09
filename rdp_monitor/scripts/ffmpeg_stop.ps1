# This script is intended to be executed upon RDP disconnect or logoff events.

# === Path Configuration ===
$BasePidDir = "C:\Users\cococ\Desktop\rdp-video-pjt\rdp_monitor\pids"

# 1. Get current username and define user-specific PID folder
$UserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[-1]
$PidDir = "$BasePidDir\$UserName" 

Write-Host "User Session: $UserName - Starting full cleanup in: $PidDir"

# 2. Check if the user folder exists
if (!(Test-Path $PidDir)) {
    Write-Host "PID folder not found. No processes to stop."
    exit
}

# 3. Search for all PID files in the user's folder
$PidFiles = Get-ChildItem -Path $PidDir -Filter "pid_*.txt" -ErrorAction SilentlyContinue

if ($PidFiles.Count -eq 0) {
    Write-Host "No PID files found for user ($UserName). No processes to stop."
    # Attempt to remove the user folder if it's empty (optional safety)
    Remove-Item $PidDir -Force -ErrorAction SilentlyContinue
    exit
}

Write-Host "Found $($PidFiles.Count) PID files for cleanup. Starting batch termination."

# 4. Loop through all PID files to terminate processes and delete files
foreach ($file in $PidFiles) {
    $PidFile = $file.FullName
    
    $TargetPid = Get-Content $PidFile | Select-Object -First 1

    Write-Host "   - Trying to stop PID: $TargetPid from file: $($file.Name)"
    
    # 5. Attempt process termination (주석 해제)
    try {
        Stop-Process -Id $TargetPid -Force -ErrorAction Stop
        Write-Host "   Process $TargetPid terminated successfully."
    }
    catch {
        # Catch failure if process is already gone or access is denied
        Write-Host "   Process $TargetPid termination failed (Already stopped or non-existent)."
    }

    # 6. Delete PID file regardless of termination success (주석 해제)
    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
    Write-Host "   PID File deleted: $($file.Name)"
}

# 7. Remove the user folder if it is now empty (주석 해제)
$RemainingItems = Get-ChildItem -Path $PidDir
if ($RemainingItems.Count -eq 0) {
    Remove-Item $PidDir -Force -ErrorAction SilentlyContinue
    Write-Host "Cleaned up and removed empty user folder: $PidDir"
}

Write-Host "======================================="
Write-Host "Cleanup completed for user $UserName."
Write-Host "======================================="