IDLdoc 3.3 Tutorial
===================

:Author: Michael Galloy

:Abstract: This tutorial attempts to provide a friendly guide to start using IDLdoc. See the reference guide for a more detailed listing of all the options that IDLdoc provides.


Introduction
------------

IDLdoc generates nicely formatted API documentation directly from source code. The idea is to keep the documentation close to the code and to have as much as possible be generated directly from the source code itself.

Features? 

  #. API documentation for both developers and users of the code base
  #. analyze code for things like code complexity

Similar things? 

  #. Javadoc
  #. Doxygen

Inspired by reStructuredText and Sphinx projects

History? IDLdoc 2.0 vs. IDLdoc 3.0

This tutorial intends to get a new user up to speed in using IDLdoc in the simplest way using the newer, more modern style of IDLdoc commenting. Don't worry, though, IDLdoc still supports legacy commenting styles so you don't have to go changing existing documentation (unless you want to make use of some of the cool, new features!). Experienced users will probably learn some new things too, since documentation for IDLdoc has been spotty in the past.


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

Note: By default, IDLdoc 3.0 copies source code into the output directory, so placing the output directory in your `!PATH` can cause IDL to choose the (possibly outdated) copy in the docs over the correct source file. It is recommended to either place your docs outside your `!PATH` or use the `NOSOURCE` keyword.


Comment format
--------------

difference between format and markup, `FORMAT_STYLE` and `MARKUP_STYLE` keywords; format styles = idldoc (the default), rst, idl, verbatim; markup styles = verbatim (the default, unless rst format style), rst (default for rst format style), preformatted

"rst" is the modern supported style for both format and markup in current versions of IDLdoc (although not the default); legacy format/markup is described in the reference manual.


Source code files
~~~~~~~~~~~~~~~~~

file vs routine comments

common file tags: `Examples`, `Author`, `Copyright`, `History`

common routine tags: `Returns`, `Params`, `Keywords`, `Examples`, `Uses`, `Requires`, `Author`, `Copyright`, `History`

Source code files documented in different styles can be placed in the same directory hierarchy. The default IDLdoc styles, or those provided by the `FORMAT_STYLE` and `MARKUP_STYLE` keywords, can be overridden for a single file by placing a special comment on the first line of the file::

    ; docformat = 'rst'

This indicates that the rst format style should be used for this file. Since the rst markup style is the default when using the rst format style, it will also be used. To use the verbatim markup style with the rst format style for a particular file, place the following on the first line of the file::

    ; docformat = 'rst verbatim'
    
It is a good idea to place the `docformat` line on the beginning of every file that is shared with others, then IDLdoc will always use the correct styles even if the file is placed in another library.


The overview file
~~~~~~~~~~~~~~~~~

The overview file, specified with the `OVERVIEW` keyword to IDLdoc, contains comments describing the entire directory hierarchy. It is displayed near the front of the documentation, e.g., in the HTML documentation it is shown on the first page of the output.

TODO: overview file tags: `Author`, `Copyright`, `History`, `Version`, `Dirs`


`.idldoc` files
~~~~~~~~~~~~~~~

There are no special tags in `.idldoc` files; the entire file is just one big comment block. The one special syntax for `.idldoc` files is the `title` directive described in the markup section.

NOTE: "`.idldoc` files" refers to files with an `.idldoc` extension, like `cptcity-catalog.idldoc`. Files the name `.idldoc` are directory overview files, described below.


Directory overview files
~~~~~~~~~~~~~~~~~~~~~~~~

Directory overview files are special `.idldoc` files that describe the contents of a particular directory. They are named `.idldoc` and placed in the corresponding directory. `Private`, `Hidden`, `Author`, `Copyright`, and `History` tags are allowed in a directory overview file.

For example, the `collection/` directory of the IDLdoc source contains the following `.idldoc` file::

    The collection framework defines classes to provide various types of
    containers, primarily list (`MGcoArrayList`) and hash table 
    (`MGcoHashTable`) implementation. These containers are more general than 
    `IDL_Container`, in that they allow elements of any IDL type instead of 
    just objects.

    :Author:
       Michael Galloy

    :Copyright:
      BSD-licensed

The comments from the above directory overview file, along with a listing of the files in the directory, appear somewhere near the beginning of the documentation for the directory. In the HTML output, the link from the main overview page or the link in the lower-left navigation window when the directory has been selected in the upper-right navigation window lead to the directory overview page.


Comment markup
-------------- 

Several markup styles are available to annotate comment text with typesetting instructions. The "verbatim" and "preformatted" markup styles are the simplest, the comments are copied straight to the documentation with the "preformatted" style displaying the comments as monospaced, plain text also. The more modern "rst" markup style defines a simple syntax for annotating the comment text with links, images, or code samples. While the "verbatim" and "preformatted" markup styles can be useful for legacy code comments, the "rst" markup style is easier to read and is recommended for all new comments.

TODO: The comment markup style defines how text can be annotated. Once the format style has defined a place for "put comments here" for a particular item, the markup style describes the syntax of those comments.

links and inline code, rules for named links?

preformatted code blocks

image directive::

    .. image:: filename.png
    
File formats?

embed directive::

    .. embed:: filename
    
File formats?

title of an `.idldoc` file, title directive::

    .. title:: This is the title of the file

Appears in navigation links on the left/title of the page

headers, =, -, or ~ anywhere, but most useful in `.idldoc` files


IDLdoc options
--------------

user vs. developer documentation, `USER` keyword, private/hidden tags (and attributes)

The `FOOTER` keyword can specify a file to include at the bottom of each page of output.

When producing HTML documentation, there are often two cases that need to be handled: 

  #. documentation served on a web site and intended to be served as a full collection
  #. documentation pages intended to be handed out individually, e.g., giving someone a `.pro` file and its generated HTML documentation file
  
In the later case, it is often useful to set the `EMBED` and `NONAVBAR` keywords. The `EMBED` keyword embeds the, rather large, CSS file into each HTML page. This is inefficient for a full documentation set on a web site because in that situation, each page can just refer to a common `.css` file. The `NONAVBAR` keyword simply omits the navigation bar at the top of the page which is not needed when only one HTML page is given but useful to navigate a full documentation set.

index_level=1

source code options

/statistics and cutoffs


References
----------

The `project site <http://idldoc.idldev.com>`_ for IDLdoc contains more information about IDLdoc including the ticket system where bugs can be reported and new features requested. The mailing list, downloads of all versions along with their release notes, etc. 
