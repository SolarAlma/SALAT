# :low_brightness: SALAT_FITS2CRISPEX

!!! example "SALAT_FITS2CRISPEX"
	Create a **CRISPEX** cube from the ALMA fits cube (any level) for quick inspections using the **CRISPEX** tool.
	
	!!! warning "To use the CRISPEX tool, you should first install it seperately. See the **[CRISPEX](https://github.com/grviss/crispex)** GitHub page for furthre information."
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> salat_fits2crispex, cube, savedir=savedir, filename=filename
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`CUBE`** | The ALMA data cube in `[x,y,t]` format | `required`
		**`FITS`** | It should be set if the cube is a fits file (default = 0). | `optional`
		**`SAVEDIR`** | A directory (as a string) in where the CRISPEX (.fcube) file is stored (default = './'). | `optional`
		**`FILENAME`** | Name of the CRISPEX cube, as a string (default = 'CRISPEX_cube'). | `optional`
	
	=== "OUTPUTS"
		Parameter | Description
		------ | -----------
		---- | The CRISPEX cube (.fcube) stored in the given location.
		
	=== "EXAMPLE"
		To get the band information:
		```webidl
		IDL> dir = '/mn/stornext/d13/alma/shahin/almaobs_level4/b3__2016-12-22/'
		IDL> cube = dir+'solaralma.b3.2016-12-22.14:19:31-15:07:07__2016.1.00423.S_clean_inK_sj_level4.fits'
		IDL> salat_fits2crispex, cube, /fits, savedir='~/', filename='solaralma.b3.2016-12-22'
		
			 >>> .... writing cube: ~/solaralma.b3.2016-12-22.fcube
			 
		IDL> crispex, '~/solaralma.b3.2016-12-22.fcube'
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_fits2crispex.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)"