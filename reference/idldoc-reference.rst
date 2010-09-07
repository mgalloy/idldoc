IDLdoc 3.3 Reference
====================

:Author: Michael Galloy


IDLdoc installation
-------------------

To install IDLdoc, simply unzip and place the IDLdoc distribution in your IDL path. Do not separate the contents of the distribution; the code looks for files in locations relative to itself.


IDLdoc routine keywords
-----------------------

There are quite a few keywords to IDLdoc to set various specifications for the output. Also see the "Customizing Output" section for using templates for customized output.

=================== ========================================================
Keyword             Description
=================== ========================================================
`ASSISTANT`         obsolete; no longer used
`BROWSE_ROUTINES`   obsolete; no longer used
`CHARSET`           set to the character set to be used for the output, 
                    default is "utf-8"
`COMMENT_STYLE`     output format for comments ("html", "rst", or "latex"); 
                    default is "html"
`DEBUG`             set to allow crashes with a stack trace instead of the 
                    default simple message
`EMBED`             embed CSS stylesheet instead of linking to it (useful for 
                    documentation where individual pages must stand by 
                    themselves)
`ERROR`             set to a named variable to return the error state of the 
                    IDLdoc call; 0 indicates no error, anything else is an 
                    error
`FOOTER`            filename of file to insert into the bottom of each page of 
                    docs
`FORMAT_STYLE`      style to use to parse file and routine comments ("idl",
                    "idldoc", "verbatim", or "rst"); default is "idldoc"
`HELP`              set to print out the syntax of an IDLdoc call
`LOG_FILE`          if present, send messages to this filename instead of 
                    *stdout*
`MARKUP_STYLE`      markup used in comments ("rst" or "verbatim"); default is
                    "verbatim"
`N_WARNINGS`        set to a named variable to return the number of warnings 
                    for the IDLdoc run
`NONAVBAR`          set to not display the navbar
`NOSOURCE`          set to not put source code into output
`OUTPUT`            directory to place output; if not present, output will be 
                    placed in the `ROOT` directory           
`OVERVIEW`          filename of overview text and directory information
`PREFORMAT`         obsolete; no longer used
`QUIET`             if set, don't print info messages, only print warnings and 
                    errors
`ROOT`	            root of directory hierarchy to document; this is the only 
                    required keyword
`SILENT`            if set, don't print any messages
`STATISTICS`        set to generate complexity statistics for routines
`SUBTITLE`          subtitle for docs
`TEMPLATE_PREFIX`   prefix for template's names
`TEMPLATE_LOCATION` set to directory to find templates in
`TITLE`             title of docs
`USER`              set to generate user-level docs (private parameters, files 
                    are not shown); the default is developer-level docs 
                    showing files and parameters
`VERSION`           set to print out the version of IDLdoc
=================== ========================================================



Format styles
-------------


rst format style
~~~~~~~~~~~~~~~~

The following tags are available in file comments (i.e. comment headers not immediately preceeding/following a routine header).

============== ============ ============ ====================================
Tag name       Arguments    Attributes   Description
============== ============ ============ ====================================
`:Author:`     comments     none         specifies the author of the file
`:Copyright:`  comments     none         specifies the copyright information 
                                         for the file
`:Examples:`   comments     none         specifies examples of usage
`:Hidden:`     none         none         if present, indicates the file is not  
                                         to be shown in the documentation
`:History:`    comments     none         lists the history for the file
`:Private:`    none         none         if present, indicates the file should 
                                         not shown in user-level documentation 
                                         (set with the `USER` keyword to 
                                         IDLdoc)
`:Properties:` property     none         describes properties of a class,                                          
               name,                     i.e., a keyword to `getProperty`, 
               comments                  `setProperty`, or `init`
`:Version:`    comments     none         specifies the version of the file
============== ============ ============ ====================================


The following tags are available for comments immediately before or after a routine header.

================= ============ ========== =================================
Tag name          Arguments    Attributes Description
================= ============ ========== =================================
`:Abstract:`      none         none       if present, indicates the method is 
                                          not implemented and present only to 
                                          specify the interface to subclasses' 
                                          implementations
`:Author:`        comments     none       specifies the author of the routine
`:Bugs:`          comments     none       specifies any issues found in the 
                                          routine
`:Categories:`    list         none       specifies a comma-separated list of 
                                          category names
`:Copyright:`     comments     none       specifies the copyright for the 
                                          routine
`:Customer_id:`   comments     none       specifies a customer ID for the 
                                          routine
`:Description:`   comments     none       a tag for the standard comments for 
                                          a routine; will be appended to 
                                          standard comments if both are 
                                          present
`:Examples:`      comments     none       specifies examples of using the 
                                          routine
`:Fields:`        fieldname    none       specifies the names of the field 
                  and comments	          followed by a description of the 
                                          field
`:File_comments:` comments     none       equivalent to the main section in 
                                          file-level comments
`:Hidden:`        none         none       if present, indicate the routine 
                                          should not be shown in the 
                                          documentation
`:Hidden_file:`   none         none       if present, indicates the file 
                                          containing this routine should not 
                                          be shown in the documentation
`:History:`       comments     none       specifies the history of the 
                                          routine
`:Inherits:`      none         none       not used
`:Keywords:`      keyword name see below	documents keywords of the routine
`:Obsolete:`      none         none       if present, indicates the routine is 
                                          obsolete
