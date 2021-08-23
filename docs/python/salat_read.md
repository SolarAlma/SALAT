# :low_brightness: SALAT_READ

!!! example "SALAT_READ"
	Reads in a SALSA level4 FITS cubes and provides information about the cube's dimension and other parameters stored as extensions,such as arrays of observing time, beam's size and angle.
	The SALSA datacubes have the following dimensions: [spatial (x), spatial (y), frequency (f), Stokes (s), time (t)].
	When using Python, the dimensions are reversed: [time (t),Stokes (s),frequency (f)spatial (y),spatial (x)].
	Thus, depending on the availability of full spectra and/or Stokes parameters, the cube may have 3-5 dimensions.
	
	**CALLING SEQUENCE:**
	```python
	>>> import salat
	>>> almacube,_,_,_,_,_,_ = salat.read(file)
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status | Default
		------ | ----------- | ------ | -------
		**`file`** | Path to the SALSA cube in FITS format. | `required` | 
		**`fill_NAN`** | If `True`, user will be asked to enter value or to choose if wants to use Median. | `optional` | `False`
		**`timeout`** | If `True`, it returns 2 1D array of time in seconds and in datetime format | `optional` | `False`
		**`beamout`** | If `True`, it returns 3 arrays with beam major and minor axes and beam angle | `optional` | `False`
		**`HEADER`** | If `True`, it returns the original header | `optional` | `True`
		**`SILENT`** | If `True`, no information is printed to the terminal.  | `optional` | `False`
	
	=== "OUTPUTS"
		Parameter | Description
		--------- | -----------
		**`sqcubecrop`** | The SALSA cube as an array. Information about dimension is printed in terminal. (Squeezed and cropped ALMA cube with dimensions [t,x,y])
		**`hdr`** | Header as astropy.io.fits.header.Header
		**`timesec`** | Array with time in seconds (0 s is start of observation)
		**`timeutc`** | Array with time in UTC as datetime.datetime
		**`beammajor`** | Name of a variable for Major axis of the beam (i.e., ALMA's sampling beam) in degrees 
		**`beaminor`** | Name of a variable for Minor axis of the beam in degrees
		**`beamangle`** | Name of a variable for Angle of the beam (in degrees) which is defined as angle of the Sun with respect to the north celestial pole, i.e. the ‘position angle’
		
	=== "EXAMPLE"
		Reading the data, header, time, and beam information from a SALSA data cube, without filling Nans:
		```python
		>>> import salat
		>>> file = "./solaralma.b3.fba.20161222_141931-150707.2016.1.00423.S.level4.k.fits"
		>>> almacube,header,timesec,timeutc,beammajor,beamminor,beamangle = salat.read(file,timeout=True,beamout=True,HEADER=True,SILENT=False,fillNan = False)
		```		
		```
		100%|██████████| 1200/1200 [00:00<00:00, 31689.21it/s]
		---------------------------------------------------
		--------------- SALAT READ part of ----------------
		-- Solar Alma Library of Auxiliary Tools (SALAT) --
		Reading ALMA cube
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
		Done!
		```
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/2a09174f7807fb1e60462161c87ae65425180b31/Python/salat.py#L18)"

!!! Success "Back to the list of [Python functions](../python.md)"