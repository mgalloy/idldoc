From an official release
------------------------

The easiest way to get IDLdoc is to use an official release:

1. Download the release from the Releases_ page of the wiki.

.. _Releases:https://github.com/mgalloy/idldoc/wiki/Releases

2. Modify your ``!path`` to make sure the ``idldoc.sav`` file is found. There are various techniques to make this change, i.e., changing the `IDL_PATH` environment variable, changing the `IDL_PATH` preference, through the preferences in the IDL Workbench, etc.


From the GitHub repo
--------------------

Getting IDLdoc from the the GitHub repository is only slightly harder:

1. Get the git repo and its submodules with::

     $ git clone --recursive git@github.com:mgalloy/idldoc.git

2. Put the ``src`` and ``lib`` directories and their subdirectories into your
   IDL ``!path`` in your favorite manner.

