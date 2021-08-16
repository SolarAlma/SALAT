# :low_brightness: SALAT_INT2BRTEMP

!!! example "SALAT_INT2BRTEMP"
	Convert intensity to brightness temperature.
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> temp = salat_int2brtemp(intensity, lambda, rh=rh)
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`INTENSITY`** | ALMA's intensity (in erg cm^-2 s^-1 A^-1 sr^-1) | `required`
		**`LAMBDS`** | Wavelength in Å | `required`
		**`RH`** | convert intensities from RH code, wavelengths in nm ! | `optional`
	
	=== "OUTPUTS"
		Converted paramter (i.e., to brightness temperature)

		
	=== "EXAMPLE"

	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_int2brtemp.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)" 