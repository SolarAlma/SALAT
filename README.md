# SALAT: Solar ALMA Library of Auxiliary Tools


A collection of routines (programmed in IDL and/or Python) linked to post restorations and simple analysis/exploration of the ALMA data sets. A brief description of each code is listed below. See the code's headers for further explanations and keywords.


## IDL routines


#### :round_pushpin: SALAT_READ_FITSDATA
> Reads in a FITS file 
```JavaScript
IDL> salad_read_fitsdata, filename
```

#### :round_pushpin: SALAT_ALMA_READFITSHEADER
> Reads the FITS header and extracts relevant information 
```JavaScript
IDL> salat_alma_readfitsheader, header
```

#### :round_pushpin: SALAT_TELLURIC_TRANSMISSION
> Provides transmission of Earth's atmosphere based tabulated data file  
```JavaScript
IDL> salad_telluric_transmission, band=band, pwv=pwv_req, frequency=freq_r, out_frequency=out_freq, out_pwv=out_pwv
```

#### :round_pushpin: SALAT_MAKE_ALMA_CUBE
> Create ALMA cubes from individual files outputed by SoAP (put them together, remove bad frames and polish the cube), i.e., both pre-level4 and level4 cubes
```JavaScript
IDL> salat_make_alma_cube, filesearch, savedir=savedir, filename=filename, date=date
```

#### :round_pushpin: SALAT_ALMA_POLISH_TSERIES
> Corrects for miss-alignement between images in a time-series (due to, e.g., seeing variation with time and/or mispointing)
```JavaScript
IDL> salat_alma_polish_tseries, dir=dir, cube=cube, ...
```

#### :round_pushpin: SALAT_MAKE_MOVIE
> Males movie (time series of images) along with an analog clock and beam size/shap depicted
```JavaScript
IDL> salat_make_movie, almacube, pixelsize=pixelsize, savedir=savedir, filename=filename
```

## Python routines


