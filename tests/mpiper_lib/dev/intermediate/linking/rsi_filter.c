/* Copyright 1997, Research Systems, Inc. All Rights Reserved */

#include <stdio.h>
#include "export.h"

IDL_VPTR RSI_Filter(int argc, IDL_VPTR argv[], char *argk)
{
	float *pfOutputImage;

	IDL_VPTR ivPlainArgs[2];
	IDL_VPTR ivOutputImage;
	IDL_VPTR ivTempInputImage = NULL;
	IDL_VPTR ivTempFilter = NULL;

	static isCenter;
	static IDL_LONG lCenter;

	IDL_KW_PAR ikpKeywords[] = {
		IDL_KW_FAST_SCAN,
/*
	Remember that new keywords must be added in lexical order!
*/
		{"CENTER", IDL_TYP_LONG, 1, IDL_KW_ZERO, &isCenter, IDL_CHARA(lCenter)}, 
		{NULL}
	};
	
	IDL_KWCleanup(IDL_KW_MARK);
	IDL_KWGetParams(argc, argv, argk, ikpKeywords, ivPlainArgs, 1);
/*
	Verify the input quantities.
*/
	IDL_ENSURE_ARRAY(ivPlainArgs[0]);
	IDL_ENSURE_SIMPLE(ivPlainArgs[0]);

	IDL_ENSURE_ARRAY(ivPlainArgs[1]);
	IDL_ENSURE_SIMPLE(ivPlainArgs[1]);
	
	if (ivPlainArgs[0]->value.arr->n_dim != 2)
		IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP, 
			"The input image must be two-dimensional.");

	if (ivPlainArgs[1]->value.arr->n_dim != 2)
		IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP, 
			"The input filter must be two-dimensional.");

	if (ivPlainArgs[1]->value.arr->dim[0] != 
		ivPlainArgs[1]->value.arr->dim[1])
		IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP, 
			"The input filter must be square.");

	if (ivPlainArgs[1]->value.arr->dim[0] % 2 != 1)
		IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP, 
			"The input filter must have an odd number of pixels in each dimension.");

	if ((ivPlainArgs[1]->value.arr->dim[0] > ivPlainArgs[0]->value.arr->dim[0]) ||
		(ivPlainArgs[1]->value.arr->dim[0] > ivPlainArgs[0]->value.arr->dim[1]))
		IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP, 
			"The input filter dimensions cannot be larger than the image's.");
/*
	Convert the input image to a floating point array, if necessary.
*/
	ivTempInputImage = IDL_BasicTypeConversion(1, &ivPlainArgs[0], IDL_TYP_FLOAT);
	ivTempFilter = IDL_BasicTypeConversion(1, &ivPlainArgs[1], IDL_TYP_FLOAT);
/*
	Create storage for the output image.  Initialize the array to zero
	since the algorithm is not defined for all pixels.
*/
	pfOutputImage = (float *) IDL_MakeTempArray(IDL_TYP_FLOAT, 2, 
		ivPlainArgs[0]->value.arr->dim, IDL_BARR_INI_ZERO, &ivOutputImage);
/*
	Execute the convolution
*/
	(void) rsi_convolve(ivPlainArgs[0]->value.arr->dim[0], 
		ivPlainArgs[0]->value.arr->dim[1], 
		(float *) ivTempInputImage->value.arr->data,
		ivPlainArgs[1]->value.arr->dim[0],
		(float *) ivTempFilter->value.arr->data,
		pfOutputImage, (int) lCenter);
/*
	If the filter and image were converted to floating point from
	something else, delete the temporary variables.
*/
	if (ivTempInputImage != ivPlainArgs[0])
		IDL_Deltmp(ivTempInputImage);

	if (ivTempFilter != ivPlainArgs[1])
		IDL_Deltmp(ivTempFilter);
/*
	Clean up the keywords.
*/
	IDL_KWCleanup(IDL_KW_CLEAN);
	return(ivOutputImage);
}

