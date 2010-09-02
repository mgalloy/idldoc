IDLdoc Tutorial
===============

:Author: Michael Galloy
:Date: 24 August 2010



Introduction
------------

IDLdoc generates nicely formatted API documentation directly from source code. The idea is to keep the documentation close to the code and to have as much as possible be generated directly from the source code itself.

Features? 

  #. API documentation for both developers of the code base and users of the code base
  #. analyze code like complexity

Similar things? 

  #. Javadoc
  #. Doxygen

Inspired by reStructuredText and Sphinx projects

History? IDLdoc 2.0 vs. IDLdoc 3.0


Basics
------

The basic calling sequence for IDLdoc specifies the path to a directory (or hierarchy of directories) with the `ROOT` keyword and, optionally, the path to where the output should be created::

    IDL> idldoc, root='path/to/code', output='path/to/output'

If `OUTPUT` is not specified, output will be created inside the `ROOT` hierarchy next to the source files. By default, IDLdoc creates HTML documentation, though it can be customized to create other types of documentation. To view the documentation produced from the above command, open `path/to/output/index.html` in a web browser.

IDLdoc will generate useful documentation from any valid IDL code, showing the calling sequence of routines even if there are no comments, or no comments in a format that IDLdoc recognizes, in the source code. But for more useful documentation, comments formatted in a simple manner that IDLdoc recognizes can be parsed and placed into the output documentation.

IDLdoc examines files with `.pro`, `.sav`, `.dlm`, and `.idldoc` extensions. Source code and specially formatted comments in `.pro` files are parsed. Save files, of either the code or data varieties, are examined for their contents and listing of the routines or variables contained are produced. DLM files produce a similar, but more limited, output as normal source code files. Finally, `.idldoc` files are a way of including documentation that is common to several items, such as an overview of a directory or a page describing a topic that several routines refer to.

Two keywords you most likely will want to specify are `TITLE` and `SUBTITLE`. Set these to string values to be displayed prominently on your documentation. For example, the command used to generate the API documentation for the IDLdoc project itself is::

   idldoc, root='src', output='api-docs', $
           title='API documentation for IDLdoc ' + idldoc_version(), $
           subtitle='IDLdoc ' + idldoc_version(/full), /statistics, $
           index_level=1, overview='overview', footer='footer', /embed, $
           format_style='rst', markup_style='rst'

This places the IDLdoc version information into the title/subtitle of the documentation. We'll talk about some of the other options in the following sections.


Comment format
--------------

difference between format and markup, `FORMAT_STYLE` and `MARKUP_STYLE` keywords; format styles = idldoc (the default), rst, idl, verbatim; markup styles = verbatim (the default, unless rst format style), rst (default for rst format style), preformatted

"rst" is the modern supported style for both format and markup in current versions of IDLdoc (although not the default); legacy format/markup is described in the reference manual.

Files documented in different styles can be placed in the same directory hierarchy. The default IDLdoc styles, or those provided by the `FORMAT_STYLE` and `MARKUP_STYLE` keywords, can be overridden for a single file by placing a special comment on the first line of the file::

    ; docformat = 'rst'

This indicates that the rst format style should be used for this file. Since the rst markup style is the default when using the rst format style, it will also be used. To use the verbatim markup style with the rst format style for a particular file, place the following on the first line of the file::

    ; docformat = 'rst verbatim'
    
It is a good idea to place the `docformat` line on the beginning of every file that is shared with others, then IDLdoc will always use the correct styles even if the file is placed in another library.

The overview file, specified with the `OVERVIEW` keyword to IDLdoc, contains comments describing the entire directory hierarchy. It is displayed near the front of the documentation, e.g., in the HTML documentation it is shown on the first page of the output.

`.idldoc` files

Directory overview files are special `.idldoc` files that describe the contents of a particular directory. They are named `.idldoc` and placed in the corresponding directory. `Private`, `Hidden`, `Author`, `Copyright`, and `History` tags are allowed in a directory overview file.

user vs. developer documentation, `USER` keyword, private/hidden tags (and attributes)


Comment markup
--------------

TODO: The comment markup style defines how text can be annotated. Once the format style has defined a place for "put comments here" for a particular item, the markup style describes the syntax of those comments.

links and inline code, rules for named links?

preformatted code blocks

image directive::

    .. image:: filename.png
    
File formats?

title of an IDLdoc file, title directive::

    .. title:: This is the title of the file

Appears in navigation links on the left/title of the page


References
----------

The `project site <http://idldoc.idldev.com>`_ for IDLdoc contains more information about IDLdoc including the ticket system where bugs can be reported and new features requested. The mailing list, downloads of all versions along with their release notes, etc. 
