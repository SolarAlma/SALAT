# :low_brightness: SALAT_BAND_INFO

!!! example "SALAT_BAND_INFO"
	Provide frequencies for ALMA receiver bands (currently only central frequencies)
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> info = salat_band_info()
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Default
		------ | ----------- | -------
		---- | ---- | ----
		
	=== "OUTPUTS"
		Parameter | Description
		------ | -----------
		**`BAND`** | ALMA Bands' identifier (1-10).
		**`LAM_MM_LW`** | Lower boundaries of the Bands; Wavelenth (in mm).
		**`LAM_MM_UP`** | Upper boundaries of the Bands; Wavelenth (in mm).
		**`FRQ_GHZ_LW`** | Lower boundaries of the Bands; Frequency (in GHz).
		**`FRQ_GHZ_UP`** | Upper boundaries of the Bands; Frequency (in GHz).
		
	=== "EXAMPLE"
		To get the band information:
		```webidl
		IDL> info = salat_band_info()
		IDL> help, info
	    	 BAND            INT       Array[10]
	    	 LAM_MM_LW       FLOAT     Array[10]
	    	 LAM_MM_UP       FLOAT     Array[10]
	    	 FRQ_GHZ_LW      FLOAT     Array[10]
	    	 FRQ_GHZ_UP      FLOAT     Array[10]
			  
		IDL> print, info.BAND[2], info.LAM_MM_LW[2], info.LAM_MM_UP[2], info.FRQ_GHZ_LW[2], info.FRQ_GHZ_UP[2]
			 3      2.60000      3.60000      84.0000      116.000
		```
		Thus, for Band 3, the wavelength and frequency ranges are 2.6-3.6 mm and 84-116 GHz, respectively. 
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_band_info.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)"
