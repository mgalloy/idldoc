/*
  f2c.c

  The function 'f2c' accepts a Fahrenheit temperature value as input
  and returns the equivalent Celsius value.
*/

#include <stdio.h>
#include <stdlib.h>

#ifdef WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif


// Define the function prototypes for f2c and f2c_w.
double f2c(double);
EXPORT double f2c_w(int, void **);


// The function f2c.
double f2c(double f)	/* f is passed in, c is returned. */
{
  double c;
  c = (f-32.0) * (5.0/9.0);
  return c;
}


// The wrapper function F2C_w.
EXPORT double f2c_w(int argc, void *argv[])
{
  double f;
  f = *(double *) argv[0];
  return f2c(f);
}
