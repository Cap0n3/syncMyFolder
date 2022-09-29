# SyncMyFolder

PowerShell script to synchronize two folders in mirror.

## Usage

To sync in mirror `Folder1` with `Folder2` simply do :

```console
.\syncMyFolder.ps1 C:\Users\Kim\Folder1 C:\Users\Kim\Folder2
```

## Testing

For testing simply add flag `-Test <testFolder>` to command, for example to test folder 2 in `Test/` :

```console
.\syncMyFolder.ps1 C:\Users\Kim\Folder1 C:\Users\Kim\Folder2 -Test testFolder2
```

If you wish, you can create new test folders with custom structure for testing, just name new folders 'testFolder7', 
'testFolder8', etc ... and create a `.zip` backup placed in folder `0_backup_zip/` (used to restore original structure of test folder).

Run Script with test flag and either :

- Say 'No' when prompted to check if testFolders content fits expected results. Then, run script again and say 'Yes' when prompted to re-initialize testFolders to original structure.
- Don't do anything, check if testFolders content fits expected results (Go to logs to see if folders are in sync) and if everything is ok, enter 'Y'.
