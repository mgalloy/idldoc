/* 

   convolve

   A routine to perform a digital convolution between an image array
   and a filter array. This is not the same code as in the IDL CONVOL
   function.

   Parameters:
   fImage = a 2D rectangular float array; the image
   iImageX = the horizontal size of the image
   iImageY = the vertical size of the image
   fFilter = a 2D square float array; the filter
   iFilterDim = the width of the filter
   fOutputImage = a 2D float array; the filtered image
   iCenterFlag = 1 if filter is centered; 0 otherwise

*/

void convolve(int iImageX,
	      int iImageY, 
	      float fImage[], 
	      int iFilterDim, 
	      float fFilter[],
	      float fOutputImage[], 
	      int iCenterFlag)
{   
  float fSum;
  int t, u, i, j;   
  float *pfFilterLine;   
  float *pfImageLine;

  if (iCenterFlag == 0) {
    for (t = iFilterDim - 1; t < iImageX; t++) {
      for (u = iFilterDim - 1; u < iImageY; u++) {
	fSum = (float) 0.;
	for (i = 0; i < iFilterDim; i++) {
	  pfFilterLine = &fFilter[i*iFilterDim];
	  pfImageLine = &fImage[(t - i)*iImageX + u];
	  for (j = 0; j < iFilterDim; j++)
	    fSum += *pfFilterLine++ * *pfImageLine--;
	}
	fOutputImage[t*iImageX + u] = fSum / (iFilterDim*iFilterDim);
      }
    }   
  } 
  else 
    {
      for (t = iFilterDim - 1; t < iImageX - 1; t++) {
	for (u = iFilterDim - 1; u < iImageY - 1; u++) {
	  fSum = (float) 0.;
	  for (i = 0; i < iFilterDim; i++) {
	    pfFilterLine = &fFilter[i*iFilterDim];
	    pfImageLine = &fImage[(t + i - iFilterDim/2)*iImageX + 
				  u + iFilterDim/2];
	    for (j = 0; j < iFilterDim; j++)
	      fSum += *pfFilterLine++ * *pfImageLine--;
	  }
	  fOutputImage[t*iImageX + u] = fSum / (iFilterDim*iFilterDim);
	}      
      }   
    }   
  return;
}


/* 

   convolve_w

   A wrapper routine for convolve, used for communication with IDL's
   argc-argv calling convention used in CALL_EXTERNAL.

*/

#ifdef WIN32
#define IDL_LONG_RETURN __declspec(dllexport) int
#else
#define IDL_LONG_RETURN int
#endif

void convolve(int iImageX, int iImageY, float fImage[], 
	      int iFilterDim, float fFilter[],
	      float fOutputImage[], int iCenterFlag);

IDL_LONG_RETURN convolve_w(int argc, void *argv[])
{	
  int iImageX;
  int iImageY;
  float *pfImage;
  int iFilterDimension;
  float *pfFilter;
  float *pfOutputImage;
  int iCenterFlag;

  // Parse the argument list from IDL into named variables.
  iImageX = *(int *) argv[0];
  iImageY = *(int *) argv[1];
  pfImage = (float *) argv[2];
  iFilterDimension = *(int *) argv[3];
  pfFilter = (float *) argv[4];
  pfOutputImage = (float *) argv[5];
  iCenterFlag = *(int *) argv[6];

  convolve(iImageX, iImageY, pfImage, iFilterDimension, pfFilter, 
	   pfOutputImage, iCenterFlag);

  return(1);
}
