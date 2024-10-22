# UniFi-Win-Service-Installer


This script installs and configures the UniFi Controller as a Windows service. Below are the two methods for installing this service on your system.

## Getting Started

### Method 1: Install via PowerShell (Recommended)

Run the following command in a PowerShell console:

```powershell
irm https://raw.githubusercontent.com/keegangratton1/UniFi-Win-Service-Installer/refs/heads/main/install.ps1 | iex
```

### Method 2: Manual Installation

1. Download the .zip file from the GitHub repository.
2. Extract the contents to a folder of your choice.
3. Open a cmd console or run window and run the following command to install:
```
powershell.exe -executionpolicy bypass -file "install.ps1"
```

## Roadmap

* Error Handling: Implement robust error checks to handle potential issues during installation.
* Service Status Check: Add functionality to verify that the UniFi service is running after installation.
* Script Cleanup: Ensure the script performs clean-up tasks, like removing temporary files, after successful installation
* Add firewall rules.
