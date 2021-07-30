# :low_brightness: SALAT_CONVOLVE_BEAM

!!! example "SALAT_CONVOLVE_BEAM"
	Convolve a specified synthetic beam (from an ALMA observations) to a user-provided map  (e.g. from a simulation or observations with other instruments)
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> convolved_cube = salat_convolve_beam(data, beam)
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`DATA`** | A Cube or a frame (in FITS format; as a string) to be convolved with the ALMA beam | `required`
		**`PIXEL_SIZE`** | The pixel size (i.e., sampling resolution) of the DATA (in arcsec). | `required`
		**`BEAM`** | Beam parameters [major_axis, minor_axis, beam_angle] all in degrees. It can be a 3-element array (i.e., mean of the beam parameters), or  a [3,nt] array for a time series (i.e., time-varying parameters). If the latter, then nt (numebr of frames) should be equal to that in the DATA cube. | `required`
		**`ALMA_CUBE`** | The SALSA level4 data cube in FITS format. If provided, the beam parameters are extracted from this cube (i.e., the BEAM keyword is ignored). | `optional`
	
	=== "OUTPUTS"
		Parameter | Description
		------ | -----------
		**`CONVOLVED`** | Convolved Data cube or frame (same size as input DATA)
		
	=== "EXAMPLE"
		```webidl
		IDL> data = './bifrost_b3_frame400.fits'
		IDL> pixel_size = 0.066 ; arcsec
		IDL> alma_cube = './solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits'
		IDL> convolved = salat_convolve_beam(data, pixel_size=pixel_size, alma_cube=alma_cube)
		IDL> sjim, data, /fits, w=4, iris='FUV', title='original input image'
		IDL> sjim, convolved, w=6, iris='FUV', title='convolved image'
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_convolve_beam.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)"