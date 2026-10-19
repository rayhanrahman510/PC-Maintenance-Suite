@echo off
:: --- ADMINISTRATOR PRIVILEGE CHECK & AUTO-ELEVATION ---
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :confirmed_admin
) else (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:confirmed_admin
cls
title Ultimate PC Diagnostics & Maintenance Suite Launcher (2026)
cd /d "%~dp0"

echo ===========================================================
echo         INITIALIZING PC MAINTENANCE SUITE
echo ===========================================================
echo This utility will temporarily unpack the full diagnostics 
echo matrix and guide you through an interactive tuning process.
echo ===========================================================
echo.
set /p proceed="Do you want to run the suite right now? (y/n): "
if /i "%proceed%" NEQ "y" (
    echo Cancellation confirmed. Exiting...
    timeout /t 3 >nul
    exit /b
)

:: --- CREATING THE TEMPORARY POWERSHELL SUITE ---
set "ps_file=%temp%\PC_Maintenance_Suite_Temp.ps1"

echo Writing temporary execution profiles...
(
echo # Requires -RunAsAdministrator
echo cls
echo $Host.UI.RawUI.WindowTitle = "Ultimate PC Diagnostics & Maintenance Suite (2026)"
echo.
echo $logFile = "$env:USERPROFILE\Desktop\PC_Maintenance_Suite_Log.txt"
echo.
echo function Write-Log {
echo     param^([int]$OptionNumber, [string]$OptionName^)
echo     $entry = "{0}||{1}||{2}" -f ^(Get-Date -Format "yyyy-MM-dd HH:mm:ss"^), $OptionNumber, $OptionName
echo     Add-Content -Path $logFile -Value $entry
echo }
echo.
echo function Get-LastUsed {
echo     param^([int]$OptionNumber^)
echo     if ^(-not ^(Test-Path $logFile^)^) { return "Never" }
echo     $match = Get-Content $logFile ^| Where-Object { ^($_ -split '\^|\^|'^)[1] -eq "$OptionNumber" } ^| Select-Object -Last 1
echo     if ^($match^) { return ^($match -split '\^|\^|'^)[0] } else { return "Never" }
echo }
echo.
echo function Get-ToolName {
echo     param^([int]$OptionNumber^)
echo     switch ^($OptionNumber^) {
echo         1  { "Deep Repair (DISM and SFC)" }
echo         2  { "Junk Cleanup" }
echo         3  { "App Engine Bulk Update" }
echo         4  { "Total Uninstall" }
echo         5  { "Pin Exclusion" }
echo         6  { "Battery and Energy Audit" }
echo         7  { "RAM Diagnostic" }
echo         8  { "Drive Health Chkdsk" }
echo         9  { "Storage Optimize" }
echo         10 { "Network Recovery" }
echo         11 { "Driver Backup" }
echo         12 { "Component Clean" }
echo         13 { "Quick Clean (RecycleBin/Temp/Prefetch/Recent)" }
echo         14 { "PC Power Manager" }
echo         15 { "Folder Lock Manager" }
echo         16 { "WinUtil (Chris Titus Tech)" }
echo         default { "Unknown Tool" }
echo     }
echo }
echo.
echo function Show-Menu {
echo     Clear-Host
echo     Write-Host "===========================================================" -ForegroundColor Cyan
echo     Write-Host "         ULTIMATE PC DIAGNOSTICS & MAINTENANCE SUITE        " -ForegroundColor Cyan
echo     Write-Host "===========================================================" -ForegroundColor Cyan
echo     Write-Host " ---- SYSTEM MAINTENANCE ----" -ForegroundColor DarkCyan
echo     Write-Host " [1] DEEP REPAIR: Run Sequential Component Store & SFC Fix `t[Last used: $(Get-LastUsed 1)]"
echo     Write-Host " [2] JUNK CLEANUP: Purge Delivery, Update & System Temp Caches `t[Last used: $(Get-LastUsed 2)]"
echo     Write-Host " [3] APP ENGINE: Bulk Update All Unpinned Apps `t[Last used: $(Get-LastUsed 3)]"
echo     Write-Host " [4] TOTAL UNINSTALL: List Apps & Erase Their Existence `t[Last used: $(Get-LastUsed 4)]"
echo     Write-Host " [5] PIN EXCLUSION: Block Specific Apps From Updating `t[Last used: $(Get-LastUsed 5)]"
echo     Write-Host " [6] BATTERY/ENERGY AUDIT: Generate Deep System Health Report `t[Last used: $(Get-LastUsed 6)]"
echo     Write-Host " [7] RAM DIAGNOSTIC: Schedule Low-Level Memory Test on Reboot `t[Last used: $(Get-LastUsed 7)]"
echo     Write-Host " [8] DRIVE HEALTH: Run Chkdsk Volume File System Scan `t[Last used: $(Get-LastUsed 8)]"
echo     Write-Host " [9] STORAGE OPTIMIZE: Run TRIM (SSD) or Defrag (HDD) `t[Last used: $(Get-LastUsed 9)]"
echo     Write-Host " [10] NETWORK RECOVERY: Full Adapter Flush & DNS Reset `t[Last used: $(Get-LastUsed 10)]"
echo     Write-Host " [11] DRIVER BACKUP: Export All Device Drivers to Desktop `t[Last used: $(Get-LastUsed 11)]"
echo     Write-Host " [12] COMPONENT CLEAN: Scrub Superseded/Old Windows Updates `t[Last used: $(Get-LastUsed 12)]"
echo     Write-Host " [13] QUICK CLEAN: One-Click Recycle Bin, Temp, Prefetch & Recent Purge `t[Last used: $(Get-LastUsed 13)]"
echo     Write-Host ""
echo     Write-Host " ---- POWER & SECURITY TOOLS ----" -ForegroundColor DarkCyan
echo     Write-Host " [14] POWER MANAGER: Scheduled Shutdown, Restart, Sleep, Lock & More `t[Last used: $(Get-LastUsed 14)]"
echo     Write-Host " [15] FOLDER LOCK MANAGER: Lock/Unlock Folders via NTFS Permissions `t[Last used: $(Get-LastUsed 15)]"
echo     Write-Host ""
echo     Write-Host " ---- EXTERNAL TOOL ----" -ForegroundColor DarkCyan
echo     Write-Host " [16] WINUTIL: Chris Titus Tech Windows Toolbox (interactive menu, live remote script) `t[Last used: $(Get-LastUsed 16)]"
echo     Write-Host ""
echo     Write-Host " [17] EXIT & PURGE TEMP DATA"
echo     Write-Host "===========================================================" -ForegroundColor Cyan
echo     Write-Host ""
echo     Write-Host "Enter one or more tool numbers to run them in sequence, e.g. 2,9,1" -ForegroundColor DarkGray
echo     Write-Host "Note: tools 14, 15 and 16 open their own session/menu and hold the sequence until you exit them." -ForegroundColor DarkGray
echo     Write-Host ""
echo }
echo.
echo function Invoke-Tool1 {
echo     Write-Host "--- [1] Deep Repair ---" -ForegroundColor Yellow
echo     Write-Host "1. Repairing underlying Windows Core Component Image..." -ForegroundColor Gray
echo     DISM /Online /Cleanup-Image /RestoreHealth
echo     Write-Host "2. Verifying and correcting protected local system files..." -ForegroundColor Gray
echo     sfc /scannow
echo }
echo.
echo function Invoke-Tool2 {
echo     Write-Host "--- [2] Junk Cleanup ---" -ForegroundColor Yellow
echo     Write-Host "Stopping dependent update services..." -ForegroundColor Gray
echo     Get-Service -Name wuauserv, bits, cryptsvc -ErrorAction SilentlyContinue ^| Stop-Service -Force -ErrorAction SilentlyContinue
echo     Write-Host "Clearing Delivery Optimization cache..." -ForegroundColor Gray
echo     Delete-DeliveryOptimizationCache -Force -ErrorAction SilentlyContinue
echo     Write-Host "Clearing User and System temporary folders..." -ForegroundColor Gray
echo     Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
echo     Remove-Item "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
echo     Write-Host "Restarting core Windows Update subsystems..." -ForegroundColor Gray
echo     Get-Service -Name wuauserv, bits, cryptsvc -ErrorAction SilentlyContinue ^| Start-Service -ErrorAction SilentlyContinue
echo     Write-Host "Cache structures successfully flushed!" -ForegroundColor Green
echo }
echo.
echo function Invoke-Tool3 {
echo     Write-Host "--- [3] App Engine Bulk Update ---" -ForegroundColor Yellow
echo     Write-Host "Scanning repository manifests (excluding pinned applications)..." -ForegroundColor Gray
echo     winget upgrade --all --include-unknown
echo }
echo.
echo function Invoke-Tool4 {
echo     Write-Host "--- [4] Total Uninstall ---" -ForegroundColor Yellow
echo     Write-Host ""
echo     Write-Host "*** ACTION REQUIRED - Tool 4: Total Uninstall ***" -ForegroundColor Red
echo     Write-Host "This tool cannot continue automatically: it needs you to identify" -ForegroundColor Yellow
echo     Write-Host "which installed application to permanently remove. Execution pauses" -ForegroundColor Yellow
echo     Write-Host "here until you respond. Leave the answer blank to skip this tool." -ForegroundColor Yellow
echo     Write-Host "--------------------------------------------------------" -ForegroundColor Gray
echo     $apps = winget list --source winget 2^>$null ^| Select-String -Pattern '^\S' ^| Select-Object -Skip 2
echo     if ^(-not $apps^) {
echo         Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* ^| Select-Object DisplayName, DisplayVersion ^| Format-Table
echo         $appId = Read-Host "`nEnter the exact name of the app to uninstall"
echo     } else {
echo         $apps ^| Out-String
echo         Write-Host "--------------------------------------------------------" -ForegroundColor Gray
echo         $appId = Read-Host "`nEnter the exact ID or Name of the app you want to erase"
echo     }
echo     if ^($appId^) {
echo         Write-Host "`nInitiating silent purge for: $appId..." -ForegroundColor Cyan
echo         winget uninstall --id $appId --silent --purge
echo         if ^($LASTEXITCODE -ne 0^) { winget uninstall --name $appId --silent --purge }
echo         Write-Host "`nRemoval process executed. Restart your PC later to drop locked files." -ForegroundColor Yellow
echo     } else {
echo         Write-Host "No app specified - skipping Tool 4." -ForegroundColor Gray
echo     }
echo }
echo.
echo function Invoke-Tool5 {
echo     Write-Host "--- [5] Pin Exclusion ---" -ForegroundColor Yellow
echo     Write-Host ""
echo     Write-Host "*** ACTION REQUIRED - Tool 5: Pin Exclusion ***" -ForegroundColor Red
echo     Write-Host "This tool needs you to choose a pin action before it can continue." -ForegroundColor Yellow
echo     Write-Host "Execution pauses here until you respond." -ForegroundColor Yellow
echo     Write-Host "1. List currently pinned/excluded applications"
echo     Write-Host "2. Pin an application (Block it from auto-updating)"
echo     Write-Host "3. Remove a pin (Allow it to update again)"
echo     $pinChoice = Read-Host "`nSelect Option (1-3)"
echo     if ^($pinChoice -eq "1"^) {
echo         winget pin list
echo     } elseif ^($pinChoice -eq "2"^) {
echo         $pId = Read-Host "Enter the exact Application ID to pin (e.g., Corel.Draw)"
echo         winget pin add --id $pId --blocking
echo     } elseif ^($pinChoice -eq "3"^) {
echo         $pId = Read-Host "Enter the exact Application ID to unpin"
echo         winget pin remove --id $pId
echo     } else {
echo         Write-Host "No valid selection made - skipping Tool 5." -ForegroundColor Gray
echo     }
echo }
echo.
echo function Invoke-Tool6 {
echo     Write-Host "--- [6] Battery/Energy Audit ---" -ForegroundColor Yellow
echo     $reportPath = "$env:USERPROFILE\Desktop\Battery_Report.html"
echo     Write-Host "Analyzing system history... This takes roughly 60 seconds." -ForegroundColor Gray
echo     powercfg /batteryreport /output $reportPath ^>$null
echo     Write-Host "Report successfully built! File saved to your Desktop as: Battery_Report.html" -ForegroundColor Green
echo }
echo.
echo function Invoke-Tool7 {
echo     Write-Host "--- [7] RAM Diagnostic ---" -ForegroundColor Yellow
echo     Write-Host ""
echo     Write-Host "*** ACTION REQUIRED - Tool 7: RAM Diagnostic ***" -ForegroundColor Red
echo     Write-Host "This launches a separate Windows Memory Diagnostic window." -ForegroundColor Yellow
echo     Write-Host "In that window you must choose Restart now or Check on next restart." -ForegroundColor Yellow
echo     Write-Host "The script itself continues automatically, but the actual memory" -ForegroundColor Yellow
echo     Write-Host "test only runs after you restart the PC." -ForegroundColor Yellow
echo     Write-Host "Configuring the Windows Memory Diagnostic engine..." -ForegroundColor Gray
echo     mdsched.exe
echo     Write-Host "`nA separate configuration panel has popped up." -ForegroundColor Cyan
echo }
echo.
echo function Invoke-Tool8 {
echo     Write-Host "--- [8] Drive Health Chkdsk ---" -ForegroundColor Yellow
echo     chkdsk C: /scan
echo     Write-Host ""
echo     Write-Host "*** ACTION REQUIRED - Tool 8: Drive Health ***" -ForegroundColor Red
echo     Write-Host "If structural errors were flagged above, a deep boot repair can fix them." -ForegroundColor Yellow
echo     Write-Host "It requires a full restart and can take a long time on large or errored drives." -ForegroundColor Yellow
echo     $ansFix = Read-Host "Schedule a hard fix on next restart? (y/n)"
echo     if ^($ansFix -eq 'y'^) { echo Y ^| chkdsk C: /f /r }
echo }
echo.
echo function Invoke-Tool9 {
echo     Write-Host "--- [9] Storage Optimize ---" -ForegroundColor Yellow
echo     Write-Host "Detecting volume type and initiating TRIM or Defrag sequence..." -ForegroundColor Gray
echo     Optimize-Volume -DriveLetter C -Verbose
echo }
echo.
echo function Invoke-Tool10 {
echo     Write-Host "--- [10] Network Recovery ---" -ForegroundColor Yellow
echo     Write-Host "Flushing DNS and releasing active IP leases..." -ForegroundColor Gray
echo     ipconfig /flushdns
echo     ipconfig /release
echo     ipconfig /renew
echo     Write-Host "Resetting Winsock catalog interface..." -ForegroundColor Gray
echo     netsh winsock reset
echo     Write-Host "Cycling physical network interfaces..." -ForegroundColor Gray
echo     Get-NetAdapter -Physical ^| Restart-NetAdapter
echo     Write-Host "Network pipelines fully reset." -ForegroundColor Green
echo }
echo.
echo function Invoke-Tool11 {
echo     Write-Host "--- [11] Driver Backup ---" -ForegroundColor Yellow
echo     $backupPath = "$env:USERPROFILE\Desktop\DriverBackup_" + ^(Get-Date -Format "yyyyMMdd"^)
echo     New-Item -Path $backupPath -ItemType Directory -Force ^| Out-Null
echo     Write-Host "Exporting to directory: $backupPath" -ForegroundColor Gray
echo     Export-WindowsDriver -Online -Destination $backupPath
echo     Write-Host "Driver safety archive established successfully on Desktop!" -ForegroundColor Green
echo }
echo.
echo function Invoke-Tool12 {
echo     Write-Host "--- [12] Component Clean ---" -ForegroundColor Yellow
echo     Write-Host "Scrubbing obsolete, superseded package baselines..." -ForegroundColor Gray
echo     DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase
echo     Write-Host "Component store compression completed safely." -ForegroundColor Green
echo }
echo.
echo function Invoke-Tool13 {
echo     Write-Host "--- [13] Quick Clean ---" -ForegroundColor Yellow
echo     Write-Host "Emptying Recycle Bin..." -ForegroundColor Gray
echo     Clear-RecycleBin -Force -ErrorAction SilentlyContinue
echo     Write-Host "Clearing user Temp folder ($env:TEMP)..." -ForegroundColor Gray
echo     Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
echo     Write-Host "Clearing system Temp folder..." -ForegroundColor Gray
echo     Remove-Item "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
echo     Write-Host "Clearing Prefetch cache..." -ForegroundColor Gray
echo     Remove-Item "$env:SystemRoot\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
echo     Write-Host "Clearing Recent items list..." -ForegroundColor Gray
echo     Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force -ErrorAction SilentlyContinue
echo     Write-Host "Clearing Windows Error Reporting queue..." -ForegroundColor Gray
echo     Remove-Item "$env:ProgramData\Microsoft\Windows\WER\ReportQueue\*" -Recurse -Force -ErrorAction SilentlyContinue
echo     Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\WER\ReportQueue\*" -Recurse -Force -ErrorAction SilentlyContinue
echo     Write-Host "Clearing thumbnail cache..." -ForegroundColor Gray
echo     Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue
echo     Write-Host "Clearing leftover Windows Update download cache..." -ForegroundColor Gray
echo     Remove-Item "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
echo     Write-Host "`nQuick Clean complete!" -ForegroundColor Green
echo }
echo.
echo function Get-DelayMinutes {
echo     $mins = Read-Host "Enter delay time in MINUTES"
echo     return [int]$mins * 60
echo }
echo.
echo function Get-ForceFlag {
echo     $forceChoice = Read-Host "Force close stuck applications? (y/n)"
echo     if ^($forceChoice -ieq 'y'^) { return '/f' } else { return '' }
echo }
echo.
echo function Show-Countdown {
echo     param^([int]$Seconds^)
echo     for ^($i = $Seconds; $i -gt 0; $i--^) {
echo         Write-Progress -Activity "Power Action Pending" -Status "Time remaining: $i seconds" -PercentComplete ^(^($i / $Seconds^) * 100^)
echo         Start-Sleep -Seconds 1
echo     }
echo     Write-Progress -Activity "Power Action Pending" -Completed
echo }
echo.
echo function Invoke-Tool14 {
echo     do {
echo         Clear-Host
echo         Write-Host "===================================================" -ForegroundColor Cyan
echo         Write-Host "            PC POWER MANAGER PRO (2026)" -ForegroundColor Cyan
echo         Write-Host "===================================================" -ForegroundColor Cyan
echo         Write-Host " 1. Schedule standard SHUTDOWN"
echo         Write-Host " 2. Schedule HYBRID SHUTDOWN (Fast Startup)"
echo         Write-Host " 3. Schedule RESTART"
echo         Write-Host " 4. Schedule SLEEP (Suspend to RAM)"
echo         Write-Host " 5. Schedule HIBERNATE (Suspend to Disk)"
echo         Write-Host " 6. Schedule USER LOG OFF"
echo         Write-Host " 7. Schedule SCREEN LOCK"
echo         Write-Host " 8. Cancel any active Windows timers"
echo         Write-Host " 9. Back to main menu"
echo         Write-Host "===================================================" -ForegroundColor Cyan
echo         $pmChoice = Read-Host "Select an action (1-9)"
echo.
echo         switch ^($pmChoice^) {
echo             "1" {
echo                 $secs = Get-DelayMinutes
echo                 $force = Get-ForceFlag
echo                 $sdArgs = @^('/s', '/t', "$secs"^)
echo                 if ^($force -eq '/f'^) { $sdArgs += '/f' }
echo                 shutdown @sdArgs
echo                 Write-Host "Native Windows shutdown timer initiated." -ForegroundColor Green
echo                 Read-Host "Press Enter to continue"
echo             }
echo             "2" {
echo                 $secs = Get-DelayMinutes
echo                 shutdown /s /hybrid /t $secs
echo                 Write-Host "Hybrid shutdown (Fast Startup) timer initiated." -ForegroundColor Green
echo                 Read-Host "Press Enter to continue"
echo             }
echo             "3" {
echo                 $secs = Get-DelayMinutes
echo                 $force = Get-ForceFlag
echo                 $sdArgs = @^('/r', '/t', "$secs"^)
echo                 if ^($force -eq '/f'^) { $sdArgs += '/f' }
echo                 shutdown @sdArgs
echo                 Write-Host "Native Windows restart timer initiated." -ForegroundColor Green
echo                 Read-Host "Press Enter to continue"
echo             }
echo             "4" {
echo                 $secs = Get-DelayMinutes
echo                 Write-Host "Countdown started... Keep this window open." -ForegroundColor Yellow
echo                 Show-Countdown -Seconds $secs
echo                 Add-Type -AssemblyName System.Windows.Forms
echo                 [System.Windows.Forms.Application]::SetSuspendState^([System.Windows.Forms.PowerState]::Suspend, $false, $false^)
echo             }
echo             "5" {
echo                 $secs = Get-DelayMinutes
echo                 Write-Host "Countdown started... Keep this window open." -ForegroundColor Yellow
echo                 Show-Countdown -Seconds $secs
echo                 shutdown /h
echo             }
echo             "6" {
echo                 $secs = Get-DelayMinutes
echo                 Write-Host "Countdown started... Keep this window open." -ForegroundColor Yellow
echo                 Show-Countdown -Seconds $secs
echo                 shutdown /l
echo             }
echo             "7" {
echo                 $secs = Get-DelayMinutes
echo                 Write-Host "Countdown started... Keep this window open." -ForegroundColor Yellow
echo                 Show-Countdown -Seconds $secs
echo                 rundll32.exe user32.dll,LockWorkStation
echo             }
echo             "8" {
echo                 shutdown /a 2^>$null
echo                 Write-Host "Active native timers aborted." -ForegroundColor Green
echo                 Write-Host "Note: if you triggered Sleep, Lock, or Hibernate, that action already ran and cannot be cancelled once it starts." -ForegroundColor DarkGray
echo                 Read-Host "Press Enter to continue"
echo             }
echo             "9" { return }
echo             default { Write-Host "Invalid selection." -ForegroundColor Red; Start-Sleep -Seconds 1 }
echo         }
echo     } while ^($pmChoice -ne "9"^)
echo }
echo.
echo function Invoke-Tool15 {
echo     $trackDir = "$env:ProgramData\FolderLockManager"
echo     $trackFile = "$trackDir\LockedFolders.txt"
echo     if ^(-not ^(Test-Path $trackDir^)^) { New-Item -Path $trackDir -ItemType Directory -Force ^| Out-Null }
echo     if ^(-not ^(Test-Path $trackFile^)^) { New-Item -Path $trackFile -ItemType File -Force ^| Out-Null }
echo.
echo     do {
echo         Clear-Host
echo         Write-Host "================================" -ForegroundColor Cyan
echo         Write-Host "      Folder Lock Manager" -ForegroundColor Cyan
echo         Write-Host "================================" -ForegroundColor Cyan
echo         Write-Host ""
echo         Write-Host " 1. Lock a Folder"
echo         Write-Host " 2. Unlock a Folder"
echo         Write-Host " 3. Back to main menu"
echo         Write-Host ""
echo         $flChoice = Read-Host "Select option (1-3)"
echo.
echo         switch ^($flChoice^) {
echo             "1" {
echo                 Clear-Host
echo                 Write-Host "--- Lock a Folder ---" -ForegroundColor Yellow
echo                 Write-Host ""
echo                 $folder = Read-Host "Enter full folder path to lock"
echo                 if ^([string]::IsNullOrWhiteSpace^($folder^)^) {
echo                     Write-Host "`nNo path entered." -ForegroundColor Red
echo                     Read-Host "Press Enter to continue"
echo                 } elseif ^(-not ^(Test-Path $folder -PathType Container^)^) {
echo                     Write-Host "`nFolder not found: $folder" -ForegroundColor Red
echo                     Read-Host "Press Enter to continue"
echo                 } else {
echo                     icacls "$folder" /deny Everyone:F ^| Out-Null
echo                     if ^($LASTEXITCODE -ne 0^) {
echo                         Write-Host "`nFailed to lock. Check the path and try again." -ForegroundColor Red
echo                     } else {
echo                         $existing = Get-Content $trackFile -ErrorAction SilentlyContinue
echo                         if ^(-not ^($existing ^| Where-Object { $_.Trim^(^).ToLower^(^) -eq $folder.Trim^(^).ToLower^(^) }^)^) {
echo                             Add-Content -Path $trackFile -Value $folder
echo                         }
echo                         Write-Host "`nLocked: $folder" -ForegroundColor Green
echo                     }
echo                     Read-Host "Press Enter to continue"
echo                 }
echo             }
echo             "2" {
echo                 Clear-Host
echo                 Write-Host "--- Unlock a Folder ---" -ForegroundColor Yellow
echo                 Write-Host ""
echo                 $lines = Get-Content $trackFile -ErrorAction SilentlyContinue ^| Where-Object { $_ -ne "" }
echo                 if ^(-not $lines -or $lines.Count -eq 0^) {
echo                     Write-Host "No locked folders on record." -ForegroundColor Gray
echo                     Read-Host "Press Enter to continue"
echo                 } else {
echo                     Write-Host "Currently locked folders:"
echo                     Write-Host ""
echo                     for ^($i = 0; $i -lt $lines.Count; $i++^) {
echo                         Write-Host "$($i + 1): $($lines[$i])"
echo                     }
echo                     Write-Host ""
echo                     $sel = Read-Host "Enter the number of the folder to unlock (0 to cancel)"
echo                     if ^($sel -eq "0"^) {
echo                         Write-Host "Cancelled." -ForegroundColor Gray
echo                     } elseif ^($sel -match '^\d+$' -and [int]$sel -ge 1 -and [int]$sel -le $lines.Count^) {
echo                         $target = $lines[[int]$sel - 1]
echo                         icacls "$target" /remove:d Everyone ^| Out-Null
echo                         if ^($LASTEXITCODE -ne 0^) {
echo                             Write-Host "`nUnlock command failed for $target - it may already be unlocked" -ForegroundColor Yellow
echo                             Write-Host "or the folder may no longer exist. Removing it from the record." -ForegroundColor Yellow
echo                         } else {
echo                             Write-Host "`nUnlocked: $target" -ForegroundColor Green
echo                         }
echo                         $remaining = $lines ^| Where-Object { $_.Trim^(^).ToLower^(^) -ne $target.Trim^(^).ToLower^(^) }
echo                         if ^(-not $remaining^) { $remaining = @^(^) }
echo                         Set-Content -Path $trackFile -Value $remaining
echo                     } else {
echo                         Write-Host "`nInvalid selection." -ForegroundColor Red
echo                     }
echo                     Read-Host "Press Enter to continue"
echo                 }
echo             }
echo             "3" { return }
echo             default { Write-Host "Invalid selection." -ForegroundColor Red; Start-Sleep -Seconds 1 }
echo         }
echo     } while ^($flChoice -ne "3"^)
echo }
echo.
echo function Invoke-Tool16 {
echo     Write-Host "--- [16] WinUtil (Chris Titus Tech) ---" -ForegroundColor Yellow
echo     Write-Host ""
echo     Write-Host "*** ACTION REQUIRED - Tool 16: WinUtil ***" -ForegroundColor Red
echo     Write-Host "This launches WinUtil in a nested PowerShell session." -ForegroundColor Yellow
echo     Write-Host "It fetches and runs a script live from christitus.com on every launch -" -ForegroundColor Yellow
echo     Write-Host "this suite cannot audit or control what that separate session does." -ForegroundColor Yellow
echo     Write-Host "Close that nested window/session when you are done to return here." -ForegroundColor Yellow
echo     powershell -NoExit -Command "iwr -useb https://christitus.com/win ^| iex"
echo     Write-Host ""
echo     Write-Host "Returned from the WinUtil session." -ForegroundColor Green
echo     Read-Host "Press Enter to continue"
echo }
echo.
echo function Invoke-SelectedTool {
echo     param^([int]$Num^)
echo     switch ^($Num^) {
echo         1  { Invoke-Tool1 }
echo         2  { Invoke-Tool2 }
echo         3  { Invoke-Tool3 }
echo         4  { Invoke-Tool4 }
echo         5  { Invoke-Tool5 }
echo         6  { Invoke-Tool6 }
echo         7  { Invoke-Tool7 }
echo         8  { Invoke-Tool8 }
echo         9  { Invoke-Tool9 }
echo         10 { Invoke-Tool10 }
echo         11 { Invoke-Tool11 }
echo         12 { Invoke-Tool12 }
echo         13 { Invoke-Tool13 }
echo         14 { Invoke-Tool14 }
echo         15 { Invoke-Tool15 }
echo         16 { Invoke-Tool16 }
echo         default { Write-Host "Unrecognized option $Num - skipped." -ForegroundColor Red }
echo     }
echo }
echo.
echo do {
echo     Show-Menu
echo     $rawInput = Read-Host "Enter tool number(s) in run order (e.g. 2,9,1), or 17 to exit"
echo.
echo     if ^($rawInput -eq "17"^) { break }
echo.
echo     $sequence = $rawInput -split '[,\s]+' ^| Where-Object { $_ -ne "" }
echo     $invalid = $sequence ^| Where-Object { $_ -notmatch '^\d+$' -or [int]$_ -lt 1 -or [int]$_ -gt 16 }
echo.
echo     if ^($sequence.Count -eq 0 -or $invalid^) {
echo         Write-Host ""
echo         Write-Host "Invalid input. Enter one or more numbers from 1-16, separated by commas (e.g. 2,9,1), or 17 to exit." -ForegroundColor Red
echo         Read-Host "Press Enter to continue..."
echo         continue
echo     }
echo.
echo     Write-Host ""
echo     Write-Host "The following tools will run automatically, in this exact order:" -ForegroundColor Cyan
echo     foreach ^($n in $sequence^) {
echo         Write-Host "  [$n] $(Get-ToolName $n)"
echo     }
echo     Write-Host ""
echo     Write-Host "You will only be interrupted if a specific tool needs additional input from you." -ForegroundColor DarkGray
echo     Write-Host "Tools 14, 15 and 16 open their own session/menu and will hold the sequence until you exit them." -ForegroundColor DarkGray
echo     $confirm = Read-Host "Proceed with this sequence? (y/n)"
echo.
echo     if ^($confirm -ne 'y'^) { continue }
echo.
echo     foreach ^($n in $sequence^) {
echo         $num = [int]$n
echo         Clear-Host
echo         Write-Host "===========================================================" -ForegroundColor Cyan
echo         Write-Host " Running tool $num of sequence: $(Get-ToolName $num)" -ForegroundColor Cyan
echo         Write-Host "===========================================================" -ForegroundColor Cyan
echo         Write-Log -OptionNumber $num -OptionName ^(Get-ToolName $num^)
echo         Invoke-SelectedTool -Num $num
echo         Write-Host ""
echo     }
echo.
echo     Write-Host "===========================================================" -ForegroundColor Green
echo     Write-Host " Sequence complete. All selected tools finished executing." -ForegroundColor Green
echo     Write-Host "===========================================================" -ForegroundColor Green
echo     Read-Host "Press Enter to return to menu..."
echo.
echo } while ^($true^)
) > "%ps_file%"

:: --- EXECUTION PHASE ---
echo Launching engine interface...
powershell -NoProfile -ExecutionPolicy Bypass -File "%ps_file%"

:: --- CLEANUP PHASE ---
cls
echo ===========================================================
echo            SESSION WRAP-UP & PURGE OPERATIONS
echo ===========================================================
echo Exiting framework. Cleaning runtime files from storage disk...

if exist "%ps_file%" (
    del /f /q "%ps_file%"
    echo [OK] Successfully erased temporary file trace.
)

echo.
echo Complete. Only the master batch launcher remains.
timeout /t 3 >nul
exit