`:Params:`        param name   see below  documents positional parameters of 
                                          the routine
`:Post:`          comments     none       specifies any post-conditions of the 
                                          routine
`:Pre:`           comments     none       specifies any pre-conditions of the 
                                          routine
`:Private:`       none         none       if present, indicates the routine 
                                          should not shown in user-level 
                                          documentation (set with the `USER` 
                                          keyword to IDLdoc)
`:Private_file:`  comments     none       if present, indicates the file 
                                          containing this routine should not 
                                          shown in user-level documentation 
                                          (set with the `USER` keyword to 
                                          IDLdoc)
`:Requires:`      comments     none       specifies the IDL version of the 
                                          routine; IDLdoc finds the routines 
                                          requiring the highest IDL version 
                                          and reports them on the warnings 
                                          page
`:Returns:`       comments     none       specifies the return value of the 
                                          function
`:Todo:`          comments     none       specifies any todo items left for 
                                          the routine
`:Uses:`          comments     none       specifies any other routines, 
                                          classes, etc. needed by the routine
`:Version:`       comments     none       specifies the version of the 
                                          routine
================= ============ ========== =================================



overview files tags

directory overview file tags


IDLdoc format style
~~~~~~~~~~~~~~~~~~~

The following tags are available in file comments (i.e. comment headers not immediately preceeding/following a routine header).

=============== ============ ============ ===================================
Tag name        Arguments    Attributes   Description
=============== ============ ============ ===================================
`@author`       comments     none         specifies the author of the file
`@copyright`    comments     none         specifies the copyright information 
                                          for the file
`@examples`     comments     none         specifies examples of usage
`@hidden`       none         none         if present, indicates the file is 
                                          not to be shown in the documentation
`@history`      comments     none         lists the history for the file
`@private`      none         none         if present, indicates the file 
                                          should not shown in user-level 
                                          documentation (set with the `USER` 
                                          keyword to IDLdoc)
`@property`     property     none         describes a property of a class, 
                name,                     i.e., a keyword to `getProperty`,
                comments                  `setProperty`, or `init`
`@version`      comments     none         specifies the version of the file
=============== ============ ============ ===================================

The following tags are available for comments immediately before or after a routine header.

================ ============ =========== ===================================
Tag name         Arguments    Attributes  Description
================ ============ =========== ===================================
`@abstract`      none         none        if present, indicates the method is 
                                          not implemented and present only to 
                                          specify the interface to subclasses' 
                                          implementations
`@author`        comments     none        specifies the author of the routine
`@bugs`          comments     none        specifies any issues found in the 
                                          routine
`@categories`    list         none        specifies a comma-separated list of 
                                          category names
`@copyright`     comments     none        specifies the copyright for the 
                                          routine
`@customer_id`   comments     none        specifies a customer ID for the 
                                          routine
`@description`   comments     none        a tag for the standard comments for 
                                          a routine; will be appended to 
                                          standard comments if both are 
                                          present
`@examples`      comments     none        specifies examples of using the 
                                          routine
`@field`         fieldname    none        specifies the name of the field 
                 and comments             followed by a description of the 
                                          field
`@file_comments` comments     none        equivalent to the main section in 
                                          file-level comments
`@hidden`        none         none        if present, indicate the routine 
                                          should not be shown in the 
                                          documentation
`@hidden_file`   none         none        if present, indicates the file 
                                          containing this routine should not 
                                          be shown in the documentation
`@history`       comments     none        specifies the history of the 
                                          routine
`@inherits`      none         none        not used
`@keyword`       keyword name see below   documents a keyword of the routine
`@obsolete`      none         none        if present, indicates the routine is 
                                          obsolete
`@param`         param name   see below   documents a positional parameter of 
                                          the routine
`@post`          comments     none        specifies any post-conditions of the 
                                          routine
`@pre`           comments     none        specifies any pre-conditions of the 
                                          routine
`@private`       none         none        if present, indicates the routine 
                                          should not shown in user-level 
                                          documentation (set with the `USER` 
                                          keyword to IDLdoc)
`@private_file`  comments     none        if present, indicates the file 
                                          containing this routine should not 
                                          shown in user-level documentation 
                                          (set with the `USER` keyword to 
                                          IDLdoc)
`@requires`      comments     none        specifies the IDL version of the 
                                          routine; IDLdoc finds the routines 
                                          requiring the highest IDL version 
                                          and reports them on the warnings 
                                          page
`@returns`       comments     none        specifies the return value of the 
                                          function
`@todo`          comments     none        specifies any todo items left for 
                                          the routine
`@uses`          comments     none        specifies any other routines, 
                                          classes, etc. needed by the routine
`@Version`       comments     none        specifies the version of the 
                                          routine
================ ============ =========== ===================================


overview files tags

directory overview file tags


IDL format style
~~~~~~~~~~~~~~~~

file tags

routine tags

overview files tags

directory overview file tags


Markup styles
-------------


rst markup style
~~~~~~~~~~~~~~~~

The *rst* markup style is the default markup style for the *rst* format style.

verbatim markup style
~~~~~~~~~~~~~~~~~~~~~

The *verbatim* markup style is the default markup style for the *IDLdoc* or *IDL* format styles.


preformatted style
~~~~~~~~~~~~~~~~~~

The *preformatted* markup style must be specified as a markup style, it is not the default for any format style. Comments are copied directly into the output and wrapped with markup to display them in a fixed width font.


Customizing output
------------------

