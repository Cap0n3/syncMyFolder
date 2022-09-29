# Test folder 4

A `source folder` with **one subfolder and two sub-subfolder (3 levels)**. A `target folder` with different files and folders BUT ONE folder identical from `source folder` BUT with a slighly different tree structure .

## Goal

- Remove file `ToRemove.jpg`.
- Remove file `ToRemoveSub1.rtf` from `Folder2/SubFolder1/` 
- Remove folder `SubFolder2/`.
- Keep `mySubText1.txt` in `SubFolder1/`.
- Copy `MyVids/` and its content.
- Remove `Virus/` (+ content) and `foo.txt` from `Folder2/SubFolder1/`.
- Keep `Vid2.mov` in `Folder2/SubFolder1/MyVids/`.

## Structure

Folder1/
├─ SubFolder1/
│  ├─ mySubText1.txt
│  ├─ MyVids/
│     ├─ BestShows/
│        ├─ MovieList.txt
│     ├─ Vid1.mov
│     ├─ Vid2.mov
├─ myImg1.jpg
├─ myText1.txt
Folder2/
├─ SubFolder1/
│  ├─ mySubText1.txt
│  ├─ MyVids/
│     ├─ BestShows/
│        ├─ Virus/
│           ├─ Weird
│        ├─ foo.txt
│     ├─ Vid2.mov
│  ├─ ToRemoveSub1.rtf
├─ SubFolder2/
│  ├─ ToRemoveSub2.txt
├─ ToRemove2.jpg

## Expected tree

Folder1/
├─ SubFolder1/
│  ├─ mySubText1.txt
│  ├─ MyVids/
│     ├─ BestShows/
│        ├─ MovieList.txt
│     ├─ Vid1.mov
│     ├─ Vid2.mov
├─ myImg1.jpg
├─ myText1.txt
Folder2/
├─ SubFolder1/
│  ├─ mySubText1.txt
│  ├─ MyVids/
│     ├─ BestShows/
│        ├─ MovieList.txt
│     ├─ Vid1.mov
│     ├─ Vid2.mov
├─ myImg1.jpg
├─ myText1.txt
