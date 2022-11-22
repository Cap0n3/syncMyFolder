# Test folder 6

A `target folder` with different files and folders in it BUT ONE folder AND a file identical from `source folder`. **This test adds two files for source and target that shouldn't be synced or removed** :

- `doNotSync1.png` (Source folder)
- `doNotSync2.jpg` (Source folder)
- `doNotRemove1.gp7` (Target folder)
- `doNotRemove2.doc` (Target folder)

> **Note :** Don't forget to create an exclusion file with script flag `-f <FileName>` and format file with correct syntax, it should look like this :
>
> ```txt
> [src] C:\Users\Kim\SyncMyFolder\tests\testFolder6\Folder1\SubFolder1\doNotSync1.png
> [src] C:\Users\Kim\SyncMyFolder\tests\testFolder6\Folder1\doNotSync2.jpg
> [tgt] C:\Users\Kim\SyncMyFolder\tests\testFolder6\Folder2\SubFolder1\DoNotRemove1.gp7
> [tgt] C:\Users\Kim\SyncMyFolder\tests\testFolder6\Folder2\DoNotRemove2.doc
> ```

## Goal

1. Remove files `ToRemove2.jpg`, `ToRemoveSub1.rtf` AND folder `Folder2/SubFolder2` to match `source folder` (Folder1) content.
2. Files in exception file shouln't be synced from `source folder` or removed from `target folder`.

## Structure

Folder1/
├─ SubFolder1/
│  ├─ doNotSync1.png
│  ├─ mySubText1.txt
├─ doNotSync2.jpg
├─ myImg1.jpg
├─ myText1.txt
Folder2/
├─ SubFolder1/
│  ├─ mySubText1.txt
│  ├─ ToRemoveSub1.rtf
│  ├─ doNotRemove1.gp7
├─ SubFolder2/
│  ├─ ToRemoveSub2.txt
├─ doNotRemove2.doc
├─ ToRemove2.jpg

## Expected tree

Folder1/
├─ SubFolder1/
│  ├─ doNotSync1.png
│  ├─ mySubText1.txt
├─ doNotSync2.jpg
├─ myImg1.jpg
├─ myText1.txt
Folder2/
├─ SubFolder1/
│  ├─ mySubText1.txt
│  ├─ doNotRemove1.gp7
├─ doNotRemove2.doc
├─ myImg1.jpg
├─ myText1.txt
