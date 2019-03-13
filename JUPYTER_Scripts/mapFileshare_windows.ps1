Param(
[string]$accountName,
[string]$accountKey
)

$connectFile = "c:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\ConnectShare.cmd"

if (!(Test-Path $connectFile -PathType Leaf)) {

	net use * /delete
	$cmd = "net use y: \\$accountName.file.core.windows.net\scratch /u:$accountName $accountKey"
	$cmd | Add-Content $connectFile

	#New-ItemProperty -Path 'HKLM:SystemCurrentControlSetControlTerminal Server' -Name 'fDenyTSConnections' -Value 0 -PropertyType dword -Force
	#New-ItemProperty -Path 'HKLM:SystemCurrentControlSetControlTerminal ServerWinStationsRDP-Tcp' -Name 'UserAuthentication' -Value 1 -PropertyType dword -Force

	#Restart-Computer -Force -AsJob

	}
