# :low_brightness: SALAT_INTENSITY_TO_K

!!! example "SALAT_INTENSITY_TO_K"
	Combines data cubes for different spectral windows and does check if all time steps do exist in both cubes.
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> salat_alma_intensity_to_K, ALMAcube, conversion
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`ALMAcube`** | The ALMA cube, wither 3D [x,y,t] or 4D [x,y,sw,t] in intensity units | `required`
		**`conversion`** | The conversion vector: 1D if the there are no spectral windows (SW), or 2D if the ALMA cube is 4D. | `required`
	
	=== "OUTPUTS"
		CONVERTEDCUBE:	The ALMA cube in K (same dimension as the ALMACUBE)
		
	=== "EXAMPLE"
        To be added ....
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_combine_spectralwindows.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)" 