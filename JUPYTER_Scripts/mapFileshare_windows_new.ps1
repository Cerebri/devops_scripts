Param(
        [string]$accountName,
        [string]$accountKey
        )

$cmd = "net use z: \\$accountName.file.core.windows.net\scratch /u:$accountName $accountKey"
$cmd | Set-Content "c:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\ConnectShare.cmd"

Restart-Computer -Force
