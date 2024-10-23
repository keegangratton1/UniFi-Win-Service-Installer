# Keegan Gratton
# UniFi Network Application install Script as Service
# v0.2



$outpath = "$env:temp/UniFi-installer.exe"
$installLocation = "C:\ProgramData\UbiquitiUnifi\"
$javaJreLocation = "$($installLocation)jre\bin\java.exe"
$aceLocation = "$($installLocation)lib\ace.jar"
$scriptLocation = "irm https://raw.githubusercontent.com/keegangratton1/UniFi-Win-Service-Installer/refs/heads/main/install.ps1 | iex"


function Welcome{

# Welcome Screen for UniFi-Win-Service-Installer

Clear-Host

# Define some colors for styling (optional)
$PrimaryColor = "Cyan"
$SecondaryColor = "Yellow"
$AccentColor = "Red"

# Display the welcome message
Write-Host "==================================================" -ForegroundColor $PrimaryColor
Write-Host "            UniFi-Win-Service-Installer            " -ForegroundColor $SecondaryColor
Write-Host "==================================================" -ForegroundColor $PrimaryColor
Write-Host ""
Write-Host "Project: UniFi-Win-Service-Installer" -ForegroundColor $SecondaryColor
Write-Host "Created by: Keegan Gratton github.com/keegangratton1" -ForegroundColor $SecondaryColor
Write-Host ""
Write-Host "This will install the newest version of UniFi for Windows and install as an Network Service" -ForegroundColor $AccentColor
Write-Host ""
Write-Host "IMPORTANT: If this is an upgrade, please ensure that backups have been completed!" -ForegroundColor $AccentColor
Write-Host ""
Write-Host "==================================================" -ForegroundColor $PrimaryColor
Write-Host ""

# Pause for the user to read the information
Pause
checkAdminStatus
}


function checkAdminStatus{
Write-host("Checking if running as admin... `n")

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host("Currently not running as an admin!")
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -command $scriptLocation" -Verb RunAs
    exit

}
Write-host("Sucessfull!")
getNewestVersion
}

function getNewestVersion {
    $web_client = new-object system.net.webclient
    $build_info=$web_client.DownloadString("https://fw-update.ubnt.com/api/firmware-latest?filter=eq~~product~~unifi-controller&filter=eq~~channel~~release&filter=eq~~platform~~windows") | ConvertFrom-Json 
    $majorVersion = $build_info._embedded.firmware.version_major
    $minorVersion = $build_info._embedded.firmware.version_minor
    $patchVersion = $build_info._embedded.firmware.version_patch

    $url = "https://dl.ui.com/unifi/$majorVersion.$minorVersion.$patchVersion/UniFi-installer.exe"
    Write-Host "Downloading UniFi Software"
    Invoke-WebRequest -Uri $url -OutFile $outpath 
    installUnifi
}


function installUnifi {
    write-host("Wait for install, Be sure to uncheck start server!")
    Start-Sleep -Seconds 5

    Start-Process -Filepath $outpath -ArgumentList /D="$installLocation" -Wait
    
    if (-not (Test-Path $aceLocation)){
            write-host("Install failed")
            pause

    }

    
    Write-Host("Install successfull!")
    killExisitingProcess

}

function installAsService {
    Start-Process -Filepath $javaJreLocation -ArgumentList "-jar $aceLocation installsvc" -NoNewWindow -Wait
    Start-Service -name UniFi


    write-host "UniFi Service is now installed! Please go to https://localhost:8443 "
    pause
}
function killExisitingProcess {
    Write-host "Stopping UniFi runtime"
    $javaProcesses = Get-Process java* | Where-Object {
        $_.Path -eq "$($installLocation)\jre\bin\javaw.exe" -or
        $_.Path -eq "$($installLocation)jre\bin\java.exe"
    }

    $javaProcesses | ForEach-Object { Stop-Process -Id $_.Id -Force }

    
    if(Get-Service -Name 'UniFi' -ErrorAction SilentlyContinue)
        {
            Write-host "Stopping UniFi Service"
            stop-Service -name "UniFi"
        }
        else
        {
            Write-Host 'UniFi Service is not already installed' 
        }
    installAsService
}

welcome


