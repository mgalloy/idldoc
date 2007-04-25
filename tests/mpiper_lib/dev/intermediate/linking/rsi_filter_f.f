C
C	Copyright 1997, Research Systems, Inc. All Rights Reserved
C
	INTEGER*4 FUNCTION RSI_CONVOLVE_F_EXT(ARGC, ARGV)
	INTEGER*4 ARGC
	INTEGER*4 ARGV(*)

	INTEGER*4 iArguments

	iArguments = LOC(ARGC)
	Call RSI_CONVOLVE_F(%val(ARGV(1)), %val(ARGV(2)),
     +		%val(ARGV(3)), %val(ARGV(4)), %val(ARGV(5)),
     +		%val(ARGV(6)), %val(ARGV(7)))
	RSI_CONVOLVE_F_EXT = 1
	RETURN
	END


	SUBROUTINE RSI_CONVOLVE_F(iImageX, iImageY, fImage, 
     +		iFilterDimension, fFilter,
     +		fOutputImage, iCenterFlag)
C
C	See the documentation for CONVOL in the IDL Reference Guide
C	for a description of the algorithm.  This *is not* the
C	internal IDL implementation of the function.
C
	INTEGER*4 iImageX, iImageY
	REAL*4 fImage(iImageX, iImageY)
	INTEGER*4 iFilterDimension
	REAL*4 fFilter(iFilterDimension, iFilterDimension)
	REAL*4 fOutputImage(iImageX, iImageY)
	INTEGER*4 iCenterFlag

	REAL*4 fSum
	INTEGER*4 t, u, i, j

	IF (iCenterFlag .eq. 0) THEN
	   DO t = iFilterDimension, iImageX
	      DO u = iFilterDimension, iImageY
	         fSum = 0.
	         DO i = 1, iFilterDimension
	            DO j = 1, iFilterDimension
	               fSum = fSum + fFilter(i, j) * 
     +                        fImage(t - i + 1, u - j + 1)
	            ENDDO
	        ENDDO
	        fOutputImage(t, u) = fSum
	     ENDDO
	   ENDDO
	ELSE
	   DO t = iFilterDimension, iImageX
	      DO u = iFilterDimension, iImageY
	         fSum = 0.
	         DO i = 1, iFilterDimension
	            DO j = 1, iFilterDimension
	               fSum = fSum + fFilter(i, j) *
     +                        fImage(t + i - iFilterDimension/2 + 1,
     +                               u + j - iFilterDimension/2 + 1)
	            ENDDO
	         ENDDO
                 fOutputImage(t, u) = fSum
	      ENDDO
	   ENDDO
	ENDIF
	RETURN
	END

