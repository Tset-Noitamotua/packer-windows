
# Powershell script to upgrade a PowerShell 2.0 system to PowerShell 3.0
# based on http://occasionalutility.blogspot.com/2013/11/everyday-powershell-part-7-powershell.html
#
# some Ansible modules that may use Powershell 3 features, so systems may need
# to be upgraded.  This may be used by a sample playbook.  Refer to the windows
# documentation on docs.ansible.com for details.
#
# - hosts: windows
#   tasks:
#     - script: upgrade_to_ps3.ps1

# Get version of OS

# 6.0 is 2008
# 6.1 is 2008 R2
# 6.2 is 2012
# 6.3 is 2012 R2

$powershellpath = "C:\powershell"
if (!(Test-Path $powershellpath)) {
    New-Item -ItemType directory -Path $powershellpath
}

function Download-File {
    param ([string]$path, [string]$local)
    $client = New-Object system.net.WebClient
    $client.Headers.Add("user-agent", "PowerShell")
    $client.downloadfile($path, $local)
}

if (!($PSVersionTable.psversion.Major -ge 3)) {
    # .NET Framework 4.0 is necessary.
    if (($PSVersionTable.CLRVersion.Major) -le 2) {
        $DownloadUrl = "http://download.microsoft.com/download/B/A/4/BA4A7E71-2906-4B2D-A0E1-80CF16844F5F/dotNetFx45_Full_x86_x64.exe"
        $FileName = $DownLoadUrl.Split('/')[-1]
        Write-Host "Downloading .NET 4.5 -> $downloadurl"
        Download-File $downloadurl "$powershellpath\$filename"
        Write-Host "Installing .NET 4.5 ..."
        Start-Process -Wait -FilePath "$powershellpath\$filename" -ArgumentList "/quiet", "/norestart"
    }

    # You may need to reboot after the .NET install if so just run the script again.
    # If the Operating System is above 6.2, then you already have PowerShell Version > 3
    if ([Environment]::OSVersion.Version.Major -gt 6) {
        Write-Host "OS is new; upgrade not needed."
        Exit
    }

    $DownloadUrl="https://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu"
    $FileName = $DownLoadUrl.Split('/')[-1]
    Write-Host "Downloading WMF 4.0 update -> $downloadurl ..."
    Download-File $downloadurl "$powershellpath\$filename"
    Write-Host "Installing WMF 4.0 update ..."
    Start-Process -Wait -FilePath "$powershellpath\$filename" -ArgumentList "/quiet"
    Write-Host "WMF 4.0 update installed"
} else {
    Write-Host "Powershell 3 Installed already; You don't need this"
}

# Configure for Ansible
Write-Host "Configuring Ansible for Windows ..."
$DownloadUrl="https://raw.githubusercontent.com/cchurch/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$FileName = $DownLoadUrl.Split('/')[-1]
Download-File $downloadurl "$powershellpath\$filename"
Write-Host "$powershellpath\$filename"
Start-Process powershell.exe -Wait -ArgumentList "$powershellpath\$filename"
Write-Host "Ansible for Windows configured"


# Install Chocolatey
$chocoExePath = 'C:\ProgramData\Chocolatey\bin'
if (!$($env:Path).ToLower().Contains($($chocoExePath).ToLower())) {
    # Add to system PATH
    $systemPath = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine)
    $systemPath += ';' + $chocoExePath
    [Environment]::SetEnvironmentVariable("PATH", $systemPath, [System.EnvironmentVariableTarget]::Machine)
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
    echo "Chocolatey found in PATH, skipping install..."
}


# Install OpenSSH and start it
Start-Process powershell.exe -Wait -ArgumentList "-NoExit", "a:\openssh.ps1", "-AutoStart"
