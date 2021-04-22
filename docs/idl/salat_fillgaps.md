# :low_brightness: SALAT_FILLGAPS

!!! example "SALAT_FILLGAPS"
	Fill gaps in time-series data by linear interpolation, and optionally apply a temporal boxcar average.
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> new_cube = salat_fillgaps(cube, cadence, time)
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`CUBE`** | The input (polished; level4) FITS cube. | `required`
		**`CADENCE`** | Cadence of the observations (in seconds). | `required`
		**`TIME`** | Observing time sequence (in seconds) | `required`
	
	=== "OUTPUTS"
		A new cube, modified based on the options (default: filling gaps)
		
	=== "EXAMPLE"
		To get the band information:
		```webidl
		IDL> dir = '/mn/stornext/d13/alma/shahin/almaobs_level4/b3__2017-04-23/'
		IDL> cube = 'solaralma.b3.2017-04-23.17:19:19-18:52:54__2016.1.01129.S_clean_inK_sj_level4.fits'
		IDL> time = readfits(cube, ext=1)
		IDL> new_cube = salat_fillgaps(cube, 2, time)
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_fillgaps.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)" 