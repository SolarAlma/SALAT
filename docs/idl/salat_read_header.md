# :low_brightness: SALAT_READ_HEADER

!!! example "SALAT_READ_HEADER"
	Reads in a SALSA level4 FITS cubes and outputs selected important header's parameters with meaningful names as a structure (default).
	These are also printed in terminal (unless otherwise omitted).
	All header parameters or the most important parameters with their original name tags can also be 
	outputted (optional).
	In all cases, the outputted structure also includes the original header as a string (at the end of the structure)
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> alma_header = salat_read_header(cube)
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`CUBE`** | The SALSA data cube in FITS format (if the header is not provided) | `required`
		**`HEADER`** | The header of the SALSA cube (if specified, then the CUBE is ignored) | `required`
		**`SILENT`** | If set, no information (i.e., selected important header's parameters) is printed in terminal. | `optional`
		**`ORIGINAL`** | If set, the selected important header's parameters are returned with their original name (abbreviation). Otherwise, they are returned with meaningful names (by default) | `optional`
		**`ALL`** | If set, all parameters from the header (with their original tag names) are outputted into the structure. If set, other cases are ignored (i.e., the selected important header's parameters are not outputted). | `optional`
	
	=== "OUTPUTS"
		Parameter | Description
		------ | -----------
		**`HEADER`** | The header parameters as a structure
		
	=== "EXAMPLE"
		```webidl
		IDL> cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
		IDL> header_structure = salat_read_header(cube)
		 -----------------------------------------------------------
		 |  Selected parameters from the header:
		 -----------------------------------------------------------
		 |  Time of observations: 2016-12-22T14:19:36.623999
		 |  ALMA Band: BAND3
		 |  ALMA Project ID: 2016.1.00423.S
		 |  Solar x (arcsec) ~ -0.0010000000
		 |  Solar y (arcsec) ~ 0.0010000000
		 |  Pixel size (arcsec): 0.32000000
		 |  Mean of major axis of beam (deg): 0.00058374900
		 |  Mean of minor axis of beam (deg): 0.00037963300
		 |  Mean of beam angle (deg): 0.00058374900
		 |  Frequency (Hz): 9.9990726e+10
		 |  Water Vapour: 1.59800
		 -----------------------------------------------------------
		IDL> help, header_structure
		** Structure <29afb58>, 18 tags, length=2512, data length=2501, refs=1:
		   SIMPLE          BOOLEAN   true (1)
		   MAJOR_BEAM_MEAN DOUBLE       0.00058374900
		   MINOR_BEAM_MEAN DOUBLE       0.00037963300
		   BEAM_ANGLE_MEAN DOUBLE           71.311844
		   ...		   ...			  ...
		IDL> pixel_size = header_structure.pixel_size
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_read_header.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)"