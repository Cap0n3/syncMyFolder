# Test folder 3

A `source folder` with **one subfolder and one sub-subfolder (2 levels)**. A `target folder` with different files and folders BUT ONE folder AND two files identical from `source folder`.

## Goal

- Remove file `ToRemove.jpg`.
- Remove file `ToRemoveSub1.rtf` from `SubFolder1` 
- Remove folder `SubFolder2`.
- Keep `mySubText1.txt` and `mySubText2.txt` in `SubFolder1`.
- Copy `MyVids` and its content.

## Structure

Folder1/
├─ SubFolder1/
│  ├─ mySubText1.txt
│  ├─ mySubText2.txt
│  ├─ MyVids/
│     ├─ Vid1.mov
│     ├─ Vid2.mov
├─ myImg1.jpg
├─ myText1.txt
Folder2/
├─ SubFolder1/
│  ├─ mySubText1.txt
│  ├─ mySubText2.txt
│  ├─ ToRemoveSub1.rtf
├─ SubFolder2/
│  ├─ ToRemoveSub2.txt
├─ ToRemove2.jpg

## Expected tree

Folder1/
├─ SubFolder1/
│  ├─ MyVids/
│     ├─ Vid1.mov
│     ├─ Vid2.mov
│  ├─ mySubText1.txt
│  ├─ mySubText2.txt
├─ myImg1.jpg
├─ myText1.txt
Folder2/
├─ SubFolder1/
│  ├─ MyVids/
│     ├─ Vid1.mov
│     ├─ Vid2.mov
│  ├─ mySubText1.txt
│  ├─ mySubText2.txt
├─ myImg1.jpg
├─ myText1.txt
