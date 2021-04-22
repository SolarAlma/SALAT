## General Routines

Codes for, e.g., reading the ALMA fits cubes and their headers

- [X] `SALAT_READ_FITSDATA`
- [X] `SALAT_ALMA_READFITSHEADER`

***

## Post Restorations

Codes which are applied on individual files outputted by SoAP to create
1. a single FITS cube (x,y,t), with necessary information in the header and as FITS extensions
2. identify and remove bad (broken) frames, i.e., '**_clean cube_**'
3. polish the cube (to correct for temporal misalignments and/or effect of seeing on small part of the images) and create the level4 data (optional: smooth the cube with a boxcar window of 10 frames)
4. Convert intensity cubes to brightness temperature

- [X] `SALAT_MAKE_ALMA_CUBE`
- [X] `SALAT_ALMA_POLISH_TSERIES`
- [X] `SALAT_ALMA_MODIFY_HEADER_AND_INFO`

***

## Simple Analysis

Code for simple and quick exploration of the data.

- [X] `SALAT_TELLURIC_TRANSMISSION`
- [X] `SALAT_MAKE_MOVIE`
- [X] `SALAT_COMBINE_SPECTRALWINDOWS`
- [X] `SALAT_ALMA_INT2BRTEMP`
- [X] `SALAT_ALMA_INTENSITY_TO_K`
- [X] `SALAT_ALMA_FILLGAPS`
- [X] `SALAT_CONTRAST`
- [X] `SALAT_FITS2CRISPEX`

