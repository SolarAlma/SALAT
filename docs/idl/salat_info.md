# :low_brightness: SALAT_INFO

!!! example "SALAT_INFO"
	Prints some relevant information about the data cube in terminal
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> salat_info, cube
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`CUBE`** | The SALSA cube in FITS format | `required`
		
	=== "OUTPUTS"
		Parameter | Description
		------ | -----------
		**`N/A`** | Information printed in terminal only.
		
	=== "EXAMPLE"
		```webidl
		IDL> cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
		IDL> salat_info, cube
		--------------------------------------------------
		 |  Info:
		 --------------------------------------------------
		 |  ALMA Band: BAND3
		 |  Time of observations: 2016-12-22T14:19:36.623999
		 |  ALMA Project ID: 2016.1.00423.S
		 |  Pixel size (arcsec): 0.32000000
		 |  Beam average (arcsec): 1.73409
		 |  FOV diameter (arcsec): notcomputed
		 --------------------------------------------------
		 |  Data range:
		 --------------------------------------------------
		 |  Min (K): 4573.09
		 |  Max (K): 10635.5
		 --------------------------------------------------
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_info.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)"