# Test folder 8

An empty `target folder` and several files and one folder in `source folder` that shouldn't be synced :

- `doNotSyncDir/` (Source folder)
- `doNotSyncSubFile.rtf` (Source folder)
- `doNotSync1.png` (Source folder)
- `doNotSync2.jpg` (Source folder)

> **Note :** Don't forget to create an exclusion file with script flag `-f <FileName>` and format file with correct syntax, it should look like this :
>
> ```txt
> [src] C:\Users\EMR\Documents\0_DEV_PROJECTS\0_PS_SCRIPTS\SyncMyFolder\tests\testFolder8\Folder1\SubFolder1\doNotSyncDir
> [src] C:\Users\EMR\Documents\0_DEV_PROJECTS\0_PS_SCRIPTS\SyncMyFolder\tests\testFolder8\Folder1\SubFolder1\doNotSync1.png
> [src] C:\Users\EMR\Documents\0_DEV_PROJECTS\0_PS_SCRIPTS\SyncMyFolder\tests\testFolder8\Folder1\doNotSync2.jpg
> ```

## Goal

- Files AND Folder in exclusion file shouln't be synced from `source folder`.

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
│  ├─ mySubText.txt
├─ myImg1.jpg
├─ myText1.txt
