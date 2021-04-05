!!! success "[SALAT_BAND_INFO](idl/salat_band_info.md)"
	Provide frequencies for ALMA receiver bands (currently only central frequencies)
	```webidl
	IDL> info = salat_band_info()
	```

!!! success "[SALAT_CONTRAST](idl/salat_contrast.md)"
	Compute and plot "mean intensity" and "rms intensity contrast" of a cube and indicate bad/good frames based on a given threshold
	```webidl
	IDL> bestframe = salat_contrast(cube, limit=limit, sbadframes=badframes, goodframes=goodframes)
	```

!!! success "SALAT_READ_FITSDATA"
	Reads in a FITS file 
	```webidl
	IDL> salad_read_fitsdata, filename
	```

!!! success "SALAT_ALMA_READFITSHEADER" 
	Reads the FITS header and extracts relevant information 
	```webidl
	IDL> salat_alma_readfitsheader, header
	```

!!! success "SALAT_TELLURIC_TRANSMISSION"
	Provides transmission of Earth's atmosphere based tabulated data file  
	```webidl
	IDL> salad_telluric_transmission, band=band, pwv=pwv_req, frequency=freq_r, out_frequency=out_freq, out_pwv=out_pwv
	```

!!! success "SALAT_MAKE_ALMA_CUBE"
	Create ALMA cubes from individual files outputed by SoAP (put them together, remove bad frames and polish the cube), i.e., creates both pre-level4 and level4 cubes
	```webidl
	IDL> salat_make_alma_cube, filesearch, savedir=savedir, filename=filename, date=date
	```

!!! success "SALAT_ALMA_POLISH_TSERIES"
	Corrects for miss-alignement between images in a time-series (due to, e.g., seeing variation with time and/or mispointing)
	```webidl
	IDL> salat_alma_polish_tseries, dir=dir, cube=cube, ...
	```

!!! success "SALAT_MAKE_MOVIE"
	Makes a movie (time series of images) along with an analog clock and beam size/shap depicted
	```webidl
	IDL> salat_make_movie, almacube, pixelsize=pixelsize, savedir=savedir, filename=filename
	```

!!! success "SALAT_COMBINE_SPECTRALWINDOWS"
	Combines data cubes for different spectral windows and does check if all time steps do exist in both cubes
	```webidl
	IDL> salad_combine_spectralwindows, dsw0, dsw1, nusw0, nusw1, time0, time1, spectralwindow=specwin
	```

!!! success "SALAT_ALMA_INT2BRTEMP"
	Convert intensity to brightness temperature
	```webidl
	IDL> salat_alma_int2brtemp, intensity, lambda, rh=rh
	```

!!! success "SALAT_ALMA_FILLGAPS"
	Fill gaps in time-series data by linear interpolation, and optionally apply a temporal boxcar average
	```webidl
	IDL> salat_alma_fillgaps, cube, cadence, time, boxcar=boxcar
	```

!!! success "SALAT_ALMA_MODIFY_HEADER_AND_INFO"
	Modify header of old cubes and add missing keywords
	```webidl
	IDL> salat_alma_modify_header_and_info
	```

!!! success "SALAT_ALMA_INTENSITY_TO_K"
	Convery intensity to temperature using a conversion factor's vector
	```webidl
	IDL> salat_alma_intensity_to_K
	```

!!! success "SALAT_FITS2CRISPEX"
	Create a CRISPEX cube from a fits cube (for quick inspection using CRISPEX)
	```webidl
	IDL> salat_fits2crispex, fitscube, savedir=savedir, filename=filename
	```

