# :low_brightness: SALAT_READ_HEADER

!!! example "SALAT_READ_HEADER"
	Reads in a SALSA level4 FITS cubes and outputs selected important header's parameters with meaningful names as a structure (default). These are also printed in terminal (unless otherwise omitted). All header parameters or the most important parameters with their original name tags can also be outputted (optional). Optionally, the original header is returned. 

	**CALLING SEQUENCE:**
	```python
	>>> import salat
	>>> hdr = salat.read_header(file,)
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status | Default
		------ | ----------- | ------ | -------
		**`file`** | Path to the SALSA cube in FITS format. | `required` | 
		**`ALL`** | If `True`, original header as as astropy.io.fits.header.Header is returned. If `False`, header is returned as class structure depending of ORIGINAL parameters | `optional` | `False`
		**`ORIGINAL`** | If `True`, header is returned as Nametuple structure preserving original keyword names. If `False`, header is returned as Nametuple structure new meaninful keywords. | `optional` | `False`
		**`SILENT`** | If `True`, no information is printed to the terminal.  | `optional` | `False`

	=== "OUTPUTS"
		Parameter | Description
		--------- | -----------
		**`header`** | header is return depending of input parameters. When returned as NamedTuple Class variables can be accessed as header.__varname__

	=== "EXAMPLE"
		There are 3 possible ways of obtaining the header.
		```python
		>>> import salat
		>>> #FITS header is read and pass to a Class structure with new meaningful keywords
		>>> hdrmk = salat.read_header(file1,ALL=False,ORIGINAL=False,)
		>>> print("Header with meaningful keywords", hdrmk)
		>>> print("Get Pixelsize (hdrmk.pixel_size): ",hdrmk.pixel_size)
		```		
		```
		---------------------------------------------------
		------------ SALAT READ HEADER part of ------------
		-- Solar Alma Library of Auxiliary Tools (SALAT) --
		  
		 --------------------------------------------------
		 |  Selected parameters from the header:
		 --------------------------------------------------
		 |  Time of observations:  2016-12-22T14:19:36.623999
		 |  ALMA Band:  BAND3
		 |  ALMA Project ID:  2016.1.00423.S
		 |  Solar x (arcsec) ~  -0.001
		 |  Solar y (arcsec) ~  0.001
		 |  Pixel size (arcsec):  0.32
		 |  Mean of major axis of beam (deg):  0.000583749
		 |  Mean of minor axis of beam (deg):  0.000379633
		 |  Mean of beam angle (deg):  0.000583749
		 |  Frequency (Hz):  99990725896.68
		 |  Water Vapour:  1.598
		 ---------------------------------------------------
		  
		Header with meaningful keywords Header(major_beam_mean=0.000583749, minor_beam_mean=0.000379633, beam_angle_mean=71.31184387207, RA=271.2488635455, Dec=-25.42327076764, Frequency=99990725896.68, solarx=-0.001, solary=0.001, Rest_frequency=93000000000.1, DATE_OBS='2016-12-22T14:19:36.623999', ALMA_Band='BAND3', min_of_datacube=4573.09, max_of_datacube=10635.5, ALMA_project_id='2016.1.00423.S', water_vapour=1.598, pixel_size=0.32)
		Get Pixelsize (hdrmk.pixel_size):  0.32
		```
		```python
		>>> import salat
		>>> #FITS header is read and pass to a Class structure with original keywords
		>>> #SILENT=True to avoid printing
		>>> hdrok = salat.read_header(file1,ALL=False,ORIGINAL=True,SILENT=True)
		>>> print("Header with original keywords",hdrok)
		>>> print("Get Pixelsize (hdrok.CDELT1A): ",hdrok.CDELT1A)
		```	
		```
		Header with original keywords Header(BMAJ=0.000583749, BMIN=0.000379633, BPA=71.31184387207, CRVAL1=271.2488635455, CRVAL2=-25.42327076764, CRVAL3=99990725896.68, CRVAL1A=-0.001, CRVAL2A=0.001, RESTFRQ=93000000000.1, DATE_OBS='2016-12-22T14:19:36.623999', INSTRUME='BAND3', DATAMIN=4573.09, DATAMAX=10635.5, PROPCODE='2016.1.00423.S', PWV=1.598, CDELT1A=0.32)
		Get Pixelsize (hdrok.CDELT1A):  0.32
		```
		```python
		>>> import salat
		>>> #FITS header is read and returned in original format
		>>> hdroh = salat.read_header(file1,ALL=True,SILENT=True)
		```	

	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/69793a949e9cd2e110286221ad1785c31e9796d3/Python/salat.py#L161)"

!!! Success "Back to the list of [Python functions](../python.md)"