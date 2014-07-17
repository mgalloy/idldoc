What is IDLdoc?
---------------

IDLdoc generates nicely formatted API documentation directly from IDL source
code. If the documentation is kept close to the code itself is much more likely
to be kept up-to-date. As much as possible the documentation produced by IDLdoc
is generated directly from the source code, making IDLdoc useful even if there
are no specially formatted comments at all in the source code.


Installing from an official release
-----------------------------------

The easiest way to get IDLdoc is to use an official release:

1. Download the release from the Releases_ page of the wiki.

.. _Releases:https://github.com/mgalloy/idldoc/wiki/Releases

2. Modify your ``!path`` to make sure the ``idldoc.sav`` file is found. There are various techniques to make this change, i.e., changing the `IDL_PATH` environment variable, changing the `IDL_PATH` preference, through the preferences in the IDL Workbench, etc.


Installing from GitHub
----------------------

It is easy to install IDLdoc directly from the GitHub repo:

1. Get the git repo and its submodules with::

     $ git clone --recursive git@github.com:mgalloy/idldoc.git

2. Put the ``src`` and ``lib`` directories and their subdirectories into your
   IDL ``!path`` in your favorite manner.


References
----------

See the Reference guide and Tutorial in the `docs/` directory.

See `INSTALL.rst` for more information about installing IDLdoc.

See `RELEASE.rst` for the release notes for this, and past, versions of IDLdoc.

For more information about converting a library from using IDLdoc 2.0 to IDLdoc
3.0, see `ISSUES.rst`.
