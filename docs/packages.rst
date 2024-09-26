Packages
========

Packages are installed by using the arc command.
Example:

.. code-block:: sh
    :linenos:

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

Making a package
----------------
| Note: replace ``<package name>`` with your package name

1. Setup
    1. Clone the arcos repo: ``git clone https://www.github.com/mirkokral/ccarcos.git``
    2. Make your own directory to the ``repo`` dir: ``mkdir repo/<package name>``
    3.
