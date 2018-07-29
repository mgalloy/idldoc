Release notes
=============

IDLdoc 3.6.2
------------
*Released July 28, 2018*

* Bug fix for image directive for image files in other directories specified
  with a relative path (fix by Dave Gellman).

* Only copying MathJax for LaTeX-style equations if not already present.

* Fixed crash when invalid format/markup was specified on the docformat line of
  a .pro file.


IDLdoc 3.6.1
------------
*Released June 11, 2014*

* Fix for some missing routines in the .sav file distribution.


IDLdoc 3.6.0
------------
*Released June 10, 2014*

* Checks for updates when using the VERSION keyword.

* Added Exelis VIS Doc Center output.

* Reporting only non-empty, non-comment lines in routines/files now.

* Improved algorithm for computing cyclomatic complexity and also reporting
  modified cyclomatic complexity.

* Updated to MathJax 2.0 and using the complete MathJax distribution for better
  LaTeX rendering.

* Listing methods inherited from parent classes.

* Miscellaneous bug fixes.

* Provides links to IDL library routines referenced in rst markup code syntax.

* HTML rst markup directive to include HTML directly into output (contributed by Phillip Bitzer).


IDLdoc 3.5.1
------------
*Released September 29, 2012*

* Fixed bug causing Categories page to not show Categories.


IDLdoc 3.5
----------
*Released September 10, 2012*

* Added list of inherited properties to class descriptions.

* Provides workaround for possible bug in IDL where list object contains
  strange variables that report as the type code for object, but are not
  actually objects (they are pointers).
  
* Fixed bug where Categories page showed private or hidden items.

* Added hide/show prompts in code snippets in HTML output from rst markup
  comments.

* Allow markup in Uses tag when using the rst markup parser. Note: the Uses
  tag is for a list of files or routines optionally separated by commas, plain
  text will have commas inserted between words.

* Fixed errors in LaTeX output.


IDLdoc 3.4.3
------------
*Released January 6, 2012*

* Fixed bug that prevented reporting search results.


IDLdoc 3.4.2
------------
*Released December 12, 2011*

* Removed IDL library routines from .sav file distribution of IDLdoc.


IDLdoc 3.4.1
------------
*Released November 28, 2011*

* Fixed another bug where parsing rst Requires tag would cause IDLdoc to
  crash.


IDLdoc 3.4
----------
*Released November 21, 2011*

* Allow LaTeX equation formatting.

* Fix for bug where links to routines, files, etc. in directory overview
  comments on the overview page were not correct.

* Adding links to parent items in index entries.

* Changes to HTML output styling including larger type size.

* Fixed bug where DLM contents could not be references using backtick notation
  in rst markup syntax.
  
* Added private and hidden attributes to directory names in overview file.

* Not showing warnings page when USER keyword is set.

* Fixed bug where parsing rst Requires tag would cause IDLdoc to crash.

* Fixed bug where Warnings page showed items from private or hidden items.


IDLdoc 3.3.1
------------
*Released January 8, 2011*

* Fixed memory leaks involved with computing complexity statistics and making
  shortened comments for overview files.

* Fix for bug where private/hidden items show up on categories page.


IDLdoc 3.3
----------
*Released October 20, 2010*

* Created tutorial and reference manual documentation.

* Added embed directive to embed SVG or other graphics formats. For the
  "latex" comment style, .svg will be replaced with .pdf.

* Directory overview comments can be picked up from a .idldoc file in each
  directory. Tags include private and hidden to control the level of
  visibility of the directory and its contents, as well as author, copyright,
  and history.

* Added ROUTINE_LINE_CUTOFFS keyword to control level of warning for number of
  lines in a routine (only used when STATISTICS is set). Set
  ROUTINE_LINE_CUTOFFS to a two-element array indicating the number of lines
  that needs to be exceeded before the routine has a warning or is flagged.

* McCabe complexity computed for each routine when STATISTICS set. Added
  COMPLEXITY_CUTOFFS keyword to control level of warning for complexity. Set
  COMPLEXITY_CUTOFFS to a two-element array indicating the complexity that
  needs to be exceeded before the routine has a warning or is flagged.

* Added a link in each routine's details to its source code.

* Improved rst markup style. Headings can be created by underlining with "="
  (for level 1 headings), "-" (level 2), or "~" (level 3). Links can be done
  explicitly via `my website <michaelgalloy.com>` or looked up in the scope
  of the comment's context, like `my_routine`. Added title directive so that
  .idldoc files can have a separate title to be display (instead of just their
  filename).

