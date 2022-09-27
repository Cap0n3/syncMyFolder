# Test Folder 1

A `target folder` with different files and folders in it. Source `Folder1` and Target `Folder2` have a totally different structure.

## Goal

Since "source" `Folder1` and "target" `Folder2` have nothing in common, everything should be erased from `target folder` (Folder2) and replaced with `source folder` (Folder1) content.

## Structure

Folder1/
├─ SubFolder1/
│  ├─ mySubText1.txt
├─ myImg1.jpg
├─ myText1.txt
Folder2/
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
