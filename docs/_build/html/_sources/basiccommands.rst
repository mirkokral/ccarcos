Command reference
=================

| If you use arcos, you should already be pretty comfortable with a UNIX-like shell or the craftos shell.
| But here's a basic command reference

| ``ls <directory>``
| Lists a directory
| Example:

.. code-block:: sh
    :linenos:

        root@arcos /user/root # cd /
        root@arcos / # ls
        apis apps config data rom services startup.lua system temporary user
        root@arcos / #
        

| ``cd <directory>``
| Changes into directory. You can either use relative paths (ex. ``cd system``) or absolute ones (ex. ``cd /system``)
| Example:

.. code-block:: sh
    :linenos:

        root@arcos /user/root # cd /
        root@arcos / # cd system
        root@arcos /system #

| ``cp <source> <target>``
| Copies file <source> into <target>
| Example:

.. code-block:: sh
    :linenos:

        root@arcos /user/root # ls
        file.lua
        root@arcos /user/root # cp file.lua file2.lua
        root@arcos /user/root # ls
        file.lua file2.lua
        root@arcos /user/root #


| ``mv <source> <target>``
| Moves <source> to <target>
| Same as ``cp`` but deletes the old file
| Example:

.. code-block:: sh
    :linenos:

        root@arcos /user/root # ls
        file.lua
        root@arcos /user/root # mv file.lua file2.lua
        root@arcos /user/root # ls
        file2.lua
        root@arcos /user/root #

| ``cat <file>``
| Reads <file> and outputs it's contents
| Example:

.. code-block:: sh
    :linenos:

        root@arcos /user/root # ls
        tip.txt
        root@arcos /user/root # cat tip.txt
        The arcos source code is available at https://www.github.com/mirkokral/ccarcos/.
        root@arcos /user/root #
    
| ``mkdir <folder>``
| Creates a folder
| Example:

.. code-block:: sh
    :linenos:

        root@arcos /user/root # ls
        tip.txt
        root@arcos /user/root # mkdir test
        root@arcos /user/root # ls
        test tip.txt
        root@arcos /user/root # mv tip.txt test/tip.txt
        root@arcos /user/root # ls
        test
        root@arcos /user/root # ls test
        tip.txt
        root@arcos /user/root #

| ``rm <file/folder>``
| Removes a file or folder
| Example:

.. code-block:: sh
    :linenos:

        root@arcos /user/root # ls
        tip.txt
        root@arcos /user/root # rm tip.txt
        root@arcos /user/root # ls

        root@arcos /user/root #



| ``arc fetch``
| Fetches the latest repository information
| Example:

.. code-block:: sh
    :linenos:

        root@arcos /user/root # arc fetch
        root@arcos /user/root #

| ``arc install <package>``
| Installs a package
| Example:

.. code-block:: sh
    :linenos:

        root@arcos /user/root # arc fetch
        root@arcos /user/root # arc install craft
        These packages will be installed:

        rednet craft

        Do you want to proceed? [y/n] y
        (1/2) rednet
        (2/2) craft
        Done
        root@arcos /user/root # craft
        CraftOS 1.8 Compat on arcos 24.08 "Vertica" (Alpha release)
        missingno
        > hello
        Hello, world!
        >

| ``arc uninstall <package>``
| Uninstalls a package
| Example:

.. code-block:: sh
    :linenos:

        root@arcos /user/root # arc uninstall craft
        These packages will be uninstalled:

        craft

        Do you want to proceed? [y/n] y
        root@arcos /user/root # craft
        [string "eval"]:1: '=' expected near <eof>
        root@arcos /user/root #