* Added a preformatted markup style which is nearly equivalent to verbatim,
  but also makes HTML output respect line-breaks.
  
* Added author, copyright, history, and version tags to the overview file

* Allow properties of a class to be marked as hidden or private in rst format.

* Small changes to ensure compatible with IDL 8.0.

* Miscellaneous bug fixes.


IDLdoc 3.2
----------
*Released June 5, 2009*

* Added ability to create LaTeX output. Use the TEMPLATE_PREFIX keyword to the
  IDLDOC command to specify that the LaTeX templates should be used and the
  COMMENT_STYLE keyword to specify that markup in comments in the source code
  should be converted to LaTeX in the output::

    idldoc, ..., template_prefix='latex-', comment_style='latex'

* Added ability to create documentation for DLM files. IDLdoc will
  automatically find .dlm files in the ROOT subdirectories and create
  documentation for them. No special comments in the .dlm file are necessary
  (or used).

* Added INDEX_LEVEL keyword to IDLDOC command to control the granularity of
  the index: 0 for no index; 1 for directories, classes, files, and routines;
  2 for level 1 items plus parameters, keywords, fields, properties, and sav
  file variables

* Adds links to names of routines and classes found in the Uses section for
  routines and files.

* Added color output in the output log for errors and warnings if the
  COLOR_OUTPUTLOG keyword is set or if the MG_TERMISTTY routine is present and
  returns true.

* Miscellaneous small bug fixes.


IDLdoc 3.1
----------
*Released June 18, 2008*

* Added ability to reference images in rst markup. IDLdoc will automatically
  copy referenced images into the output.

* In rst markup, illegal characters like < and > are automatically converted
  to character entities.
  
* Added `:Description:` tag for compatibility with IDL Workbench update.

* Changed default markup parser to rst when format parser is rst.

* Miscellaneous small bug fixes.


IDLdoc 3.0
----------
*Released January 21, 2008*

* IDLdoc 3.0 is completely rewritten from scatch. It is released under a
  BSD-style open source license (see COPYING file for legal details). Feel
  free to make modifications to the source code. If you add something cool
  that you think others would be interested, please send me a patch!
  
* Comments inside ;+/;- that are not immediately before or after a routine
  header are considered file level comments. (The file_comments tag is still
  used, but is no longer needed.) There are also file-level tags now; any
  routine level tag that is reasonable on the file-level is allowed (i.e. most
  anything except params, keywords, and returns).
  
* Routine comments can be immediately before or *after* the routine header.

* Comments can now contain basic restructured text markup. Separating lines
  of text with a blank line will create separate paragraphs. Ending a line
  with two colons (::) and then indenting will format the indented section
  like a block of code.

* It is now feasible to create your own library of templates for output. The
  TEMPLATE_PREFIX keyword specifies a prefix before the template names. The
  TEMPLATE_LOCATION keyword specifies a directory for the templates to use.
  The easiest way to get started with this is to copy the provided templates
  to a new location, specify that location with the TEMPLATE_LOCATION keyword,
  and start modifying those templates.
  
  Also the COMMENT_STYLE keyword specifies a classname of the class to handle
  outputting other types of comments besides HTML (i.e. LaTeX, rst, etc.).

* The style of the documentation can be changed with the FORMAT_STYLE and
  MARKUP_STYLE keywords for an IDLdoc run. These styles can also be changed on
  a file-by-file basis with a docformat comment on the first line of the file
  like::
  
      ; docformat = 'rst'
  
  Available with IDLdoc 3.0 are the default IDLdoc style, the IDL standard
  template, and a new restructured text based style.
  
* Uses "requires" tag on routines to find the highest version of IDL required
  by a project. Simply put the IDL version required as the first match to the
  regular expression::
 
      [[:digit].]+
 
  IDLdoc will automatically find it and compare it to other versions
  required. The warnings page will display the highest version required and
  list all the routines that require that version.
  
* The source link is always available (in IDLdoc 2.0 it was only active if the
  OUTPUT keyword was not used). There is a NOSOURCE keyword to explicitly
  not show source code if that is required. Copying the source code or linking
  to it is controlled by the SOURCE_LINK keyword.
  
* Ability to generate output for the IDL Assistant has not been reimplemented
  since IDL has a new help system in IDL 7.0. For now, only HTML designed for
  a normal browser is provided with IDLdoc (though with the TEMPLATE_*
  keywords, users could now do these customizations themselves).

* IDLdoc 3.0 requires IDL 6.2. IDLdoc runs on all platforms supported by IDL.
