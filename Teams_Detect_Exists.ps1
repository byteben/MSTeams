
$Profile = @{ }
$ErrorActionPreference = "SilentlyContinue"
$CurrentUser = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName
$UserProfiles = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\*"

forEach ($UserProfile in $UserProfiles)
{
	$SecID = New-Object -TypeName System.Security.Principal.SecurityIdentifier($UserProfile.PSChildName)
	$DomUserName = $SecID.Translate([System.Security.Principal.NTAccount])
	$Profile.Add($DomUserName.Value, $UserProfile.ProfileImagePath)
}

$PathToUser = $Profile[$CurrentUser]
$PathToTeams = Join-Path -Path $PathToUser -ChildPath "\AppData\Local\Microsoft\Teams\current\Teams.exe"

if (Test-Path -LiteralPath $PathToTeams)
{
	Write-Output "Installed"
}