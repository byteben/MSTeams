<#
===========================================================================
Created on:   22/10/2020
Created by:   Ben Whitmore
Filename:     New_Team.ps1
===========================================================================

.DESCRIPTION
Script to create a New Team and set the Owner

MicrosoftTeams module required and also a connection to MicrosoftTeams: -
Import-Module MicrosoftTeams
Connect-MicrosoftTeams

.PARAMETER TeamName 
The new Team Name 

.PARAMETER Owner 
The UPN of the team owner

.Example 
'New_Team.ps1' -TeamName "Critical Response" -Owner "barryboo@byteben.com"

#>

param (
    [Parameter(Mandatory = $True)]
    [string] $TeamName,
    [string] $Owner
)

#Checking if Team exists
Write-Output "Checking if Team `"$TeamName`" already exists...`n"
$TeamExists = Get-Team | Where-Object { $_.DisplayName -eq $TeamName }

If ($TeamExists) {
    Write-Warning "`"$TeamName`" already exists on this tenant. Aborting operation.`n"
}
else {
    Write-output "`"$TeamName`" does not exist on this tenant. Continuing operation...`n"

    #Checking if Owner exists
    Write-Output "Checking if user `"$Owner`" exists on this tenant...`n"
    $UserExists = Get-MsolUser -UserPrincipalName $Owner | Select-Object -ExpandProperty UserPrincipalName

    If (!($UserExists)) {
        Write-Warning "`"$UserExists`" does not exist on this tenant. Aborting operation.`n"
    }
    else {
        Write-output "`"$UserExists`" exists on this tenant. Continuing operation...`n"

        #Checking if Owner has the correct licence
        Write-Output "Checking if user `"$Owner`" has a valid licence...`n"
        $UserLicenceValid = Get-MsolUser -UserPrincipalName $Owner | Where-Object { ($_.licenses).AccountSkuId -match "ENTERPRISEPACK" }

        If (!($UserLicenceValid)) {
            Write-Warning "`"$Owner`" does not have a valid licence on this tenant. Aborting operation.`n"
        }
        else {
            Write-output "`"$Owner`" has a valid licence on this tenant. Continuing operation...`n"

            #Create new Team
            Write-output "Creating Team `"$TeamName`" on this tenant...`n"
            New-Team -DisplayName $TeamName -Owner $Owner -visibility Private
        }
    }
}