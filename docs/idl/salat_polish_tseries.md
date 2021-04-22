# :low_brightness: SALAT_POLISH_TSERIES

!!! example "SALAT_POLISH_TSERIES"
	Corrects for temporal misalignments (i.e., between consecutive images in a time-series) as well as 'destretching' within the individual images (if needed), due to, e.g., seeing variation with time and/or miss-pointing.
	
	!!! warning "Please note that this procedure is also called within SALAT_MAKE_ALMA_CUBE. This code may need to be run if extra care (keywords; e.g., for 'destretching') is required."
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> salat_polish_tseries, dir, cube, param=param, /nodestretch
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`DIR`** | Path to the dirrecoty in where the input (clean; bad-frames removed) cube is stoted (default = `'./'`). | `required`
		**`CUBE`** | Name of input (clean) FITS cube in this format: (x,y,t). | `required`
		**`PARAM`** | An IDL save file including the images parameters. | `required`
		**`SAVEDIR`** | A directory (as a string) in where the FITS cubes are stored (default = DIR). | `optional`
		**`FILENAME`** | Name of the FITS cubes, as a string (default = same as CUBE + additional keywords). | `optional`
		**`NODESTRETCH`** | If set, destretching is not applied. | `optional`
		**`NP`** | Larger shake usually needs larger np. Typically, np = 4, if not helpful then np = 6 or 7, ... | `required`
		**`CLIP`** | Destretching parameter (default = `[12,4,2,1]`) | `optional`
		**`TILE`** | Destretching parameter (default = `[6,8,14,24]`) | `optional`
		**`TSTEP`** | Destretching parameter | `optional`
		**`SCALE`** | Destretching parameter (default = `1.0 / pixelsize`) | `optional`
		.... | .... | ....
		
		!!! warning "Destretching is rarely needed"
	
	=== "OUTPUTS"
		Two types of FITS cubes stored in the given location.
		
		FITS Cube | Description
		------ | -----------
		CORRECTED_APER | Polished cube (correct for temporal misalignments, atmospheric effects, etc.)
		LEVEL4 | Same as CORRECTED_APER, but with additional temporal boxcar (over 20 sec).
		
	=== "EXAMPLE"
		To get the band information:
		```webidl
		IDL> dir = '/mn/stornext/d13/alma/shahin/almaobs_level4/b3__2017-04-23/'
		IDL> cube = 'solaralma.b3.2017-04-23.17:19:19-18:52:54__2016.1.01129.S_clean.fits'
		IDL> param = 'solaralma.b3.2017-04-23.17:19:19-18:52:54__2016.1.01129.S_clean.save'
		IDL> salat_polish_tseries, dir, cube, param=param, /nodestretch
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_polish_tseries.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)" 
