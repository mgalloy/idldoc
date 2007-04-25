/*

  pass_string

  A routine that accepts a string from IDL.

*/
#include <stdio.h>
#include <stdlib.h>
#include <export.h>

#ifdef WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

EXPORT int pass_string(int argc, void *argv[]) {

  return 1;
}
