/*
  moment.c

  The program 'moment' computes the mean, absolute deviation, standard
  deviation, and moments 2-4 for an input vector.

  This program is copied from "Numerical Recipes in C", p 475.
*/

#include <math.h>

void moment(data, n, ave, adev, sdev, svar, skew, curt)
int n;
float data[], *ave, *adev, *sdev, *svar, *skew, *curt;
{
  int j;
  float s, p;

  // Get the mean.
  s = 0.0;
  for (j=1; j<=n; j++) s += data[j];
  *ave = s/n;

  // Get the higher moments.
  *adev = (*svar) = (*skew) = (*curt) = 0.0;
  for (j=1; j<=n; j++) {
    *adev += fabs(s = data[j] - (*ave));
    *svar += (p = s*s);
    *skew += (p *= s);
    *curt += (p *= s);
  }
  *adev /= n;
  *svar /= (n-1);
  *sdev = sqrt(*svar);
  if (*svar) {
    *skew /= (n*(*svar)*(*sdev));
    *curt = (*curt)/(n*(*svar)*(*svar)) - 3.0;
  } else *curt = -1.0;
}

