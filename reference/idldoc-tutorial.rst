IDLdoc Tutorial
===============

:Author: Michael Galloy
:Date: 24 August 2010



Introduction
------------

IDLdoc generates nicely formatted API documentation directly from source code. The idea is to keep the documentation close to the code and to have as much as possible be generated directly from the source code itself.

Features? 

  #. analyze code like complexity

Similar things? 

  #. Javadoc
  #. Doxygen

History? IDLdoc 2.0 vs. IDLdoc 3.0


Basics
------

Run on undocumented code::

    IDL> idldoc, root='path/to/code', output='path/to/output'

Can be marked up in special ways.

files examined: `.pro`, `.sav`, `.dlm`, `.idldoc`


Comment format
--------------

difference between format and markup

"rst" is the standard for both format and markup in current versions of IDLdoc (although not the default); legacy format/markup is described in the reference manual.

overview file

directory overview files

user vs. developer documentation, private/hidden tags (and attributes)


Comment markup
--------------

links and inline code, preformatted code blocks, images

title of an IDLdoc file


References
----------

The `project site <http://idldoc.idldev.com>`_ for IDLdoc contains more information about IDLdoc including the ticket system where bugs can be reported and new features requested. The mailing list, downloads of all versions along with their release notes, etc. 
