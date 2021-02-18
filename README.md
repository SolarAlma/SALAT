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
> Create ALMA cubes from individual files outputed by SoAP (put them together, remove bad frames and polish the cube), i.e., creates both pre-level4 and level4 cubes
```JavaScript
IDL> salat_make_alma_cube, filesearch, savedir=savedir, filename=filename, date=date
```

#### :round_pushpin: SALAT_ALMA_POLISH_TSERIES
> Corrects for miss-alignement between images in a time-series (due to, e.g., seeing variation with time and/or mispointing)
```JavaScript
IDL> salat_alma_polish_tseries, dir=dir, cube=cube, ...
```

#### :round_pushpin: SALAT_MAKE_MOVIE
> Makes a movie (time series of images) along with an analog clock and beam size/shap depicted
```JavaScript
IDL> salat_make_movie, almacube, pixelsize=pixelsize, savedir=savedir, filename=filename
```

#### :round_pushpin: SALAT_COMBINE_SPECTRALWINDOWS
> Combines data cubes for different spectral windows and does check if all time steps do exist in both cubes
```JavaScript
IDL> salad_combine_spectralwindows, dsw0, dsw1, nusw0, nusw1, time0, time1, spectralwindow=specwin
```

#### :round_pushpin: SALAT_ALMA_INT2BRTEMP
> Convert intensity to brightness temperature
```JavaScript
IDL> salat_alma_int2brtemp, intensity, lambda, rh=rh
```

#### :round_pushpin: SALAT_ALMA_FILLGAPS
> Fill gaps in time-series data by linear interpolation, and optionally apply a temporal boxcar average
```JavaScript
IDL> salat_alma_fillgaps, cube, cadence, time, boxcar=boxcar
```

#### :round_pushpin: SALAT_ALMA_MODIFY_HEADER_AND_INFO
> Modify header of old cubes and add missing keywords
```JavaScript
IDL> salat_alma_modify_header_and_info
```

#### :round_pushpin: SALAT_ALMA_INTENSITY_TO_K
> Convery intensity to temperature using a conversion factor's vector
```JavaScript
IDL> salat_alma_intensity_to_K
```

#### :round_pushpin: SALAT_CONTRAST
> Compute and plot "mean intensity" and "rms intensity contrast" of a cube and indicate bad/good frames based on a given threshold
```JavaScript
IDL> bestframe = salat_contrast(cube, limit=limit, sbadframes=badframes, goodframes=goodframes)
```

## Python routines

#### :round_pushpin: SALAT_ALMA_READFITSDATA
> Read all FITS in a folder and create DataCube, an array with times and extract pixelsize
```JavaScript
In [1]: run salat_alma_readfitsdata.py

In [2]: path_alma_fba = '/test_data/b3.2017-04-22/'

In [3]: dfba_alma_soap,tfba_alma_soap,arpx_alma_soap = ALMA_fits_reader(path_alma_fba) 
````

#### :round_pushpin: SALAT_ALMA_READFITSHEADER
> Read a FITS file and return the header
```JavaScript
In [1]: run salat_alma_readfitsheader.py

In [2]: file = file = '/test_data/b3.2017-04-22/solaralma.b3.2017-04-22-17:54:44.s17.sw0123.sip.fba.level3.v011.image.pbcor.in_K.nof.fits'

In [3]: header = alma_readheader(file,showheader = True)
````

#### :round_pushpin: SALAT_ALMA_SPLITSCANS
> Use the FITS READER to read data and create a cube split in all the scans for the observation
```JavaScript
In [1]: run salat_alma_readfitsheade.py

In [2]: path_alma_fba = '/test_data/b3.2017-04-22/'
        dfba_alma_soap,tfba_alma_soap,arpx_alma_soap = ALMA_fits_reader(path_alma_fba,Shahin_format=False)
        dfba_scans_alma,tfba_scans_alma = ALMA_splitcube_scans(tfba_alma=tfba_alma_soap,dfba_alma=dfba_alma_soap)
        print('')
        print('Number of scans: ',len(tfba_scans_alma))
        print('')
        print('Done!')
````

#### :round_pushpin: SALAT_ALMA_HELIOPROJECTIVE_SUNP
> Use a reference FITS file to compute the Helioprojective position from the original Coordinates 'gcrs'
```JavaScript
In [1]: run salat_alma_helioprojective_sunP.py

In [2]: file = '/test_data/b3.2017-04-22/solaralma.b3.2017-04-22-17:20:13.s11.sw0123.sip.fba.level3.v011.image.pbcor.in_K.nof.fits'
    	frame_ctro,frame_ctrh,sunpangle,tref = compute_helioprojective_sunp(file)
    	#To print the Central Poisition (x,y) found
    	print("(x,y) arcsec: ",frame_ctrh.Tx,frame_ctrh.Ty)
````

#### :round_pushpin: SALAT_ALMA_GETBEAM
> From the FITS file extract the beam major, minor axis and angle and create a numpy array with each. 
```JavaScript
In [1]: run salat_alma_getbeam.py

In [2]: path_alma_fba = '/SALAT/test_data/b3.2017-04-22/'
		bmaj_obs,bmin_obs,bpan_obs = get_ALMA_obs_beam(path_alma_fba)
````

#### :round_pushpin: SALAT_ALMA_ART_CONVOLVER_BEAM
> This script takes an ART cube and convolved with a chosen ALMA beam using DASK for parallelizing
> It has been tested in Viscacha producing the convolution of 3660 frames of simulation in about 5.5 hours
> It makes use of other scripts and needs to be generalized
