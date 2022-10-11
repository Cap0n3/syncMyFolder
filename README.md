# SyncMyFolder

PowerShell script to sync two directories in mirror. It optionally accepts an exclusion list to exclude specific folders (and it's content) or files from source or target directory.

> **Note :** Script has an integrated log facility to check if everything went as expected or not. To read log files go to `log/` directory (will be created after first run) or in log-archives/ for older logs (compressed).

## Usage

Set execution policy :

```ps1
Set-ExecutionPolicy RemoteSigned
```

For example, to mirror `Folder1` (source) in `Folder2` (target) simply do :

```console
.\syncMyFolder.ps1 C:\Users\Kim\Folder1 C:\Users\Kim\Folder2
```

### Exclusion list

Now, to sync in mirror Folder1 (source) but exclude from sync some files/folder from source or target simply include exclusion file after the option `-f` :

```console
.\syncMyFolder.ps1 C:\Users\Kim\Folder1 C:\Users\Kim\Folder2 -f myExclusions.txt
```

`myExclusions.txt` file (name and extension is up to you) will contain files or folders that should be excluded from sync. It works for source or target folder.

> **Note :** for target folder it'll simply not erase excluded file even if it's only present in target folder and not source.

Each entry should have this syntax :

```txt
[<src/tgt>] <path> like this :
```

So it would look something like this :

```txt
[src] C:\Users\Kim\Folder1\SubFolder1\doNotSyncDir
[src] C:\Users\Kim\Folder1\SubFolder1\doNotSync1.png
[src] C:\Users\Kim\Folder1\doNotSync2.jpg
[tgt] C:\Users\Kim\Folder2\SubFolder1\doNotRemoveDir
[tgt] C:\Users\Kim\Folder2\SubFolder1\DoNotRemove1.gp7
[tgt] C:\Users\Kim\Folder2\DoNotRemove2.doc
```

It's also possible to exclude a specific type of file from sync (works only for source folder) :

```txt
[src] *.txt
```

## Testing

For testing simply add flag `-Test <testFolder>` to command, for example to test folder 2 in `Test/` :

```console
.\syncMyFolder.ps1 C:\Users\Kim\Folder1 C:\Users\Kim\Folder2 -Test testFolder2
```

There's already a few tests provided but if you wish, you can create new test folders with a custom structure for testing. Parent folder should be named 'testFolder8', 'testFolder9', etc ... Once created, you must create a `.zip` backup of the test folder placed in `0_backup_zip/`  directory, archive will used to restore original structure of test folder after the test synchronization.

Run Script with test flag and then either :

- Say no `N` when prompted to check if testFolders content fits expected results. Then, run script again and say yes `Y` when prompted to re-initialize testFolders to original structure.
- Don't do anything, check if testFolders content fits expected results (Go to logs to see if folders are in sync or check console message) and if everything is ok, enter `Y` to restore test folder original structure.
