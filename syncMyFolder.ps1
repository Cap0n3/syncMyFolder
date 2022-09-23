<#
    .SYNOPSIS
    This PowerShell script syncs two folders. Created by Cap0n3.

    .DESCRIPTION
    Script to sync two folders in mirror.

    .NOTES
    For testing please uncomment line 92 and 143 (Prompt-Clean function). If you wish, you can create new test folders with custom 
    structure for testing, just name new folders 'testFolder3', 'testFolder4', etc ... and create a zip backup placed in folder '0_backup_zip'. 
    Run Script with lines uncommented and say 'No' when prompted to check if testFolders content fits expected results, then run script 
    again and say 'Yes' when prompted to re-initialize testFolders to original structure.
#>

# ================================ #
# ============ SET-UP ============ #
# ================================ #

# Source & Target Folder
$global:folderpath1 = "C:\Users\EMR\Documents\0_DEV_PROJECTS\0_PS_SCRIPTS\SyncMyFolder\tests\testFolder2\Folder1"
$global:folderpath2 = "C:\Users\EMR\Documents\0_DEV_PROJECTS\0_PS_SCRIPTS\SyncMyFolder\tests\testFolder2\Folder2"

# Get script current directory
$global:currentdir = (Get-Location).toString()

# Script execution time stamp
$global:script_time = (Get-Date).toString("yyMMdd_HHmmss")

# Create logs folder (if it doesn't exist)
if (!(Test-Path "$currentdir\logs" -PathType Container)) {
    New-Item -ItemType Directory -Force -Path "$currentdir\logs"
}

# === ERROR SET-UP === #
# Treat all errors as terminating errors
$ErrorActionPreference = "STOP"

# === TESTING SET-UP === #
# Test folders (where backup of folder stucture are)
$global:testfolderzip = "$currentdir\tests\0_backup_zip"
# The test folder path
$global:testfolder = "$currentdir\tests"

# =============================== #
# ============ UTILS ============ #
# =============================== #


$logfile = "$currentdir\logs\{$($script_time)}_syncMyFolder.log"
function Write-Log {
    <# Custom logging utility #>
    param([String]$message)
    $time_stamp = (Get-Date).toString("dd/MM/yyyy HH:mm:ss")
    $log_message = "$time_stamp - $message"
    Add-content $logfile -value $log_message
}

# For testing
function Clean-Tests {
    <#
    Function unzip test folders and replace old ones in tests/. Used to restart testing.
    #>
    # Clean test folders in tests/
    Get-ChildItem -Path $testfolder |
    Foreach-Object {
        # If folder are named testFolder[1, 2, 3, ...] then remove
        if($_.Name -match 'testFolder\d') {
            Remove-Item $_.FullName -Recurse
            Write-Log "{TEST} Removing file '$($_.Name)'" 
        }
    }
    # Go through zip folders & unzip to destination
    Get-ChildItem -Path $testfolderzip |
    Foreach-Object {
        # Expand zip in test dir
        Expand-Archive -Path $_.FullName -DestinationPath $testfolder -Force -Verbose
        Write-Log "{TEST} Expanding file '$($_.Name)' at path '$($testfolder)'"  
    }
}

function Prompt-Clean {
    $title    = 'Confirm'
    $question = 'Do you want to clean test folders & restart testing ? Say no to see result in testFolders.'
    $choices  = '&Yes', '&No'
    
    # Prompt user & Delete
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    
    if ($decision -eq 0) {
        # Delete file (use -Force on Remove-Item)
        Clean-Tests
        Write-Host "`Testing folders cleaned, all ready for new tests !" -ForegroundColor Green
    } 
    elseif ($decision -eq 1) {
        Write-Host "Testing folders not touched, go check results in testfodlers." -ForegroundColor cyan
    }
}

# ============================== #
# ============ SYNC ============ #
# ============================== #

# Get folders content
$folder1_files = Get-ChildItem -Path $folderpath1 -Recurse
$folder2_files = Get-ChildItem -Path $folderpath2 -Recurse
# Compare two folders
$files_diff = Compare-Object -ReferenceObject $folder1_files -DifferenceObject $folder2_files

# === Log informations about sync === #
Write-Log "====== COMPARE OBJECT ======"
Write-Log "{INFO} Comparing folders '$($folderpath1)' and '$($folderpath2)'"
# Exit script if folders are already in sync
if ($files_diff -eq $null) {
    Write-Log "{INFO} Folders are in sync !"
    Write-Log "{INFO} Exiting script !"
    Prompt-Clean # For testing
    Exit
}

# Else log Compare-Object results
$files_diff | foreach {
    $filepath = $_.InputObject.FullName
    $indicator = $_.SideIndicator
    Write-Log "[$($indicator)] '$($filepath)'"
}

# === Start sync === #
Write-Log "====== START SYNC ======"
$files_diff | foreach {
    # Get file full path
    $filepath = $_.InputObject.FullName

    if ($_.SideIndicator -eq "<=") {
        # === Then file is only in SOURCE folder === #
        Write-Log "{INFO}{COPYING} '$($filepath)' {IN FOLDER} '$($filepath)'"
        # Copy file to target folder
        try {
            Copy-Item -Path $filepath -Destination $folderpath2 -Recurse
        }
        catch {
            Write-Log "{ERROR} An error occured !"
            Write-Log "{ERROR} Error type : $_"
        }
    }
    elseif ($_.SideIndicator -eq "=>") {
        # === Then file is only in TARGET folder === #
        Write-Log "{INFO}{REMOVING} '$($filepath)' {IN FOLDER} '$($folderpath2)'"
        # Remove file from target folder
        try {
            Remove-Item -Path $filepath -Recurse
        } 
        catch [System.Management.Automation.ItemNotFoundException] {
            Write-Log "{WARNING} File not found : '$($filepath)'"
        }
        catch {
            Write-Log "{ERROR} An error occured !"
            Write-Log "{ERROR} Error type : $_"
        }
    }
}

# ========================================== #
# ============ FOR TESTING ONLY ============ #
# ========================================== #

# UNCOMMENT FOR TESTING
Prompt-Clean
