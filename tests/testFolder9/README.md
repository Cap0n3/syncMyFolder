# Test Folder 9

Test with an empty `target folder` AND hidden files.

## Goal

The script should simply copy source folder content (content only and not the folder itself) in target directory. It should NOT copy hidden files.

## Structure

Folder1/
├─ SubFolder1/
│  ├─ .myHiddenFile1.txt
│  ├─ mySubText1.txt
├─ .myHiddenFile2.bak
├─ myImg1.jpg
├─ myText1.txt
Folder2/

## Expected tree

Folder1/
├─ SubFolder1/
│  ├─ .myHiddenFile1.txt
│  ├─ mySubText1.txt
├─ .myHiddenFile2.bak
├─ myImg1.jpg
├─ myText1.txt
Folder2/
├─ SubFolder1/
│  ├─ mySubText1.txt
├─ myImg1.jpg
├─ myText1.txt
