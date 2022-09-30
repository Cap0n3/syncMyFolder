# SyncMyFolder

PowerShell script to sync two directories in mirror. It also accept an exclusion list to exclude specific folders (and it's content) or files from source or target directory.

## Usage

Set execution policy :

```ps1
Set-ExecutionPolicy RemoteSigned
```

To sync in mirror `Folder1` with `Folder2` simply do :

```console
.\syncMyFolder.ps1 C:\Users\Kim\Folder1 C:\Users\Kim\Folder2
```

To sync in mirror Folder1 (source) but exclude from sync some files/folder from source or target :

```console
.\syncMyFolder.ps1 C:\Users\Kim\Folder1 C:\Users\Kim\Folder2 -f myExclusions.txt
```

### Exclusion list

`myExclusions.txt` file (can be named differently) will contain files or folders that should be excluded from sync. It works for source or target folder.

Each entry should have this syntax :

```txt
[<src/tgt>] <path> like this :
```

It would look like this :

```txt
[src] C:\Users\Kim\Folder1\SubFolder1\doNotSyncDir
[src] C:\Users\Kim\Folder1\SubFolder1\doNotSync1.png
[src] C:\Users\Kim\Folder1\doNotSync2.jpg
[tgt] C:\Users\Kim\Folder2\SubFolder1\doNotRemoveDir
[tgt] C:\Users\Kim\Folder2\SubFolder1\DoNotRemove1.gp7
[tgt] C:\Users\Kim\Folder2\DoNotRemove2.doc
```

## Testing

For testing simply add flag `-Test <testFolder>` to command, for example to test folder 2 in `Test/` :

```console
.\syncMyFolder.ps1 C:\Users\Kim\Folder1 C:\Users\Kim\Folder2 -Test testFolder2
```

If you wish, you can create new test folders with custom structure for testing, just name new folders 'testFolder7', 'testFolder8', etc ... and create a `.zip` backup placed in folder `0_backup_zip/` (used to restore original structure of test folder).

Run Script with test flag and either :

- Say 'No' when prompted to check if testFolders content fits expected results. Then, run script again and say 'Yes' when prompted to re-initialize testFolders to original structure.
- Don't do anything, check if testFolders content fits expected results (Go to logs to see if folders are in sync) and if everything is ok, enter 'Y'.
