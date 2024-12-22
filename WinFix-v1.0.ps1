# Ensure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator." -ForegroundColor Yellow
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Welcome and Information
Write-Host "WinFix - by Raza" -ForegroundColor Magenta
Write-Host "`n"
Write-Host "`nThis tool helps recover Windows from unstable RAM OCs and general maintenance." -ForegroundColor Yellow
Write-Host "`nNote: This script does not guarantee fixes for major issues. Reinstallation may still be necessary if you fucked up bad." -ForegroundColor Yellow
Write-Host "`n"

# Confirm Starting the Tool
$startTool = Read-Host "If you would like to run the tool now, type [Y]. To cancel, type [N]"
if ($startTool -notmatch '^[Yy]$') {
    Write-Host "`n"
    Write-Host "Tool canceled by user." -ForegroundColor Red
    Start-Sleep -Seconds 2
    exit
}

# System Checks
Write-Host "Starting system checks..." -ForegroundColor Yellow
Write-Host "`nRunning Check Disk... (this may take several minutes)"
chkdsk /r /f /offlinescanandfix /v
chkdsk /scan /perf

Write-Host "`nRunning SFC Scan..."
sfc /scannow

Write-Host "`nRunning DISM Health Checks..."
dism /online /cleanup-image /checkhealth
dism /online /cleanup-image /scanhealth
dism /online /cleanup-image /restorehealth

Write-Host "`nSystem checks completed successfully. Review the output for any issues." -ForegroundColor Green

# Temporary File Cleanup
$cleanTemp = Read-Host "Do you want to clear temporary files? [Recommended] (y/n)"
if ($cleanTemp -match '^[Yy]$') {
    Write-Host "`nClearing temporary files in %temp% folder..." -ForegroundColor Yellow
    Try {
        Get-ChildItem -Path "$env:USERPROFILE\AppData\Local\Temp" -Recurse -Force | Remove-Item -Recurse -Force
        Write-Host "Successfully cleared files in %temp% folder." -ForegroundColor Green
    } Catch {
        Write-Host "Error clearing %temp% folder: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "`nClearing temporary files in Windows 'Temp' folder..." -ForegroundColor Yellow
    Try {
        Get-ChildItem -Path "$env:SystemDrive\Windows\Temp" -Recurse -Force | Remove-Item -Recurse -Force
        Write-Host "Successfully cleared files in Windows 'Temp' folder." -ForegroundColor Green
    } Catch {
        Write-Host "Error clearing Windows 'Temp' folder: $($_.Exception.Message)" -ForegroundColor Red
    }
} Else {
    Write-Host "Skipping temporary file cleanup." -ForegroundColor Yellow
}

# Disk Cleanup
$runDiskCleanup = Read-Host "Do you want to open Disk Cleanup? [Optional] (y/n)"
if ($runDiskCleanup -match '^[Yy]$') {
    Write-Host "`nOpening Disk Cleanup..." -ForegroundColor Yellow
    if (Get-Command cleanmgr.exe -ErrorAction SilentlyContinue) {
        Start-Process cleanmgr.exe
    } else {
        Write-Host "Disk Cleanup utility is not available on this system." -ForegroundColor Red
    }
} Else {
    Write-Host "Skipping Disk Cleanup." -ForegroundColor Yellow
}

# Closing Message
Write-Host "`nThank you for using WinFix! Hope it helped you out :)" -ForegroundColor Magenta
Write-Host "Feel free to report any bugs or suggestions to @Raza on the Overclocking Discord Server!" -ForegroundColor Magenta
