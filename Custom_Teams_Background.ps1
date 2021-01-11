<#	
===========================================================================
Created on:   	28/04/2020 22:08
Created by:   	Ben Whitmore
Organization: 	byteben.com
Filename:     	Custom_Teams_Background.ps1
===========================================================================

1.3 - 11/01/21
-Fixed an issue with the script not downloading content in some scenarios in PoSh 5 by using the "UseBasicParsing" option for invoke-webrequest and changing how the Full URL is created. Thanks/Credit to @DirkHaex
-Changed URI formatting

1.202804.02 - 28/04/20  Ben Whitmore @byteben.com
-Added check that switch Install/Uninstall was used

1.202804.01 - 28/04/20  Ben Whitmore @byteben.com
-Initial Release

.DESCRIPTION
Script to download an image file from a URL and place in a users Microsoft Teams Backgrounds\Uploads folder

.EXAMPLE
Custom_Teams_Background.ps1 -Install -BackgroundName "Teams_Back_1.jpg" -BackgroundUrl "https://byteben.com/bb/Downloads/Teams_Backgrounds/"

.EXAMPLE
Custom_Teams_Background.ps1 -Uninstall -BackgroundName "Teams_Back_1.jpg"

.PARAMETER Install
Switch parameter which must be used with the parameters BackgroundName and BackgroundURL but not Uninstall

.PARAMETER UnInstall
Switch parameter which must be used with the parameter BackgroundName but not BackgroundURL or Install

.PARAMETER BackgroundName
Specify the image file name located at your URL e.g. "Teams_Back_1.jpg"

.PARAMETER BackgroundUrl
Specify the BackgroundURL where youe image file is located. URL should end with a forward slash. e.g. "https://byteben.com/bb/Downloads/Teams_Backgrounds/"

#>

#Get background file name and URL from Intune app installation parameter
#NOTE: We specify these individually so we can remove the background image using the same script
Param (
    [Parameter(Mandatory = $True)]
    [string]$BackgroundName,
    [Parameter(Mandatory = $False)]
    [uri]$BackgroundUrl,
    [Switch]$Install,
    [Switch]$UnInstall
)

#Check if the Install or Uninstall parameter was passed to the script
if (1 -ne $Install.IsPresent + $Uninstall.IsPresent) {
	Write-Warning "Please specify one of either the -Install or -Uninstall parameter when running this script"
	exit 1
}

#Specify Teams custom background directory
$TeamsDir = Join-Path $ENV:Appdata "Microsoft\Teams\Backgrounds\Uploads"
$BackgroundDestination = Join-Path $TeamsDir $BackgroundName

If ($Install) {

    #Create Backgrounds\Uploads folder if it doesn't exist
    If (!(Test-Path $TeamsDir)) {
        New-Item -ItemType Directory -Path $TeamsDir -Force | Out-Null
    }

    #Create Full URL for background image
    $FullUrl = [Uri]::new([Uri]::new($BackgroundUrl), $BackgroundName).ToString()
    New-Object uri $FullUrl
    

    #Test if URL is valid
    Try {
        #Attempt URL get and set Status Code variable
        $URLRequest = Invoke-WebRequest -UseBasicParsing -URI $FullURL -ErrorAction SilentlyContinue
        $StatusCode = $URLRequest.StatusCode
    }
    Catch {
        #Catch Status Code on error
        $StatusCode = $_.Exception.Response.StatusCode.value__
        Exit 1
    }

    #If URL exists
    If ($StatusCode -eq 200) {

        #Attempt File download
        Try {
            Invoke-WebRequest -UseBasicParsing -Uri $FullUrl -OutFile $BackgroundDestination -ErrorAction SilentlyContinue

            #If download was successful, test the file was saved to the correct directory
            If (Test-Path $BackgroundDestination) {
                Write-Output "File download Successfull. File saved to $BackgroundDestination"
                Exit 0
            }
            else {
                Write-Warning "The download was interrupted or an error occured moving the file to the destination you specified"
                Exit 1
            }
        }
        Catch {
            #Catch any errors during the file download
            write-Warning "Error downloading file: $FullUrl" 
            Exit 1
        }
    }
    else {
        #For anything other than status 200 (URL OK), throw a warning
        Write-Warning "URL Does not exists or the website is down. Status Code: $StatusCode" 
        Exit 1
    }
}
If ($Uninstall) {

    #Test the file is in directory
    If (Test-Path $BackgroundDestination) {
		
        #Remove file from directory
        Remove-Item $BackgroundDestination -Force -Recurse -ErrorAction Stop 
        Exit 0
    }
    else {
        #Write warning if file does not exist
        Write-Warning "The File $BackgroundName does not exist in location $TeamsDir"
        Exit 1
    }
}