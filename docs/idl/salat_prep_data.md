# :low_brightness: SALAT_PREP_DATA

!!! example "SALAT_PREP_DATA"
	Take a standard SALSA level 4 cube and convert it such that it is accepted by external viewers, such as CARTA. This involves removal of empty dimensions or - if all 5 dimensions are in use - removing a dimension as selected by the user. Right now: Reduce dimensions.
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> alma = salat_read(cube, header=header, time=time, beam_major=beam_major, beam_minor=beam_minor, beam_angle=beam_angle)
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`CUBE`** | The SALSA cube in FITS format. | `required`
		**`SAVEDIR`** | A directory (as a string) in where the new cube is stored (default = './') | `optional`
		
	=== "OUTPUTS"
		Parameter | Description
		------ | -----------
		**`N/A`** | The SALSA cube as an array. Information about dimension is printed in terminal. The new cube stored in the given location (i.e., SAVEDIR) with the same name as the input CUBE, but with a '_modified-dimension' added. All headers and extensions are passed to the new cube without any changes.
		
	=== "EXAMPLE"
		```webidl
		IDL> cube = './solaralma.b3.fba.2016-12-22.14_19_31-15_07_07.2016.1.00423.S.level4.k.fits'
		IDL> salat_prep_data, cube, savedir='~/'
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_prep_data.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)"