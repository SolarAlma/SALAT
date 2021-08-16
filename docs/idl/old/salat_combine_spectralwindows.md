# :low_brightness: SALAT_COMBINE_SPECTRALWINDOWS

!!! example "SALAT_COMBINE_SPECTRALWINDOWS"
	Combines data cubes for different spectral windows and does check if all time steps do exist in both cubes.
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> combined_cube = salat_combine_spectralwindows(dsw0, dsw1, nusw0, nusw1, time0, time1, spectralwindow=specwin)
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`MIDNIGHTHOUR`** | If set, time is expected as seconds after midnight. Otherwise, Julian dates are expected by default. | `optional`
		.... | .... | ....
	
	=== "OUTPUTS"
		Combined data cubes for different spectral windows
		
	=== "EXAMPLE"
        To be added ....
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_combine_spectralwindows.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)" 