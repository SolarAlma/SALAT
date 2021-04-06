# :low_brightness: SALAT_MAKE_MOVIE

!!! example "SALAT_MAKE_MOVIE"
	Makes a movie (time series of images) from a polished (e.g., level4) data cube, along with an analog clock and beam size/shape depicted.
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> salat_make_movie, cube, pixelsize=pixelsize, savedir=savedir, filename=filename
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`CUBE`** | The input (polished; level4) FITS cube. | `required`
		**`PIXELSIZE`** | Pixel size in arcsec. | `required`
		**`SAVEDIR`** | A directory (as a string) in where the JPEG imgaes are stored. | `required`
		**`FILENAME`** | Base name of the JPEG imgaes, as a string (default = 'im'). | `optional`
	
	=== "OUTPUTS"
		JPEG frames of the movie stored in the given location (i.e., in `SAVEDIR`)
		
	=== "EXAMPLE"
		To get the band information:
		```webidl
		IDL> dir = '/mn/stornext/d13/alma/shahin/almaobs_level4/b3__2017-04-23/'
		IDL> cube = 'solaralma.b3.2017-04-23.17:19:19-18:52:54__2016.1.01129.S_clean_inK_sj_level4.fits'
		IDL> salat_make_movie, cube, pixelsize=0.34, savedir='~/images/'
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_make_movie.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)" 