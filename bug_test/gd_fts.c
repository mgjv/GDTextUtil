/*
 * This tests the correctness of the gdStringFT (or gdStringTTF) calls
 * over a range of sizes. libgd 1.8.4 has some problems with the fonts
 * that come with StarOffice 6 beta, for example. These problems are not
 * seen when using ftstrpnm to render the same font at the same size.
 */

#include <stdlib.h>
#include <stdio.h>
#include <gd.h>

#define TEST_STRING "Hello World!"

int 
main(int argc, char *argv[])
{
    int size_range[] = {6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20},
        size_num     = sizeof(size_range)/sizeof(size_range[0]),
        bb[8],
        black, white, 
	i, y;
    gdImagePtr im;
    FILE *pngout;

    if (argc < 2)
    {
	fprintf(stderr, "Need a font file name\n");
	return EXIT_FAILURE;
    }

    /* Create the image, and allocate colours */
    im    = gdImageCreate(500, 250);
    white = gdImageColorAllocate(im, 255, 255, 255);
    black = gdImageColorAllocate(im, 0, 0, 0);

    /* Draw strings */
    y = size_range[0] + 4;
    for (i = 0; i < size_num; i++)
    {
#if 1
#define GDTTF  gdImageStringFT
#define GDTTFs "StringFT"
#else
#define GDTTF  gdImageStringTTF
#define GDTTFs "StringTTF"
#endif
	char *err = GDTTF(im, bb, black, argv[1], size_range[i], 
	    0., 5, y, TEST_STRING);
	if (err)
	{
	    fprintf(stderr, GDTTFs": %s\n", err);
	    return EXIT_FAILURE;
	}
	y += size_range[i] + 4;
    }

    /* Save image */
    pngout = fopen("gd_fts.png", "wb");
    if (pngout == NULL)
    {
	perror("Cannot open gd_fts.png for write");
	return EXIT_FAILURE;
    }
    gdImagePng(im, pngout);

    /* clean up */
    fclose(pngout);
    gdImageDestroy(im);

    return EXIT_SUCCESS;
}
