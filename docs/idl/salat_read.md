# :low_brightness: SALAT_READ

!!! example "SALAT_READ"
	Reads in a SALSA level4 FITS cubes and provides information about the cube's dimension and other parameters stored as extensions,
	such as arrays of observing time, beam's size and angle.
	The SALSA datacubes have the following dimensions: [spatial (x), spatial (y), frequency (f), Stokes (s), time (t)].
	Thus, depending on the availability of full spectra and/or Stokes parameters, the cube may have 3-5 dimensions.
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> alma = salat_read(cube, header=header, time=time, beam_major=beam_major, beam_minor=beam_minor, beam_angle=beam_angle)
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`CUBE`** | Path to the SALSA cube in FITS format. | `required`
		**`NAN_VALUE`** | User defined value to replace all NaN values (outside the science field of view). | `optional`
		**`NAN_MEDIAN`** | If set, the NaN values are replaced with the median of the entire data cube. Overrides NAN_VALUE if both are set. | `optional`
		**`SILENT`** | If set, no information is printed to the terminal.  | `optional`
	
	=== "OUTPUTS"
		Parameter | Description
		------ | -----------
		**`ALMA`** | The SALSA cube as an array. Information about dimension is printed in terminal.
		**`HEADER`** | Name of a an IDL structure to store header of the FITS cube (calls salat_load_header.pro). By default, the most important header's parameters with meaningful tag names are outputted as a structure. Extra keywords: add /all for all parameters in the header, and/or /original for their original tag names/abbreviations
		**`TIME`** | Name of a variable for observing time, in seconds from UTC midnight (`optional`)
		**`BEAM_MAJOR`** | Name of a variable for Major axis of the beam (i.e., ALMA's sampling beam) in degrees (`optional`)
		**`BEAM_MINOR`** | Name of a variable for Minor axis of the beam in degrees (`optional`)
		**`BEAM_ANGLE`** | Name of a variable for Angle of the beam (in degrees) which is defined as angle of the Sun with respect to the north celestial pole, i.e. the ‘position angle’ (`optional`)
		
	=== "EXAMPLE"
		Reading the data, header, time, and beam information from a SALSA data cube:
		```webidl
		IDL> cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
		IDL> alma = salat_read(cube, header=header, time=time, beam_major=beam_major, beam_minor=beam_minor, beam_angle=beam_angle)
		... data cube dimension: 3D [x,y,time]
		... data set of dimensions x,y: 320,320
		... number of frames: 1200
		IDL> help, header
		** Structure <231ecc8>, 136 tags, length=3840, data length=3803, refs=1:
		   SIMPLE          BOOLEAN   true (1)
		   BITPIX          LONG               -64
		   NAXIS           LONG                 5
		   NAXIS1          LONG               320
		   ...		   ...		      ...
		IDL> help, time, beam_major, beam_minor, beam_angle
		TIME            FLOAT     = Array[1200]
		BEAM_MAJOR      FLOAT     = Array[1200]
		BEAM_MINOR      FLOAT     = Array[1200]
		BEAM_ANGLE      FLOAT     = Array[1200]
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_read.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)"