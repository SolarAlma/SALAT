# :low_brightness: SALAT_SALSA_TO_CRISPEX

!!! example "SALAT_SALSA_TO_CRISPEX"
	Create a CRISPEX cube from the ALMA fits cube (3D, 4D, or 5D) for quick inspections using the CRISPEX tool. Note: the CRISPEX tool should be installed separately (https://github.com/grviss/crispex)
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> salat_salsa_to_crispex, cube, savedir=savedir
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`CUBE`** | The SALSA cube in FITS format. | `required`
		**`SAVEDIR`** | A directory (as a string) in where the CRISPEX (.fcube) file is stored (default = './') | `optional`
		
	=== "OUTPUTS"
		Parameter | Description
		------ | -----------
		**`N/A`** | The CRISPEX cube (.fcube) stored in the given location (i.e., SAVEDIR), with the same name as the input CUBE.
		
	=== "EXAMPLE"
		```webidl
		IDL> cube = './solaralma.b3.fba.2016-12-22.14_19_31-15_07_07.2016.1.00423.S.level4.k.fits'
		IDL> salat_salsa_to_crispex, cube, savedir='~/'
		IDL> crispex, '~/solaralma.b3.fba.2016-12-22.14_19_31-15_07_07.2016.1.00423.S.level4.k.fcube'
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_salsa_to_crispex.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)"