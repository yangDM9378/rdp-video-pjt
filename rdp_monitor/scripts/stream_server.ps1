. "C:\rdp-video-pjt\rdp_monitor\scripts\common.ps1"

$config   = Get-Config
$BASE_DIR = $config["RECORD_DIR"]
$PORT     = [int]$config["SERVER_PORT"]
$LOG_DIR  = $config["LOG_DIR"]

if (!(Test-Path $LOG_DIR)) {
    New-Item -ItemType Directory -Path $LOG_DIR -Force | Out-Null
}
$LogFile = Join-Path $LOG_DIR "stream_server.log"

function Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts $Message" | Out-File $LogFile -Append -Encoding utf8
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:$PORT/")

try {
    $listener.Start()
}
catch {
    exit 1
}

Log "[SERVER] START port=$PORT base_dir=$BASE_DIR"

while ($listener.IsListening) {

    $context  = $null
    $response = $null

    try {
        $context  = $listener.GetContext()
        $request  = $context.Request
        $response = $context.Response

        $relPath = $request.QueryString["path"]
        if (-not $relPath) {
            $response.StatusCode = 400
            return
        }

        $fullPath = Join-Path $BASE_DIR $relPath
        $fullPath = [System.IO.Path]::GetFullPath($fullPath)
        $basePath = [System.IO.Path]::GetFullPath($BASE_DIR)

        if (-not $fullPath.StartsWith($basePath)) {
            $response.StatusCode = 403
            return
        }

        if (-not (Test-Path $fullPath)) {
            $response.StatusCode = 404
            return
        }

        Log "[STREAM] START path=$relPath"

        $response.ContentType = "video/webm"
        $response.StatusCode  = 200

        $fs = [System.IO.File]::OpenRead($fullPath)
        try {
            $buffer = New-Object byte[] 8192
            while (($read = $fs.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $response.OutputStream.Write($buffer, 0, $read)
            }
        }
        finally {
            $fs.Close()
        }

        Log "[STREAM] SUCCESS path=$relPath"
    }
    catch [System.ObjectDisposedException] {
        break
    }
    catch {
    }
    finally {
        if ($response -and $response.OutputStream) {
            try { $response.OutputStream.Close() } catch {}
        }
    }
}

$listener.Stop()
$listener.Close()
