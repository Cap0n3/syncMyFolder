<#
.SYNOPSIS
    This PowerShell script syncs two folders. Created by Cap0n3.

.DESCRIPTION
    Script to sync two folders in mirror.

.NOTES
    For testing simply add flag `-Test <testFolder>` to command, for example to test folder 2 :
    
    .\syncMyFolder.ps1 Fol1 Fol2 -Test testFolder2

    If you wish, you can create new test folders with custom structure for testing, just name new folders 'testFolder7', 
    'testFolder8', etc ... and create a zip backup placed in folder '0_backup_zip' (used to restore original structure of 
    test folder). 
    
    Run Script with test flag and either :
    - Say 'No' when prompted to check if testFolders content fits expected results. Then, run script again and say 'Yes' 
      when prompted to re-initialize testFolders to original structure.
    - Don't do anything, check if testFolders content fits expected results (Go to logs to see if folders are in sync) and
      if everything is ok, enter 'Y'.

.EXAMPLE
    To sync in mirror Folder1 do :
    .\syncMyFolder.ps1 C:\Users\Kim\Folder1 C:\Users\Kim\Folder2
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory, Position=0)]
    [String]$folderpath1,
    [Parameter(Mandatory, Position=1)]
    [String]$folderpath2,
    [Parameter(Mandatory=$false, Position=2)]
    [String]$Test
)

# ================================ #
# ============ SET-UP ============ #
# ================================ #

# Get script current directory
$global:currentdir = (Get-Location).toString()

# Script execution time stamp
$global:script_time = (Get-Date).toString("yyMMdd_HHmmss")

# Change Source & Target Folder for testing
if (!($Test -eq "")) {
    Write-Host "`n[TEST] Testing enabled for folder '$Test'" -ForegroundColor Cyan
    $global:folderpath1 = "$currentdir\tests\$Test\Folder1"
    $global:folderpath2 = "$currentdir\tests\$Test\Folder2"
}

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
        Write-Host "Testing folders not touched, go check results in test folders." -ForegroundColor cyan
    }
}

function Create-ExceptArrays {
    <#
    .SYNOPSIS
        To create exception arrays for source & target folder.

    .DESCRIPTION
        This function returns two arrays with files that shouldn't be synced from source or removed from target folder.

    .PARAMETER  $except_file
        User defined file containing exceptions for source and target folder.
    
    .OUTPUTS
        Returns two arrays of exceptions, one with file names for source & another for target.
    #>
    param(
        [Parameter(Mandatory)]
        [String]$except_file
    )
    #Prepare arrays to store exceptions
    $src_exceptions = @()
    $tgt_exceptions = @()
    # Get content of file
    $file_data = Get-Content $except_file
    # Read file content & populate arrays
    $file_data | ForEach-Object {
        # Exception for source or target folder ?
        $which_exception =  $PSItem.SubString(0, 5)
        # Start at 6 to avoid selecting space char
        $file_path = $PSItem.SubString(6)
        # Test if path exists
        if(!(Test-Path $file_path)){
            Write-Log "{ERROR}(Create-ExceptArrays) Path in file '$($except_file)' was not found ! Given path : '$($file_path)'"
            throw "Path in file '$($except_file)' was not found ! Check path : '$($file_path)'"
        }
        if($which_exception -eq "[src]"){
            $src_exceptions+=$file_path
        }
        elseif ($which_exception -eq "[tgt]") {
            $tgt_exceptions+=$file_path
        }
    }
    Write-Log "{INFO}(Create-ExceptArrays) Exceptions for source folder : $($src_exceptions)"
    Write-Log "{INFO}(Create-ExceptArrays) Exceptions for target folder : $($tgt_exceptions)"
    return $src_exceptions, $tgt_exceptions
}

