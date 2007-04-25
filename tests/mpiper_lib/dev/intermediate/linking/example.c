/*
  example.c

  The function 'sum_array' computes the sum of the elements in an
  input array. Two arguments are expected: the array and the number of
  elts in the array. The sum is returned.
*/
#include <stdio.h>

float sum_array(int argc, void *argv[])
{
  float *fp;
  float s = 0.0;
  int n;

  // Set the input args to local variables.
  fp = (float *) argv[0];
  n = *(int *) argv[1];

  // Compute and return the sum.
  for (n>0; n--;) s = s + (*fp++);
  return(s);
}
