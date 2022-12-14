<#
.SYNOPSIS
    This PowerShell script syncs two folders (source, target). Created by Cap0n3.

.DESCRIPTION
    Script to sync two directories in mirror. It also accept an exclusion list to exclude specific folders (and it's content) 
    or files from source or target directory.

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
    To sync in mirror Folder1 (source) with Folder2 (target) do :
    .\syncMyFolder.ps1 C:\Users\Kim\Folder1 C:\Users\Kim\Folder2

.EXAMPLE
    To sync in mirror Folder1 (source) but exclude from sync some files/folder from source or target :
    .\syncMyFolder.ps1 C:\Users\Kim\Folder1 C:\Users\Kim\Folder2 -f myExclusion.txt

    The file "myExclusion.txt" (can be named differently) should have this formating [<src/tgt>] <path> like this :

    [src] C:\Users\Kim\Folder1\SubFolder1\doNotSyncDir
    [src] C:\Users\Kim\Folder1\SubFolder1\doNotSync1.png
    [src] C:\Users\Kim\Folder1\doNotSync2.jpg
    [tgt] C:\Users\Kim\Folder2\SubFolder1\doNotRemoveDir
    [tgt] C:\Users\Kim\Folder2\SubFolder1\DoNotRemove1.gp7
    [tgt] C:\Users\Kim\Folder2\DoNotRemove2.doc
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory, Position=0)]
    [alias("Source")]
    [String]$source_folder,
    [Parameter(Mandatory, Position=1)]
    [alias("Target")]
    [String]$target_folder,
    [Parameter(Mandatory=$false, Position=2)]
    [String]$Test,
    [Parameter(Mandatory=$false)]
    [alias("f")]
    [String]$exclusions
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
    $global:source_folder = "$currentdir\tests\$Test\Folder1"
    $global:target_folder = "$currentdir\tests\$Test\Folder2"
}

# === LOG ROTATION SET-UP === #
$MAX_LOGS = 30 # Max log files permitted in log dir
$MAX_ARCHIVE = 100 # Max zip archives permitted in archive dir

# Create logs folder (if it doesn't exist)
if (!(Test-Path "$currentdir\logs" -PathType Container)) {
    New-Item -ItemType Directory -Force -Path "$currentdir\logs" | Out-null
}

# Count .log files in logs folder
$log_count = (Get-ChildItem -Path "$currentdir\logs" -Filter *.log | Measure-Object).Count

# Create a .zip file if there's too many log files in log folder
if($log_count -gt ($MAX_LOGS)){
    # Create directory for archives (if it doesn't exist)
    if (!(Test-Path "$currentdir\logs\log-archives" -PathType Container)) {
        New-Item -ItemType Directory -Force -Path "$currentdir\logs\log-archives" | Out-null
    }
    # Get all log files
    $log_files = Get-ChildItem -Path "$currentdir\logs" -Filter *.log
    # Get time stamps of first and last log files (to create archive name)
    $startEndFile = $log_files[0].toString() + $log_files[-1].toString()
    $log_files[0].toString() -match '\{\d+_\d+\}' | Out-null
    $startFileStamp = $Matches[0]
    $log_files[-1].toString() -match '\{\d+_\d+\}' | Out-null
    $endFileStamp = $Matches[0]
    # Compress files
    $log_files | Compress-Archive -DestinationPath "$currentdir\logs\log-archives\$($startFileStamp)-$($endFileStamp).zip"
    # Remove log files
    $log_files | ForEach-Object {
        Remove-Item "$currentdir\logs\$($PSItem)" -Force
    }
    # === Clean log-archive (to avoid cluttering) === #
    # Count .zip files in dir 
    $zip_count = (Get-ChildItem -Path "$currentdir\logs\log-archives" -Filter *.zip | Measure-Object).Count
    # Remove first n zip files
    if ($zip_count -gt ($MAX_ARCHIVE)){
        $zip_files = Get-ChildItem -Path "$currentdir\logs\log-archives" -Filter *.zip
        for ($i = 0; $i -lt $($MAX_ARCHIVE / 2); $i++){
            Remove-Item "$currentdir\logs\log-archives\$($zip_files[$i])"
        }
    }
}

# === ERROR SET-UP === #
# Treat all errors as terminating errors
$ErrorActionPreference = "STOP"

