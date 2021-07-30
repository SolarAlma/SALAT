# :low_brightness: SALAT_MAKE_ALMA_CUBE

!!! example "SALAT_MAKE_ALMA_CUBE"
	Create ALMA cubes from individual files outputted by SoAP (put them together, remove bad frames and polish the cube), i.e., creates both pre-level4 (aka 'clean') and level4 cubes.
	
	**CALLING SEQUENCE:**
	```webidl
	IDL> salat_make_alma_cube, dir, files, savedir=savedir, filename=filename, date=date
	```
	=== "INPUTS / OPTIONAL KEYWORDS"
		Option | Description | Status
		------ | ----------- | -------
		**`DIR`** | Path to the directory in which the individual files are stored. | `required`
		**`FILES`** | A string representing filename template of the individual files from SoAP (i.e., replace time and scan number with *). The code should be run in the directory where the individual files are located. Example: 'solaralma.b6.2018-08-23-*.sw0123.sip.fba.level3.v011.image.pbcor.fits' | `required`
		**`DATE`** | Date of observations (as a string) in 'YYYY.MM.DD' format. Example: '2016.12.22' | `required`
		**`BADFRAMES`** | An array of 'bad frames' selected manually (e.g., with the help of 'salat_contrast'). Bad frames are also automatically identified. | `optional`
		**`SAVEDIR`** | A directory (as a string) in where the FITS cubes are stored (default = '~/'). | `optional`
		**`FILENAME`** | Name of the FITS cubes, as a string (default = 'solaralma'). | `optional`
	
	=== "OUTPUTS"
		Various FITS cubes stored in the given location.
		
		FITS Cube | Description
		------ | -----------
		ORIGINAL | 3D cube of individual SoAP files
		CLEAN | Same as ORIGINAL with the 'bad' frames removed
		LEVEL4 | Polished cube (correct for temporal misalignments, atmospheric effects, etc.)
		
	=== "EXAMPLE"
		To get the band information:
		```webidl
		IDL> dir = '/mn/stornext/d13/alma/almaobs_final/2017.1.00653.S/SolarAlma_fits_images.b6.sip.fba.level3.Sv012.Cv5.4.0-70.20200225-143144/'
		IDL> files = 'solaralma.b6.2018-04-12-*.sw0123.sip.fba.level3.v012.image.pbcor.fits'
		IDL> salat_make_alma_cube, dir, files, savedir='~/', filename='solaralma.b6.2018-04-12.cube.sw0123.sip.fba.level3.v012.image.pbcor'
		```
		
		!!! warning "Identifying the 'bad' frames may need some manual work! Take extra care for detecting the 'bad' frames."
	
	!!! quote "[Source code](https://github.com/SolarAlma/SALAT/blob/main/IDL/salat_make_alma_cube.pro)"

!!! Success "Back to the list of [IDL Routines](../idl.md)" 