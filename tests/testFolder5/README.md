# Test folder 5

A `target folder` with different files and folders in it BUT ONE folder AND a file identical from `source folder`. **This test adds two files for source that shouldn't be synced** :

- `doNotSync1.png` (Source folder)
- `doNotSync2.jpg` (Source folder)

> **Note :** Don't forget to create an exception file with script flag `-f <FileName>` and format file with correct syntax, it should look like this :
>
> ```txt
> [src] C:\Users\Kim\SyncMyFolder\tests\testFolder5\Folder1\SubFolder1\doNotSync1.png
> [src] C:\Users\Kim\SyncMyFolder\tests\testFolder5\\Folder1\doNotSync2.jpg
> ```

## Goal

- Don't copy `doNotSync1.png` and `doNotSync2.jpg` in `Folder2`.
- Remove file `ToRemove.jpg`.
- Remove file `ToRemoveSub1.rtf` from `Folder2/SubFolder1` 
- Remove folder `SubFolder2`.
- Keep `mySubText1.txt` in `Folder2/SubFolder1`.

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
├─ SubFolder2/
│  ├─ ToRemoveSub2.txt
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
├─ myImg1.jpg
├─ myText1.txt
