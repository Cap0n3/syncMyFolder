# Test folder 7

A `target folder` with different files and folders in it BUT ONE folder. **This test adds two files AND two folders for source and target that shouldn't be synced or removed** :

- `doNotSyncDir/` (Source folder)
- `doNotSyncSubFile.rtf` (Source folder)
- `doNotSync1.png` (Source folder)
- `doNotSync2.jpg` (Source folder)
- `doNotRemoveDir/` (Target folder)
- `doNotRemoveSubFile.jpg` (Target folder)
- `DoNotRemove1.gp7` (Target folder)
- `DoNotRemove2.doc` (Target folder)

> **Note :** Don't forget to create an exclusion file with script flag `-f <FileName>` and format file with correct syntax, it should look like this :
>
> ```txt
> [src] C:\Users\EMR\Documents\0_DEV_PROJECTS\0_PS_SCRIPTS\SyncMyFolder\tests\testFolder7\Folder1\SubFolder1\doNotSyncDir
> [src] C:\Users\EMR\Documents\0_DEV_PROJECTS\0_PS_SCRIPTS\SyncMyFolder\tests\testFolder7\Folder1\SubFolder1\doNotSync1.png
> [src] C:\Users\EMR\Documents\0_DEV_PROJECTS\0_PS_SCRIPTS\SyncMyFolder\tests\testFolder7\Folder1\doNotSync2.jpg
> [tgt] C:\Users\EMR\Documents\0_DEV_PROJECTS\0_PS_SCRIPTS\SyncMyFolder\tests\testFolder7\Folder2\SubFolder1\doNotRemoveDir
> [tgt] C:\Users\EMR\Documents\0_DEV_PROJECTS\0_PS_SCRIPTS\SyncMyFolder\tests\testFolder7\Folder2\SubFolder1\doNotRemove1.gp7
> [tgt] C:\Users\EMR\Documents\0_DEV_PROJECTS\0_PS_SCRIPTS\SyncMyFolder\tests\testFolder7\Folder2\doNotRemove2.doc
> ```

## Goal

1. Remove files `ToRemove.jpg`, `ToRemoveSub1.rtf` AND folder `Folder2/SubFolder2` to match `source folder` (Folder1) content.
2. Files AND Folders in exclusion file shouln't be synced from `source folder` or removed from `target folder`.

## Structure

Folder1/
├─ SubFolder1/
│  ├─ doNotSyncDir/
│     ├─ doNotSyncSubFile.rtf
│  ├─ doNotSync1.png
│  ├─ mySubText.txt
├─ doNotSync2.jpg
├─ myImg1.jpg
├─ myText1.txt
Folder2/
├─ SubFolder1/
│  ├─ doNotRemoveDir/
│     ├─ doNotRemoveSubFile.jpg
│  ├─ ToRemoveSub1.rtf
│  ├─ doNotRemove1.gp7
├─ SubFolder2/
│  ├─ ToRemoveSub2.txt
├─ doNotRemove2.doc
├─ ToRemove2.jpg

## Expected tree

Folder1/
├─ SubFolder1/
│  ├─ doNotSyncDir/
│     ├─ doNotSyncSubFile.rtf
│  ├─ doNotSync1.png
│  ├─ mySubText.txt
├─ doNotSync2.jpg
├─ myImg1.jpg
├─ myText1.txt
Folder2/
├─ SubFolder1/
│  ├─ doNotRemoveDir/
│     ├─ doNotRemoveSubFile.jpg
│  ├─ mySubText.txt
│  ├─ doNotRemove1.gp7
├─ doNotRemove2.doc
├─ myImg1.jpg
├─ myText1.txt
