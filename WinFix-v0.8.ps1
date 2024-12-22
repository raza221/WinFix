# Ensure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator." -ForegroundColor Yellow
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "WinFix - by Raza" -ForegroundColor Magenta
Write-Host `n
Write-Host "This is a powershell tool I've written to mainly somewhat help with recovering your Windows install from unstable RAM OCs, it can still be used generally for clearing temp files and routine checkups." -ForegroundColor Magenta
Write-Host `n
Write-Host "This tool doesn't claim to FIX your Windows install, if you fuck up bad then you'll probably have to reinstall. But it contains pretty much all that is possible to do without reinstalling the OS." -ForegroundColor Magenta

Write-Host `n
$cleanTemp = Read-Host "If you would like to run the tool now, respond by typing [Y]. To cancel the tool now, type [N]"
if ($cleanTemp -eq 'y') {
    

} Else {
    Write-Host "Skipping temporary file cleanup." -ForegroundColor Yellow
}

Write-Host "Starting system checks..." -ForegroundColor Yellow
Write-Host `n

Write-Host "Running Check Disk..." -ForegroundColor Yellow
Write-Host "Please wait, this might take several minutes..." -ForegroundColor Yellow
Write-Host `n
chkdsk /r /f /offlinescanandfix /v
Write-Host `n

Write-Host "Scanning Check Disk..." -ForegroundColor Yellow
Write-Host "Please wait, this might take several minutes..." -ForegroundColor Yellow
Write-Host `n
chkdsk /scan /perf
Write-Host `n

# Run SFC Scannow
Write-Host "Running SFC scan..." -ForegroundColor Yellow
Write-Host "Please wait, this might take several minutes..." -ForegroundColor Yellow
Write-Host `n
sfc /scannow
Write-Host `n

# Run DISM CheckHealth
Write-Host `n
Write-Host "Checking Health..." -ForegroundColor Yellow
Write-Host `n
dism /online /cleanup-image /checkhealth
Write-Host `n

# Run DISM ScanHealth
Write-Host `n
Write-Host "Scanning Health..." -ForegroundColor Yellow
Write-Host `n
dism /online /cleanup-image /scanhealth
Write-Host `n

# Run DISM RestoreHealth
Write-Host `n
Write-Host "Restoring Health..." -ForegroundColor Yellow
Write-Host `n
dism /online /cleanup-image /restorehealth
Write-Host `n

Write-Host `n
Write-Host "Success: System checks completed. Review the output for any issues." -ForegroundColor Green

Write-Host `n
$cleanTemp = Read-Host "Do you want to clear temporary files? [Recommended] (y/n)"
if ($cleanTemp -eq 'y') {
    # Clear %temp% folder
    Write-Host `n
    Write-Host "Clearing temporary files in %temp% folder..." -ForegroundColor Yellow
    Write-Host `n
    Try {
        Get-ChildItem -Path "$env:USERPROFILE\AppData\Local\Temp" -Recurse -Force | Remove-Item -Recurse -Force
        Write-Host "Successfully cleared files in %temp% folder." -ForegroundColor Green
    } Catch {
        Write-Host "Error clearing %temp% folder: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Clear Windows temp folder
    Write-Host `n
    Write-Host "Clearing temporary files in Windows 'Temp' folder..." -ForegroundColor Yellow
    Write-Host `n
    Try {
        Get-ChildItem -Path "$env:SystemDrive\Windows\Temp" -Recurse -Force | Remove-Item -Recurse -Force
        Write-Host "Successfully cleared files in Windows 'Temp' folder." -ForegroundColor Green
    } Catch {
        Write-Host "Error clearing Windows 'Temp' folder: $($_.Exception.Message)" -ForegroundColor Red
    }
} Else {
    Write-Host "Skipping temporary file cleanup." -ForegroundColor Yellow
}

# Ask user if they want to open Disk Cleanup
Write-Host `n
$runDiskCleanup = Read-Host "Do you want to open Disk Cleanup? [Optional] (y/n)"
if ($runDiskCleanup -eq 'y') {
    Write-Host `n
    Write-Host "Opening Disk Cleanup..." -ForegroundColor Yellow
    Write-Host `n
    If (Get-Command cleanmgr.exe -ErrorAction SilentlyContinue) {
        Start-Process cleanmgr.exe
    } Else {
        Write-Host "Disk Cleanup utility is not available on this system."
    }
} Else {
    Write-Host "Skipping Disk Cleanup." -ForegroundColor Yellow
}

Write-Host "Thank you for using WinFix! Hope it helped you out :)" -ForegroundColor Magenta
Write-Host `n
Write-Host "Feel free to report any bugs or suggestions to @Raza on the Overclocking Discord Server, or just say hi :D" -ForegroundColor Magenta