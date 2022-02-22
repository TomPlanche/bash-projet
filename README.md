<div align="center">
    <h1 style="
               font-size: 2rem;
               background-color: var(--background);
               display: block;
               margin: auto;
               padding: 15px;
               text-align: center;
               width: 75%;
               min-height: 90px;
               cursor: pointer;
               box-shadow:
                5px  -5px  0 -5px rgba(88, 133, 176, 0.1), 5px  -5px  #10BBE5,
                10px -10px 0 -5px rgba(88, 133, 176, 0.1), 10px -10px #0D98BA,
                15px -15px 0 -5px rgba(88, 133, 176, 0.1), 15px -15px #0A758F,
                20px -20px 0 -5px rgba(88, 133, 176, 0.1), 20px -20px #075264;
               ">
        Small School Project In Bash (unfinished)
    </h1>
</div>



## Goal

This project consists of creating a <u>**VFS** (**Virtual File System**)</u>

## Définition

> A **virtual** file system is a hierarchical data structure that allows the management of information about a specific domain. For example, for process management, Linux uses the **/proc,** file system which is a hierarchy of folders in which information about each process is stored (each has a folder named after the PID of the process). This information can be: priority, CPU flags to use, processor cores to use (affinity), etc.

## Expectations

This project has 4 different expectations :

- [Create a folder hierarchy by running a command](#1-create-a-folder-hierarchy-by-running-a-command)
- [Copy a file to the VFS by scanning its extension](#2-copy-a-file-to-the-vfs-by-scanning-its-extension)
- [Retrieving the path of a file](#3--retrieving-the-path-of-a-file)
- Check the integrity of the VFS
- Delete a file or the entire VFS

### 1. Create a folder hierarchy by running a command

- Allows to create the VFS, if the VFS is already created, the user is proposed to rewrite over it or not.

```shell
# If the file does not exist.
sh projet.sh -create
# screen: "VFS created."

# If the file already exists.
sh projet.sh -create
# screen: "VFS already exists, do you want to delete it and recreate it? (o/n): "
```

![Chart](https://github.com/TomPlanche/bash-projet/blob/master/chart-VFS.png)

### 2. **Copy a file to the VFS by scanning its extension**

- Allows you to copy any file to the VFS.

    - If the file exists **<u>and</u>** there is a folder for the file extension **<u>and</u>** this file is not in the VFS.

        - Copy in the right folder

            ```bash
            sh projet.sh -copy test.ai 
            # screen: test.ai -> VFS/Documents/Illustrator/test.ai
            ```

    - If a file with the same name and extension is already in the VFS

        -  Create a numbered file.

            ```bash
            sh project.sh -copy test.ai
            # screen: test.ai -> VFS/Documents/Illustrator/test-1.ai
            sh project.sh -copy test.ai
            # screen: test.ai -> VFS/Documents/Illustrator/test-2.ai
            # etc..
            ```

    - If the extension is not recognised, then the program asks the user if they wish to :

        - Copy the file to a 'Random' folder or create a new folder and enter the name.

            ```bash
            sh project.sh test.sh
            # screen: There is no folder for this type of file,
                # Do you want to move this file to the 'Random' folder: choice 1?
                # or do you want to create a special folder in $v/Documents: choice 2?
                # (1 or 2): <- user input
            
            # If the user has chosen 1
                # screen: test.sh -> VFS/Documents/Random/test.sh
            
            # If user has chosen 2
                # screen: Name of the new Folder: <- user input
                # test.sh -> VFS/Documents/NameNewFolder/test.sh
            ```


![Chart](https://github.com/TomPlanche/bash-projet/blob/master/chart-VFS-2.png)

### 3.  Retrieving the path of a file

```shell
sh projet.sh -where fileSearched
# screen: fileSearched in fileSearchedPath
```

- Let's take the VFS [from above](#2-copy-a-file-into-the-vfs-by-analysing-its-extension) as an example.

```sh
sh projet.sh -where test.ai
# screen: test.ai in VFS/Documents/Illustrator/
```