function Compare-Folders {
    <#
    .SYNOPSIS
        Compare content of source & target folders.
    
    .DESCRIPTION
        Check if given folder paths exists and are really folders (and not files), compare their contents and return difference 
        or log and exit if they're are already in sync. 
    
    .PARAMETER src_folder
        Source folder.
    
    .PARAMETER src_folder
        Target folder.
    
    .OUTPUTS
        Returns Compare-Object
    #>
    param(
        [Parameter(Mandatory,Position=0)]
        [String]$src_folder,
        [Parameter(Mandatory,Position=1)]
        [String]$tgt_folder
    )
    # First check if given paths exists
    if(!(Test-Path $src_folder)) {
        Write-Log "{ERROR}(Compare-Folders) Source folder was not found ! Given path : '$($src_folder)'"
        throw "Source folder was not found ! Check path : '$($src_folder)'"
        Exit
    }
    if(!(Test-Path $tgt_folder)) {
        Write-Log "{ERROR}(Compare-Folders) Target folder was not found ! Given path : '$($tgt_folder)'"
        throw "Target folder was not found ! Check path : '$($tgt_folder)'"
        Exit
    }
    # Then if given path are folders
    if(!((Get-Item $src_folder) -is [System.IO.DirectoryInfo])) {
        Write-Log "{ERROR}(Compare-Folders) Given source folder is not a folder ! Given path : '$($src_folder)'"
        throw "Given source folder is not a folder ! Check path : '$($src_folder)'"
        Exit
    }
    if(!((Get-Item $tgt_folder) -is [System.IO.DirectoryInfo])) {
        Write-Log "{ERROR}(Compare-Folders) Given target folder is not a folder ! Given path : '$($tgt_folder)'"
        throw "Given target folder is not a folder ! Check path : '$($tgt_folder)'"
        Exit
    }

    # Get elements
    $objects = @{
        ReferenceObject = (Get-ChildItem -Path $src_folder -Recurse)
        DifferenceObject = (Get-ChildItem -Path $tgt_folder -Recurse)
      }

    # Compare folders
    $folder_diff = Compare-Object @objects

    # Exit script if folders are already in sync
    if ($folder_diff -eq $null) {
        Write-Log "{INFO}(Compare-Folders) Folders are in sync !"
        Write-Log "{INFO}(Compare-Folders) Exiting script !"
        if (!($Test -eq "")) {
            Write-Host "[OK] Test was a success ! Folders are in sync !" -ForegroundColor Green
            Prompt-Clean # FOR TESTING
        }
        Exit
    } else {
        # If they're not in sync log & return difference
        Write-Log "====== COMPARE OBJECT ======"
        $folder_diff  | foreach {
            $filepath = $_.InputObject.FullName
            $indicator = $_.SideIndicator
            Write-Log "{INFO}(Compare-Folders) [$($indicator)] '$($filepath)'"
        }
        return $folder_diff 
    }   
}

function Split-FullPath {
    <#
    .SYNOPSIS
        Split given path in two parts.
    
    .DESCRIPTION
        This utility function split path in two parts depending on source or target absolute path, it'll split at source folder 
        absolute path and at file relative path. 
        For instance, take this path to a file in source folder "C:\Users\Kim\\SourceFolder\SubFolder1\ToRemove.jpg"

        - Function would split absolute path to source : "C:\Users\Kim\\SourceFolder" and return it.
        - Plus it would return relative path to file (or folder) : "SubFolder1\ToRemove.jpg"
        
        Note : To correctly split path, function needs absolute path to source

    .PARAMETER path_to_split
        Path to split
    
    .PARAMETER folder_abs_path
        Source or Target absolute path
    
    .OUTPUTS
        Returns arrays with absolute path to source AND relative path to file (or folder)
    #>
    param(
        [Parameter(Mandatory,Position=0)]
        [String]$path_to_split,
        [Parameter(Mandatory,Position=1)]
        [String]$folder_abs_path
    )
    Write-Log "{DEBUG}(Split-FullPath) Path to split : $path_to_split" 
    Write-Log "{DEBUG}(Split-FullPath) Absolute path to folder : $folder_abs_path"
    $result = @()
    # Split first part of path (source or target) and second (file relative path)
    # Out-null to avoid placing boolean in result array
    ($path_to_split -match [regex]::Escape($folder_abs_path)) | out-null
    $source_abs_path = $matches[0]
    $result += $source_abs_path
    # Remove path to source/target folder
    $file_rel_path = $path_to_split -replace [regex]::Escape($source_abs_path), ""
    $result += $file_rel_path
    return $result
}

# ============================== #
# ============ SYNC ============ #
# ============================== #

# Compare source & target folders
$comparison = Compare-Folders $folderpath1 $folderpath2

# === Start sync === #
Write-Log "====== START SYNC ======"
$comparison | foreach {
    # Get current item full path
    $item_path = $_.InputObject.FullName

    if ($_.SideIndicator -eq "<=") {
        # === Then file is only in SOURCE folder === #
        try {
            # COPY FILE/FOLDER TO TARGET FOLDER
            # Get second only second part of path (file/folder relative path)
            $path_split = Split-FullPath $item_path $folderpath1
            <# 
            Update target folder absolute path with relative path to file/folder to respect tree structure.
            Allow to recreate path, for instance "C:\Users\Kim\Source\Subfolder1\myVids\myVid.mov" would be 
            transformed to "C:\Users\Kim\Target\Subfolder1\myVids\myVid.mov"
            #>
            $updated_path = $folderpath2 + $path_split[1]
            Write-Log "{INFO} COPYING '$($item_path)' IN FOLDER '$($updated_path)'"
            Copy-Item -Path $item_path -Destination $updated_path -Recurse
        }
        catch {
            Write-Log "{ERROR} An error occured !"
            Write-Log "{ERROR} Error type : $_"
        }
    }
    elseif ($_.SideIndicator -eq "=>") {
        # === Then file is only in TARGET folder === #
        try {
            # Remove file from target folder
            Write-Log "{INFO} REMOVING '$($item_path)' IN FOLDER '$($folderpath2)'"
            Remove-Item -Path $item_path -Recurse   
        } 
        catch [System.Management.Automation.ItemNotFoundException] {
            Write-Log "{WARNING} File not found : '$($item_path)'"
        }
        catch {
            Write-Log "{ERROR} An error occured !"
            Write-Log "{ERROR} Error type : $_"
        }
    }

# ====== LAST CHECKS ====== #
Compare-Folders $folderpath1 $folderpath2

if (!($Test -eq "")) {
    Prompt-Clean # FOR TESTING
}
