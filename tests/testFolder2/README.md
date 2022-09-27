# Test 2

A `target folder` with different files and folders in it **BUT ONE folder AND a file identical from `source folder`.**

## Goal

- Remove file `ToRemove.jpg`.
- Remove file `ToRemoveSub1.rtf` from `SubFolder1` 
- Remove folder `SubFolder2`.
- Keep `mySubText1.txt` in `SubFolder1`.

## Structure

Folder1/
├─ SubFolder1/
│  ├─ mySubText1.txt
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
│  ├─ mySubText1.txt
├─ myImg1.jpg
├─ myText1.txt
Folder2/
├─ SubFolder1/
│  ├─ mySubText1.txt
├─ myImg1.jpg
├─ myText1.txt
