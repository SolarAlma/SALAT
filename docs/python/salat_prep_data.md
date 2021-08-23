# :low_brightness: SALAT_PREP_DATA

!!! example "SALAT_PREP_DATA"
	Take a standard SALSA level 4 cube and convert it such that it is accepted by external viewers, such as CARTA. This involves removal of empty dimensions or - if all 5 dimensions are in use - removing a dimension as selected by the user. Right now: Reduce dimensions.
	
	**CALLING SEQUENCE:**
	```python
	>>> import salat
	>>> salat.prep_data(file)
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status | Default
		------ | ----------- | ------ | -------
		**`file`** | Path to the SALSA cube in FITS format. | `required` | 
		**`savedir`** | Path to directory to save in | `required` | `./`

	
	=== "OUTPUTS"
		Parameter | Description
		------ | -----------
		**`N/A`** | The new cube stored in the given location (i.e., `savedir`) with the same name as the input CUBE, but with a '_modified-dimension' added.

		
	=== "EXAMPLE"
		```python
		>>> import salat
		>>> salat.prep_data(file)
		```	
		```
		------------------------------------------------------
		------------ SALAT PREP DATA part of -------------
		---- Solar Alma Library of Auxiliary Tools (SALAT)----
		Done!
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/69793a949e9cd2e110286221ad1785c31e9796d3/Python/salat.py#L888)"

!!! Success "Back to the list of [Python functions](../python.md)"