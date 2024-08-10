Command reference
=================

| If you use arcos, you should already be pretty comfortable with a UNIX-like shell or the craftos shell.
| But here's a basic command reference

| ``ls <directory>``
| Lists a directory
| Example:

.. code-block::

        root@arcos /user/root # cd /
        root@arcos / # ls
        apis apps config data rom services startup.lua system temporary user
        

| ``cd <directory>``
| Changes into directory. You can either use relative paths (ex. ``cd system``) or absolute ones (ex. ``cd /system``)
| Example:

.. code-block::

        root@arcos /user/root # cd /
        root@arcos / # cd system
        root@arcos /system #

| ``cp <source> <target>``
| Copies file <source> into <target>
| Example:

.. code-block::

        root@arcos /user/root # ls
        file.lua
        root@arcos /user/root # cp file.lua file2.lua
        root@arcos /user/root # ls
        file.lua file2.lua


| ``mv <source> <target>``
| Moves <source> to <target>
| Same as ``cp`` but deletes the old file
| Example:

.. code-block::

        root@arcos /user/root # ls
        file.lua
        root@arcos /user/root # mv file.lua file2.lua
        root@arcos /user/root # ls
        file2.lua

