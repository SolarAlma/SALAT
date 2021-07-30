# :low_brightness: SALAT_BAND_INFO

!!! example "SALAT_BAND_INFO"
	Provide frequencies for ALMA receiver bands (currently only central frequencies)
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> info = salat_band_info()
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Type | Description | Default
		------ | ---- | ----------- | -------
		**`setup_commands`** | list of str | Run these commands before starting the documentation collection. | `[]`
	
	=== "OUTPUTS"
		Parameter | Type | Description
		------ | ---- | -----------
		**`setup_commands`** | list of str | Run these commands before starting the documentation collection.
		
		
	=== "EXAMPLE"
		To get the band information:
		```webidl
		IDL> help, info
	    	 BAND            INT       Array[10]
	    	 LAM_MM_LW       FLOAT     Array[10]
	    	 LAM_MM_UP       FLOAT     Array[10]
	    	 FRQ_GHZ_LW      FLOAT     Array[10]
	    	 FRQ_GHZ_UP      FLOAT     Array[10]
			 
		IDL> print, info.BAND
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_band_info.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)"