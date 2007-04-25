/*
  moment_w.c

  This wrapper program is used as an interface to pass parameters
  between IDL and the C program 'moment'.
*/

#include <stdio.h>
#include <stdlib.h>

#ifdef WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

// Declare the function prototypes for 'moment' and the wrapper 
// program 'moment_w'
EXPORT int moment_w(int, void **);
void moment(float *, int n, float *, float *, float *, 
	    float *, float *, float *);

// The wrapper routine 'moment_w'
EXPORT int moment_w(int argc, void *argv[])
{
  float *array;
  int n;
  float *wavg, *wadev, *wsdev, *wsvar, *wskew, *wcurt;

  // Define variables from the argv list to hold output from 
  // moment.
  array = (float *) argv[0];
  n = *(int *) argv[1];
  wavg = (float *) argv[2];
  wadev = (float *) argv[3];
  wsdev = (float *) argv[4];
  wsvar = (float *) argv[5];
  wskew = (float *) argv[6];
  wcurt = (float *) argv[7];

  // Call moment.
  moment(array, n, wavg, wadev, wsdev, wsvar, wskew, wcurt);

  return 1;
}
