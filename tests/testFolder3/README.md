# Test 3

A `target folder` with different files and folders in it BUT ONE folder AND a file identical from `source folder`. **This test adds two files for source and target that shouldn't be synced or removed** :

- `doNotSync1.png` (Source folder)
- `doNotSync2.jpg` (Source folder)
- `DoNotRemove1.gp7` (Target folder)
- `DoNotRemove2.doc` (Target folder)

> **Note :** Don't forget to create an exception file with script flag `-f <FileName>` and format file with correct syntax, it should look like this :
>
> ```txt
> [src] doNotSync1.png
> [src] doNotSync2.jpg
> [tgt] DoNotRemove1.gp7
> [tgt] DoNotRemove2.doc
> ```

## Goal

1. Remove files `ToRemove.jpg`, `ToRemoveSub1.rtf` AND folder `SubFolder2` to match `source folder` (Folder1) content.
2. Files in exception file shouln't be synced from source or removed from target.

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
│  ├─ DoNotRemove1.gp7
├─ SubFolder2/
│  ├─ ToRemoveSub2.txt
├─ DoNotRemove2.doc
├─ ToRemove2.jpg
