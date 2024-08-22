# The arc archive specification.
###### arc stands for archive clear
## 1st part: The file offset table
The file offset table contains all files and their offset in the file (in bytes/characters).  
If a file is to be treated as a directory, the file's offset will be -1  
The file offset table contains every file's offset in this format: (every file is a new line)  
|{name}|{offset}|  
For example:  
|hello|-1|
|hello/world|27|  
This means that filenames cannot contain the letter | nor a newline.
## 2nd part: The raw data
After the table comes a newline. And after that newline comes the raw file data.