# === TESTING SET-UP === #
# Test folders (where backup of folder stucture are)
$global:testfolderzip = "$currentdir\tests\0_backup_zip"
# The test folder path
$global:testfolder = "$currentdir\tests"

# ===================================== #
# ============ UTILS FUNCS ============ #
# ===================================== #

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
            Remove-Item $_.FullName -Recurse -Force
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

function Create-ExclusionArrays {
    <#
    .SYNOPSIS
        To create exclusion arrays for source & target folder (files or folders to exclude).

    .DESCRIPTION
        This function returns two arrays with files/folders that shouldn't be synced from source or removed from target folder.

    .PARAMETER  $exclusionList_file
        User defined file containing exclusions for source and target folder.
    
    .OUTPUTS
        Returns two arrays of exclusions, one with file names for source & another for target.
    #>
    param(
        [Parameter(Mandatory)]
        [String]$exclusionList_file
    )
    #Prepare arrays to store exceptions
    $src_exclusions = @()
    $tgt_exclusions = @()
    # Get content of exclusion file
    $file_data = Get-Content $exclusionList_file
    # Read file content & populate arrays
    $file_data | ForEach-Object {
        # Exception for source or target folder ?
        $which_exclusion =  $PSItem.SubString(0, 5)
        # Start at 6 to avoid selecting space char
        $excludedFile_path = $PSItem.SubString(6)
        # Test if path exists
        if(!(Test-Path $excludedFile_path)){
            Write-Log "{ERROR}(Create-ExclusionArrays) Path in file '$($exclusionList_file)' was not found ! Given path : '$($excludedFile_path)'"
            throw "(Create-ExclusionArrays) Path in file '$($exclusionList_file)' was not found ! Check path : '$($excludedFile_path)'"
        }
        if($which_exclusion -eq "[src]"){
            # Check if item path point to a file or a folder
            if(Test-Path -Path $excludedFile_path -PathType Container) {
                Write-Log "{DEBUG}(Create-ExclusionArrays) adding in source exclusion folder '$($excludedFile_path)'"
                # If it's a folder, first store folder in exclusion array
                $src_exclusions+=$excludedFile_path
                # Then, get all its children
                $subItems = Get-ChildItem -Path $excludedFile_path -Recurse
                # And store all content in source exclusion array
                $subItems | ForEach-Object {
                    $src_exclusions+=$_.FullName
                }
            }
            elseif (Test-Path -Path $excludedFile_path -PathType leaf) {
                if($excludedFile_path -match '\*\.\w+'){
                    # If it's a wildcard exclusion for a specific type of file (like *.txt)
                    $excludedExtensionFiles = Get-ChildItem "$($source_folder)\$($matches[0])" -Recurse
                    $excludedExtensionFiles | ForEach-Object {
                        $src_exclusions+=$PSItem.toString()
                    }
                    Write-Log "{INFO}(Create-ExclusionArrays) Excluded files with extension '$($matches[0])' : '$($excludedExtensionFiles)'"
                } else {
                    Write-Log "{DEBUG}(Create-ExclusionArrays) Adding in source exclusion file '$($excludedFile_path)'"
                    # It's a file, simply add it to exclusion array
                    $src_exclusions+=$excludedFile_path
                }    
            }    
        }
        elseif ($which_exclusion -eq "[tgt]") {
            if(Test-Path -Path $excludedFile_path -PathType Container) {
                Write-Log "{DEBUG}(Create-ExclusionArrays) adding in source exclusion folder '$($excludedFile_path)'"
                # If it's a folder, first store folder in exclusion array
                $tgt_exclusions+=$excludedFile_path
                # Then, get all its children
                $subItems = Get-ChildItem -Path $excludedFile_path -Recurse
                # And store all content in source exclusion array
                $subItems | ForEach-Object {
                    $tgt_exclusions+=$_.FullName
                }
            }
            elseif (Test-Path -Path $excludedFile_path -PathType leaf) {
                Write-Log "{DEBUG}(Create-ExclusionArrays) adding in source exclusion file '$($excludedFile_path)'"
                # It's a file, simply add it to exclusion array
                $tgt_exclusions+=$excludedFile_path
            }
        }
    }
    Write-Log "{INFO}(Create-ExclusionArrays) Exclusions for source folder : $($src_exclusions)"
    Write-Log "{INFO}(Create-ExclusionArrays) Exclusions for target folder : $($tgt_exclusions)"
    return $src_exclusions, $tgt_exclusions
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
        [String]$tgt_folder,
        [Parameter(Mandatory=$false,Position=2)]
        [Array]$src_exclusions_array,
        [Parameter(Mandatory=$false,Position=3)]
        [Array]$tgt_exclusions_array
    )

    function Get-Difference {
        <#
        Utility function to compare objects and exclude files if necessary (mainly here to stay DRY)
        #>
        param(
            [Parameter(Mandatory=$true)]
            [bool]$exclude
        )
        if($exclude -eq $false) {
            # Get elements
            $objects = @{
                ReferenceObject = (Get-ChildItem -Path $src_folder -Recurse)
                DifferenceObject = (Get-ChildItem -Path $tgt_folder -Recurse)
            }
            Write-Log "{DEBUG}(Compare-Folders Get-Difference) Reference object : $($objects.ReferenceObject)"
            Write-Log "{DEBUG}(Compare-Folders Get-Difference) Difference object : $($objects.ReferenceObject)"
        }
        elseif($exclude -eq $true) {
            # Get elements but exclude files from exclusion arrays
            $objects = @{
                ReferenceObject = (Get-ChildItem -Path $src_folder -Recurse | Where-Object FullName -NotIn $src_exclusions_array)
                DifferenceObject = (Get-ChildItem -Path $tgt_folder -Recurse | Where-Object FullName -NotIn $tgt_exclusions_array)
            }
            Write-Log "{DEBUG}(Compare-Folders Get-Difference) Reference object : $($objects.ReferenceObject)"
            Write-Log "{DEBUG}(Compare-Folders Get-Difference) Difference object : $($objects.ReferenceObject)"
        }
        # Compare folders
        return Compare-Object @objects
    }

    # First, check if given paths exists
    if(!(Test-Path $src_folder)) {
        Write-Log "{ERROR}(Compare-Folders) Source folder was not found ! Given path : '$($src_folder)'"
        throw "(Compare-Folders) Source folder was not found ! Check path : '$($src_folder)'"
        Exit
    }
    if(!(Test-Path $tgt_folder)) {
        Write-Log "{ERROR}(Compare-Folders) Target folder was not found ! Given path : '$($tgt_folder)'"
        throw "(Compare-Folders) Target folder was not found ! Check path : '$($tgt_folder)'"
        Exit
    }
    # Then, if given paths are folders
    if(!((Get-Item $src_folder) -is [System.IO.DirectoryInfo])) {
        Write-Log "{ERROR}(Compare-Folders) Given source folder is not a folder ! Given path : '$($src_folder)'"
        throw "(Compare-Folders) Given source folder is not a folder ! Check path : '$($src_folder)'"
        Exit
    }
    if(!((Get-Item $tgt_folder) -is [System.IO.DirectoryInfo])) {
        Write-Log "{ERROR}(Compare-Folders) Given target folder is not a folder ! Given path : '$($tgt_folder)'"
        throw "(Compare-Folders) Given target folder is not a folder ! Check path : '$($tgt_folder)'"
        Exit
    }
    # Check if there are exclusions
    if(!($src_exclusions_array -eq $null) -and !($tgt_exclusions_array -eq $null)) {
        Write-log "{DEBUG} There are exclusions arrays for source and target."
        $folder_diff = Get-Difference $true
    } else {
        Write-log "{DEBUG} There are no exclusions arrays for source and target."
        $folder_diff = Get-Difference $false
    }

    # Exit script if folders are already in sync
    if ($folder_diff -eq $null) {
        Write-Host "Folders are in sync !" -ForegroundColor Green
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
    Write-Log "{DEBUG}(Split-FullPath) Path to split : '$path_to_split'" 
    Write-Log "{DEBUG}(Split-FullPath) Absolute path to folder : '$folder_abs_path'"
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

function Copy-Content {
    <#
    .SYNOPSIS
        Copy file or folder to destination.
    
    .DESCRIPTION
        This utility function copy file to destination and take into account exclusions, it's been created to keep code DRY.

    .PARAMETER fullPath
        Full path to file/folder
    
    .PARAMETER _source_exclusions
        Source exclusions.
    #>
    param(
        [Parameter(Mandatory,Position=0)]
        [String]$fullPath,
        [Parameter(Mandatory,Position=1)]
        [AllowNull()]
        [Array]$_source_exclusions
    )
    # Test if path exists
    if(!(Test-Path $fullPath)) {
        Write-Log "{ERROR}(Copy-Content) Path was not found ! Given path : '$($fullPath)'"
        throw "(Copy-Content) Path was not found ! Check path : '$($fullPath)'"
        Exit
    }
    # Get second only second part of path (file/folder relative path)
    $path_split = Split-FullPath $fullPath $source_folder
    <# 
    Update target folder absolute path with relative path to file/folder to respect tree structure.
    Allow to recreate path, for instance "C:\Users\Kim\Source\Subfolder1\myVids\myVid.mov" would be 
    transformed to "C:\Users\Kim\Target\Subfolder1\myVids\myVid.mov"
    #>
    $updated_path = $target_folder + $path_split[1]
    if (!($fullPath -in $_source_exclusions)){
        
        if (!(Test-Path -Path $fullPath -PathType leaf)){
            Write-Log "{INFO}(Copy-Content) CREATING FOLDER '$($updated_path)'"
            # If it's a folder, simply create it without its content (to avoid copying excluded files/folder inside)
            New-Item -Path $updated_path -ItemType Directory
        } else {
            # Else, if it's a file just copy to right destination
            Write-Log "{INFO}(Copy-Content) COPYING '$($fullPath)' IN FOLDER '$($updated_path)'"
            Copy-Item -Path $fullPath -Destination $updated_path
        }               
    } else {
        # If it is then log it
        Write-Log "{INFO}(Copy-Content) Exclude following file/folder from sync : '$($fullPath)'"
    }
}

# ============================== #
# ============ SYNC ============ #
# ============================== #

# Create exclusion arrays for source and target if flag is indicated in command
if(!($exclusions -eq "")){
    $source_exclusions = @()
    $target_exclusions = @()
    $source_exclusions, $target_exclusions = Create-ExclusionArrays $exclusions
}

# === Target folder is empty, this is first sync === #
if((Get-ChildItem -Path $target_folder | Measure-Object).Count -eq 0) {
    # If it is, then copy all source content in target folder
    Write-Log "Target directory is empty, copying content of '$($source_folder)' in '$($target_folder)'"
    Get-ChildItem -Path $source_folder -Recurse | ForEach-Object {
        # === Start sync === #
        Write-Log "====== START SYNC ======"
        Copy-Content $PSItem.FullName $source_exclusions
    }
} else {
    # === This is not the first sync, compare source/target folders to see differences === #   
    # Check if there are exclusions arrays or not
    if(!($exclusions -eq "")){
        $comparison = Compare-Folders $source_folder $target_folder $source_exclusions $target_exclusions
    } else {
        $comparison = Compare-Folders $source_folder $target_folder
    }

    # === Start sync === #
    Write-Log "====== START SYNC ======"
    $comparison | foreach {
        # Get current item full path
        $item_path = $_.InputObject.FullName

        if ($_.SideIndicator -eq "<=") {
            # === Then file is only in SOURCE folder === #
            try {
                # COPY FILE/FOLDER TO TARGET FOLDER
                Copy-Content $item_path $source_exclusions
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
                # Check if item is in exclusion list (don't remove if it is)
                if (!($item_path -in $target_exclusions)){
                    Write-Log "{INFO} REMOVING '$($item_path)' IN FOLDER '$($target_folder)'"
                    Remove-Item -Path $item_path -Recurse -Force
                } 
            } 
            catch [System.Management.Automation.ItemNotFoundException] {
                Write-Log "{WARNING} File not found (check if file parent folder has already been erased) : '$($item_path)'"
            }
            catch {
                Write-Log "{ERROR} An error occured !"
                Write-Log "{ERROR} Error type : $_"
            }
        }
    }
}

# ====== LAST CHECKS ====== #
# To see if source & target folders are in sync
Compare-Folders $source_folder $target_folder $source_exclusions $target_exclusions

if (!($Test -eq "")) {
    Prompt-Clean # FOR TESTING
}
