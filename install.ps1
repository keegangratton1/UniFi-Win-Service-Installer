# Keegan Gratton
# UniFi Network Application install Script as Service
# v0.1


#Road map
# Error Checks
# Check service is running
# Clean up script

$outpath = "$env:temp/UniFi-installer.exe"
$installLocation = "C:\ProgramData\UbiquitiUnifi\"
$javaJreLocation = "$($installLocation)jre\bin\java.exe"
$aceLocation = "$($installLocation)lib\ace.jar"


function getNewestVersion {
    $web_client = new-object system.net.webclient
    $build_info=$web_client.DownloadString("https://fw-update.ubnt.com/api/firmware-latest?filter=eq~~product~~unifi-controller&filter=eq~~channel~~release&filter=eq~~platform~~windows") | ConvertFrom-Json 
    $majorVersion = $build_info._embedded.firmware.version_major
    $minorVersion = $build_info._embedded.firmware.version_minor
    $patchVersion = $build_info._embedded.firmware.version_patch

    $url = "https://dl.ui.com/unifi/$majorVersion.$minorVersion.$patchVersion/UniFi-installer.exe"
    Write-Host "Downloading UniFi Software"
    Invoke-WebRequest -Uri $url -OutFile $outpath 

}


function installUnifi {
    Start-Process -Filepath $outpath -ArgumentList /D="$installLocation" -Wait
    killExisitingProcess
}
function installAsService {
    Start-Process -Filepath $javaJreLocation -ArgumentList "-jar $($installLocation)lib\ace.jar installsvc" -NoNewWindow -Wait

    write-host "UniFi Service is now installed! Please go to https://localhost:8443 "
    Read-Host -Prompt "Press Enter to exit"
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



getNewestVersion
installUnifi