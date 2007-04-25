/*

  imageread

  A routine that reads a flat binary image from a file, given the
  filepath to the file and the dimensions of the image contained in
  the file. The point is to demonstrate how to pass strings to
  external libraries.

  The BYTE type is defined in IDL's export.h as unsigned char.
  IDL_STRING and IDL_STRING_STR are also defined in export.h.

  For more info on IDL strings, see Ch 13 of the EDG.

  Compile & link syntax on Linux:
  $ gcc -c -shared -fPIC -I$IDL_DIR/external imageread.c
  $ ld -shared -o imageread.so imageread.o

*/
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <export.h>

#ifdef WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

// What is the BYTE type? It's defined in export.h as unsigned char.
typedef UCHAR BYTE;

// Prototype functions.
void imageread(char *, int, int, BYTE *);
EXPORT imageread_w(int, void **);

/*

***************
* imageread_w *
***************

  This wrapper routine accepts and parses input from IDL and passes
  info to imageread.
*/
EXPORT int imageread_w(int argc,
		       void *argv[]) {

  // Define variables.
  char *filename;
  int xsize, ysize;
  BYTE *imagedata;
  IDL_STRING *sfilename;

  // Parse the set of void pointers argv into individual variables.
  sfilename = (IDL_STRING *) argv[0];
  xsize = *(int *) argv[1];
  ysize = *(int *) argv[2];
  imagedata = (BYTE *) argv[3];

  // The macro IDL_STRING_STR takes as its argument a pointer to an
  // IDL_STRING struct. If the string is null, it returns a pointer to
  // a zero-length null-terminated string, otherwise it returns the
  // string pointer from the struct. Consistent use of this macro will
  // avoid the most common error involving strings -- a pointer to a
  // null string.
  filename = IDL_STRING_STR(sfilename);

  // Call imageread.
  imageread(filename, 
	    xsize,
	    ysize,
	    imagedata);

  // Return.
  return 1;
}

/*

*************
* imageread *
*************

*/
void imageread(char *filename, 
	       int xsize,
	       int ysize,
	       BYTE *imagedata) {

  // Define variables.
  int imagefile;
  char imagename[80];
  int nbytes;
  int goodread;
  void *tempimagepointer;

  // Cast the imagedata pointer to a void pointer.
  tempimagepointer = (void *) imagedata;
  
  // Count the number of bytes in the image file.
  nbytes = xsize*ysize;

  // Open the image file. The open function expects a char array.
  strcpy(imagename, filename);
  imagefile = open(imagename, O_RDONLY);
  if (imagefile == -1) {
    fprintf(stderr, "Error opening file %s.\n", imagefile);
    return;
  }

  // Read the data from the file.
  goodread = read(imagefile, tempimagepointer, nbytes);

  // Close the file.
  close(imagefile);
}
