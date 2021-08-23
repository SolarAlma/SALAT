# :low_brightness: SALAT_INFO

!!! example "SALAT_INFO"
	Prints some relevant information about the data cube in terminal
	
	**CALLING SEQUENCE:**
	```python
	>>> import salat
	>>> salat.info(file)
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status | Default
		------ | ----------- | ------ | -------
		**`file`** | Path to the SALSA cube in FITS format. | `required` | 
	
	=== "OUTPUTS"
		Parameter | Description
		------ | -----------
		**`N/A`** | Information printed in terminal only.

		
	=== "EXAMPLE"
		```python
		>>> import salat
		>>> salat.info(file)
		```	
		```
		---------------------------------------------------
		--------------- SALAT INFO part of ----------------
		-- Solar Alma Library of Auxiliary Tools (SALAT) --
		----------------------------------------------
		| Data feat.: 
		----------------------------------------------
		|  ALMA BAND:  3
		|  Obs. Date:  2016-12-22
		|  ALMA proj:  2016.1.00423.S
		|  Pix. Unit:  K
		|  Pix. Size:  0.32  arcsec.
		|  Beam mean:  6242.723999999999  arcsec
		|  FOV. diam:  notcomputed
		----------------------------------------------
		| Data range 
		----------------------------------------------
		|  Min =  4573.09  Kelvin
		|  Max =  10635.5  Kelvin
		----------------------------------------------
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/9bfa6c648a27ea5b6958d51d8384420ec9096642/Python/salat.py#L487)"

!!! Success "Back to the list of [Python functions](../python.md)"


