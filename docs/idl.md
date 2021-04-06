!!! success "[SALAT_MAKE_ALMA_CUBE](idl/salat_make_alma_cube.md)"
	Create ALMA cubes from individual files outputted by SoAP (put them together, remove bad frames and polish the cube), i.e., creates both pre-level4 (aka 'clean') and level4 cubes.
	```webidl
	IDL> salat_make_alma_cube, dir, files, savedir=savedir, filename=filename, date=date
	```

!!! success "[SALAT_POLISH_TSERIES](idl/salat_polish_tseries.md)"
	Corrects for temporal misalignments (i.e., between consecutive images in a time-series) as well as 'destretching' within the individual images (if needed), due to, e.g., seeing variation with time and/or miss-pointing.
	```webidl
	IDL> salat_polish_tseries, dir, cube, param=param, /nodestretch
	```

!!! success "[SALAT_CONTRAST](idl/salat_contrast.md)"
	Compute and plot "mean intensity" and "rms intensity contrast" of a cube and indicate bad/good frames based on a given threshold
	```webidl
	IDL> bestframe = salat_contrast(cube, limit=limit, sbadframes=badframes, goodframes=goodframes)
	```
	
!!! success "[SALAT_FITS2CRISPEX](idl/salat_fits2crispex.md)"
	Create a CRISPEX cube from the ALMA fits cube (any level) for quick inspections using the CRISPEX tool.
	```webidl
	IDL> salat_fits2crispex, cube, savedir=savedir, filename=filename
	```

!!! success "[SALAT_MAKE_MOVIE](idl/salat_make_movie.md)"
	Makes a movie (time series of images) from a polished (e.g., level4) data cube, along with an analog clock and beam size/shape depicted.
	```webidl
	IDL> salat_make_movie, cube, pixelsize=pixelsize, savedir=savedir, filename=filename
	```

!!! success "[SALAT_BAND_INFO](idl/salat_band_info.md)"
	Provide frequencies for ALMA receiver bands (currently only central frequencies)
	```webidl
	IDL> info = salat_band_info()
	```

!!! success "[SALAT_FILLGAPS](idl/salat_fillgaps.md)"
	Fill gaps in time-series data by linear interpolation, and optionally apply a temporal boxcar average.
	```webidl
	IDL> new_cube = salat_fillgaps(cube, cadence, time)
	```

!!! success "[SALAT_TELLURIC_TRANSMISSION](idl/salad_telluric_transmission.md)"
	Provides transmission of the Earth's atmosphere based tabulated data file.
	```webidl
	IDL> info = salad_telluric_transmission(band=band, pwv=pwv_req, frequency=freq_r, out_frequency=out_freq, out_pwv=out_pwv)
	```

!!! success "[SALAT_INT2BRTEMP](idl/salat_int2brtemp.md)"
	Convert intensity to brightness temperature.
	```webidl
	IDL> temp = salat_int2brtemp(intensity, lambda, rh=rh)
	```

!!! success "SALAT_COMBINE_SPECTRALWINDOWS"
	Combines data cubes for different spectral windows and does check if all time steps do exist in both cubes
	```webidl
	IDL> salad_combine_spectralwindows, dsw0, dsw1, nusw0, nusw1, time0, time1, spectralwindow=specwin
	```

!!! success "SALAT_INTENSITY_TO_K"
	Convery intensity to temperature using a conversion factor's vector
	```webidl
	IDL> salat_intensity_to_K
	```

!!! success "~~SALAT_MODIFY_HEADER_AND_INFO~~"
	Modify header of old cubes and add missing keywords
	```webidl
	IDL> salat_modify_header_and_info
	```
	
!!! success "~~SALAT_READ_FITSDATA~~"
	Reads in a FITS file 
	```webidl
	IDL> salad_read_fitsdata, filename
	```

!!! success "~~SALAT_READFITSHEADER~~" 
	Reads the FITS header and extracts relevant information 
	```webidl
	IDL> salat_readfitsheader, header
	```